import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/network/api_endpoints.dart';
import 'package:investapas/core/network/api_service.dart';
import 'package:investapas/core/utils/navigationService.dart';
import 'package:investapas/core/utils/shared_prefs_helper.dart';
import 'package:investapas/data/models/market_item.dart';
import 'package:investapas/domain/repositories/portfolio.dart';
import 'package:investapas/routes/appRoutes.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../../../data/services/live_price_service.dart';
import 'terminal_event.dart';
import 'terminal_state.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {

  Timer? _portfolioTimer;
  socket_io.Socket? _socket;
  final SharedPrefsHelper prefs = SharedPrefsHelper();

  TerminalBloc() : super(const TerminalState()) {

    on<ChangeMarketTab>((event, emit) {
      emit(state.copyWith(marketTab: event.tab, items: []));
    });

    on<ChangeTerminalSubViewEvent>((event, emit) {
      emit(state.copyWith(subView: event.subView));
      if (event.subView == TerminalSubView.positions) {
        add(const LoadPortfolioEvent());
      }
    });

    on<SearchStockEvent>((event, emit) async {
      if (event.query.trim().isEmpty) {
        emit(state.copyWith(searchQuery: '', searchItems: [], isLoading: false));
        return;
      }
      emit(state.copyWith(searchQuery: event.query));
      try {
        final response = await ApiHelper.get(
          "${ApiEndpoints.searchApi}?search=${event.query}",
        );
        if (response["status"] == true) {
          final List data = response["data"];
          final items = data.map((e) => MarketItem(
            securityId: e['securityId']?.toString() ?? '',
            name: e['name'] ?? '',
            symbol: e['symbol'] ?? '',
            exchangeSegment: e['exchangeSegment'] ?? '',
            exchange: e['exchange'] ?? '',
            lotSize: e['lotSize']?.toString() ?? '1',
            isUp: true,
            strikePrice: e['strikePrice']?.toString(),
            optionType: e['optionType']?.toString(),
            expiry: e['expiry']?.toString(),
          )).toList();
          emit(state.copyWith(isLoading: false, searchItems: items));
          // Subscribe search results via both relay and direct WS
          _subscribeItems(items);
          LivePriceService.instance.subscribe(
            items.map((i) => {
              'ExchangeSegment': _resolveSegment(i.exchange, i.exchangeSegment),
              'SecurityId': i.securityId,
            }).toList(),
          );
        } else {
          emit(state.copyWith(isLoading: false, searchItems: []));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, searchItems: []));
      }
    });

    on<LoadPortfolioEvent>((event, emit) async {
      emit(state.copyWith(portfolioLoading: true));
      await _doFetchPortfolio(emit);
    });

    on<RefreshPortfolioSilentEvent>((event, emit) async {
      await _doFetchPortfolio(emit);
    });

    on<LoadInstrumentsEvent>((event, emit) async {
      if (state.instrumentsLoading) return;
      if (event.page > 1 && !state.hasMoreInstruments) return;

      emit(state.copyWith(instrumentsLoading: true));
      try {
        final response = await ApiHelper.get(
          "${ApiEndpoints.instrumentsApi}?page=${event.page}",
        );
        if (response["status"] == true) {
          final List data = response["data"];
          final int totalPages = response["totalPages"] ?? 1;

          final newItems = data.map<MarketItem>((e) => MarketItem(
            securityId: e['securityId']?.toString() ?? '',
            name: e['name'] ?? '',
            symbol: e['symbol'] ?? '',
            exchangeSegment: e['exchangeSegment'] ?? '',
            exchange: e['exchange'] ?? '',
            lotSize: e['lotSize']?.toString() ?? '1',
            isUp: true,
            strikePrice: e['strikePrice']?.toString(),
            optionType: e['optionType']?.toString(),
            expiry: e['expiry']?.toString(),
          )).toList();

          final updatedItems = event.page == 1
              ? newItems
              : [...state.instrumentItems, ...newItems];

          emit(state.copyWith(
            instrumentItems: updatedItems,
            instrumentsPage: event.page,
            instrumentsTotalPages: totalPages,
            instrumentsLoading: false,
          ));

          // Subscribe via Socket.io (backend relay)
          _subscribeItems(newItems);

          // Also subscribe directly to Dhan for fast prices
          LivePriceService.instance.subscribe(
            newItems.map((i) => {
              'ExchangeSegment': _mapSegment(i.exchangeSegment),
              'SecurityId': i.securityId,
            }).toList(),
          );

        } else {
          emit(state.copyWith(instrumentsLoading: false));
        }
      } catch (_) {
        emit(state.copyWith(instrumentsLoading: false));
      }
    });

    // ── Live price update (from Socket.io relay) ──────────────────────────
    on<LivePriceUpdateEvent>((event, emit) {
      // Also push into LivePriceService so UI StreamBuilder picks it up
      LivePriceService.instance.updateFromRelay(event.securityId, event.ltp);
      final updated = Map<String, double>.from(state.livePrices);
      updated[event.securityId] = event.ltp;
      emit(state.copyWith(livePrices: updated));
    });

    // ── Socket connected → subscribe ALL instruments ──────────────────────
    on<SocketConnectedEvent>((event, emit) {
      emit(state.copyWith(isSocketConnected: true));

      // Subscribe major indices (IDX_I segment)
      _socket!.emit('subscribeMarket', {
        'instruments': [
          {'ExchangeSegment': 'IDX_I', 'SecurityId': '13'},
          {'ExchangeSegment': 'IDX_I', 'SecurityId': '25'},
          {'ExchangeSegment': 'IDX_I', 'SecurityId': '27'},
          {'ExchangeSegment': 'IDX_I', 'SecurityId': '51'},
          {'ExchangeSegment': 'IDX_I', 'SecurityId': '442'},
        ]
      });

      // Subscribe DB instruments (if already loaded)
      if (state.instrumentItems.isNotEmpty) {
        _subscribeItems(state.instrumentItems);
      }
    });

    on<SocketDisconnectedEvent>((event, emit) {
      emit(state.copyWith(isSocketConnected: false));
    });

    on<SubscribeMarketEvent>((event, emit) {
      _subscribeItems(state.instrumentItems);
    });

    on<SubscribeAdditionalItemsEvent>((event, emit) {
      final items = event.items.cast<MarketItem>();
      _subscribeItems(items);
      LivePriceService.instance.subscribe(
        items.map((i) => {
          'ExchangeSegment': _mapSegment(i.exchangeSegment),
          'SecurityId': i.securityId,
        }).toList(),
      );
    });

    on<DisconnectMarketEvent>((event, emit) {
      _socket?.emit('unsubscribeMarket', {});
      emit(state.copyWith(isSocketConnected: false));
    });

    // ── Init ──────────────────────────────────────────────────────────────
    add(const ChangeMarketTab(MarketTab.indices));
    add(const LoadPortfolioEvent());
    add(const LoadInstrumentsEvent(page: 1));

    _portfolioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const RefreshPortfolioSilentEvent());
    });

    // Bridge: direct Dhan WS prices → TerminalBloc state → BlocBuilder rebuilds
    LivePriceService.instance.onPriceUpdate = (secId, ltp) {
      if (!isClosed) add(LivePriceUpdateEvent(securityId: secId, ltp: ltp));
    };

    // Start direct Dhan WebSocket for fast prices
    LivePriceService.instance.start().then((_) {
      // Subscribe major indices immediately after connecting
      LivePriceService.instance.subscribe([
        {'ExchangeSegment': 'IDX_I', 'SecurityId': '13'},   // NIFTY 50
        {'ExchangeSegment': 'IDX_I', 'SecurityId': '25'},   // BANKNIFTY
        {'ExchangeSegment': 'IDX_I', 'SecurityId': '27'},   // FINNIFTY
        {'ExchangeSegment': 'IDX_I', 'SecurityId': '51'},   // SENSEX
        {'ExchangeSegment': 'IDX_I', 'SecurityId': '442'},  // MIDCAPNIFTY
      ]);
    });

    _connectSocket();
  }

  void _connectSocket() {
    _socket = socket_io.io(
      ApiHelper.baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket] ✅ Connected to ${ApiHelper.baseUrl}');
      if (!isClosed) add(const SocketConnectedEvent());
    });

    _socket!.on('priceUpdate', (data) {
      if (isClosed) return;
      try {
        final securityId = data['securityId']?.toString() ?? '';
        final ltp = (data['ltp'] as num?)?.toDouble() ?? 0.0;
        print('[Socket] 📈 priceUpdate — securityId=$securityId ltp=$ltp');
        if (securityId.isNotEmpty) {
          add(LivePriceUpdateEvent(
            securityId: securityId,
            ltp: ltp,
            open: (data['open'] as num?)?.toDouble() ?? 0.0,
            close: (data['close'] as num?)?.toDouble() ?? 0.0,
            high: (data['high'] as num?)?.toDouble() ?? 0.0,
            low: (data['low'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      } catch (e) {
        print('[Socket] ❌ priceUpdate parse error: $e');
      }
    });

    _socket!.onDisconnect((_) {
      print('[Socket] 🔌 Disconnected');
      if (!isClosed) add(const SocketDisconnectedEvent());
    });

    _socket!.onError((err) => print('[Socket] ❌ Error: $err'));
    _socket!.onConnectError((err) => print('[Socket] ❌ Connect error: $err'));

    print('[Socket] Connecting to ${ApiHelper.baseUrl}...');
    _socket!.connect();
  }

  void _subscribeItems(List<MarketItem> items) {
    if (_socket == null || items.isEmpty) return;
    // Note: no _socket!.connected check — socket_io buffers events automatically

    final instruments = items
        .where((i) => i.securityId.isNotEmpty)
        .map((i) => {
              // Use exchange + segment for correct BSE_FNO vs NSE_FNO mapping
              'ExchangeSegment': _resolveSegment(i.exchange, i.exchangeSegment),
              'SecurityId': i.securityId,
            })
        .toList();

    if (instruments.isEmpty) return;

    const batchSize = 100;
    for (var i = 0; i < instruments.length; i += batchSize) {
      final batch = instruments.sublist(
        i,
        (i + batchSize) > instruments.length ? instruments.length : i + batchSize,
      );
      print('[Socket] 📤 subscribeMarket — ${batch.length} instruments');
      _socket!.emit('subscribeMarket', {'instruments': batch});
    }
  }

  // Maps raw DB segment (D/E) + exchange → correct Dhan ExchangeSegment
  String _resolveSegment(String exchange, String segment) {
    final exch = exchange.toUpperCase();
    final seg  = segment.toUpperCase();
    if (seg == 'NSE_FNO' || seg == 'BSE_FNO' ||
        seg == 'NSE_EQ'  || seg == 'BSE_EQ'  || seg == 'IDX_I') { return seg; }
    if (seg == 'D' && exch == 'BSE') return 'BSE_FNO';
    if (seg == 'D') return 'NSE_FNO';
    if (seg == 'E' && exch == 'BSE') return 'BSE_EQ';
    if (seg == 'E') return 'NSE_EQ';
    return segment;
  }

  String _mapSegment(String segment) {
    // Backend now returns correct segment (BSE_FNO, NSE_FNO etc.) directly
    // This map handles any legacy 'D'/'E' codes just in case
    const map = {
      'D': 'NSE_FNO',
      'E': 'NSE_EQ',
      'NSE_FNO': 'NSE_FNO',
      'BSE_FNO': 'BSE_FNO',
      'NSE_EQ':  'NSE_EQ',
      'BSE_EQ':  'BSE_EQ',
      'NSE_CURR': 'NSE_CURR',
      'MCX_COMM': 'MCX_COMM',
    };
    return map[segment] ?? segment;
  }

  @override
  Future<void> close() {
    _portfolioTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    LivePriceService.instance.onPriceUpdate = null;
    return super.close();
  }

  Future<void> _doFetchPortfolio(Emitter<TerminalState> emit) async {
    try {
      final positions = await PortfolioRepository.instance.getPortfolio();
      final totalPnL = positions.fold(0.0, (sum, item) => sum + item.pnl);
      emit(state.copyWith(
        portfolioPositions: positions,
        portfolioLoading: false,
        totalPortfolioPnL: totalPnL,
      ));
    } on UnauthorizedException {
      _portfolioTimer?.cancel();
      _portfolioTimer = null;
      if (!NavigatorService.isSessionEnded) {
        NavigatorService.markSessionEnded();
        await SharedPrefsHelper().clearUserData();
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginPage);
      }
    } catch (_) {
      emit(state.copyWith(portfolioLoading: false));
    }
  }
}
