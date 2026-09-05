import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';

/// Connects directly to Dhan WebSocket using dart:io (works on Android/iOS)
class LivePriceService {
  LivePriceService._();
  static final LivePriceService instance = LivePriceService._();

  final Map<String, double> _prices    = {};
  final Map<String, double> _prevClose = {};

  // Last seen LTP per security — survives market close and app restarts
  final Map<String, double> _lastSeen  = {};

  final _controller = StreamController<Map<String, double>>.broadcast();

  WebSocket? _ws;
  bool _isConnected = false;
  bool _isStarted   = false;
  Timer? _reconnectTimer;
  Timer? _flushTimer;

  String _clientId    = '';
  String _accessToken = '';

  // Instruments queued before connection is ready
  final List<Map<String, String>> _pending = [];

  // Called whenever a price updates — used to bridge direct WS → BLoC state
  void Function(String securityId, double ltp)? onPriceUpdate;

  // ── GetStorage keys ──────────────────────────────────────────────────────────
  static const _kLastSeen  = 'lps_last_seen';
  static const _kPrevClose = 'lps_prev_close';
  final _box = GetStorage();

  Stream<Map<String, double>> get stream    => _controller.stream;
  Map<String, double> get prices            => Map.unmodifiable(_prices);
  double priceOf(String securityId)         => _prices[securityId] ?? -1;
  double prevCloseOf(String securityId)     => _prevClose[securityId] ?? 0;
  double lastSeenPriceOf(String securityId) => _lastSeen[securityId] ?? 0;
  String get marketAccessToken              => _accessToken;
  String get marketClientId                 => _clientId;

  // ── Market hours (IST, NSE/BSE) ─────────────────────────────────────────────
  // Returns true Mon–Fri between 09:15 and 15:30 IST.
  // Holiday detection is not included; market will show "open" on exchange holidays.
  static bool get isMarketOpen {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false;
    }
    final open  = DateTime(now.year, now.month, now.day, 9, 15);
    final close = DateTime(now.year, now.month, now.day, 15, 30);
    return now.isAfter(open) && now.isBefore(close);
  }

  // ── Storage: restore cached prices on startup ─────────────────────────────
  void _restoreFromStorage() {
    final ls = _box.read<Map>(_kLastSeen);
    if (ls != null) {
      _lastSeen.addAll(
        ls.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      );
    }
    final pc = _box.read<Map>(_kPrevClose);
    if (pc != null) {
      _prevClose.addAll(
        pc.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      );
    }
  }

  void _flushToStorage() {
    _box.write(_kLastSeen,  Map<String, double>.from(_lastSeen));
    _box.write(_kPrevClose, Map<String, double>.from(_prevClose));
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 60), (_) => _flushToStorage());
  }

  // ── Fetch SELF token from backend and connect ──────────────────────────────
  Future<void> start() async {
    if (_isStarted) return;
    _restoreFromStorage();  // load cached prices before any live data arrives
    _startFlushTimer();

    try {
      print('[LivePrice] Fetching market token from backend...');
      final response = await ApiHelper.get(ApiEndpoints.marketTokenApi);
      if (response != null && response['status'] == true) {
        _clientId    = response['data']['clientId']?.toString() ?? '';
        _accessToken = response['data']['accessToken']?.toString() ?? '';
        print('[LivePrice] Token received — clientId=$_clientId tokenLen=${_accessToken.length}');
        if (_clientId.isNotEmpty && _accessToken.isNotEmpty) {
          _isStarted = true;
          _connect();
        } else {
          print('[LivePrice] ❌ Token or clientId empty');
        }
      } else {
        print('[LivePrice] ❌ market-token API failed: ${response?['message']}');
      }
    } catch (e) {
      print('[LivePrice] ❌ start() error: $e');
    }
  }

  void _connect() {
    _reconnectTimer?.cancel();
    final url = 'wss://api-feed.dhan.co?version=2&token=$_accessToken&clientId=$_clientId&authType=2';
    print('[LivePrice] Connecting to Dhan (dart:io WebSocket)...');

    WebSocket.connect(url).then((ws) {
      _ws = ws;
      _isConnected = true;
      print('[LivePrice] ✅ Connected to Dhan');

      if (_pending.isNotEmpty) {
        final toSend = List<Map<String, String>>.from(_pending);
        _pending.clear();
        subscribe(toSend);
      }

      ws.listen(
        (data) => _handleMessage(data),
        onDone: () {
          _isConnected = false;
          print('[LivePrice] 🔌 Disconnected — reconnecting in 30s');
          _flushToStorage();  // save prices before reconnect gap
          _reconnectTimer = Timer(const Duration(seconds: 30), _connect);
        },
        onError: (e) {
          _isConnected = false;
          print('[LivePrice] ❌ Error: $e');
        },
        cancelOnError: false,
      );
    }).catchError((e) {
      _isConnected = false;
      print('[LivePrice] ❌ Connect failed: $e');
      _reconnectTimer = Timer(const Duration(seconds: 30), _connect);
    });
  }

  // ── Subscribe instruments ─────────────────────────────────────────────────
  void subscribe(List<Map<String, String>> instruments) {
    if (instruments.isEmpty) return;
    if (!_isConnected || _ws == null) {
      _pending.addAll(instruments);
      return;
    }

    const batchSize = 100;
    for (var i = 0; i < instruments.length; i += batchSize) {
      final batch = instruments.sublist(
        i, (i + batchSize) > instruments.length ? instruments.length : i + batchSize,
      );
      final msg = jsonEncode({
        'RequestCode': 15,
        'InstrumentCount': batch.length,
        'InstrumentList': batch,
      });
      _ws!.add(msg);
      print('[LivePrice] 📤 Subscribed ${batch.length} instruments');
    }
  }

  // ── Parse Dhan binary packet ──────────────────────────────────────────────
  // code=2 → LTP (current price)
  // code=6 → prev_close
  void _handleMessage(dynamic data) {
    try {
      Uint8List bytes;
      if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is Uint8List) {
        bytes = data;
      } else {
        return;
      }

      if (bytes.length < 12) return;

      final code  = bytes[0];
      final bd    = ByteData.sublistView(bytes);
      final secId = bd.getUint32(4, Endian.little).toString();
      final value = double.parse(bd.getFloat32(8, Endian.little).toStringAsFixed(2));

      if (code == 2) {
        _prices[secId]   = value;
        _lastSeen[secId] = value; // persist last seen LTP
        _controller.add(Map.from(_prices));
        onPriceUpdate?.call(secId, value);
      } else if (code == 6) {
        _prevClose[secId] = value;
      }
    } catch (_) {}
  }

  // Called by TerminalBloc when Socket.io relay receives priceUpdate
  void updateFromRelay(String securityId, double ltp) {
    if (securityId.isNotEmpty) {
      _prices[securityId]   = ltp;
      _lastSeen[securityId] = ltp;
      _controller.add(Map.from(_prices));
    }
  }

  void dispose() {
    _flushToStorage();
    _flushTimer?.cancel();
    _reconnectTimer?.cancel();
    _ws?.close();
    _controller.close();
  }
}
