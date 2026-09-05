import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_event.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/chart_data.dart';
import '../../../data/services/live_price_service.dart';
import '../../../data/models/constituent_stock.dart';
import '../../../data/models/news_model.dart';

class StockDetailsBloc extends Bloc<StockDetailsEvent, StockDetailsState> {
  final SharedPrefsHelper _prefs = SharedPrefsHelper();
  Timer? _expiryDebounce;

  StockDetailsBloc() : super(const StockDetailsState()) {
    on<ChangeDetailsTab>((event, emit) {
      emit(state.copyWith(marketTab: event.tab));
      if (event.tab == DetailsTab.options) {
        // Guard: skip if a load is already in flight to prevent duplicate Dhan calls
        if (state.isOptionChainLoading) return;
        if (state.availableExpiries.isEmpty) {
          add(LoadExpiryDatesEvent());
        } else if (state.optionStrikes.isEmpty && state.selectedExpiry.isNotEmpty) {
          add(LoadOptionChainEvent(state.selectedExpiry));
        }
      }
    });

    on<InitializeWithPosition>((event, emit) {
      // Reset all data for fresh load
      emit(
        state.copyWith(
          position: event.position,
          marketItem: null,
          candles: [],
          chartData: [],
          relatedFNO: [],
          optionStrikes: [],
          isChartLoading: false,
          duration: ChartDuration.d1,
        ),
      );
      add(const LoadChartEvent(ChartDuration.d1));
      add(LoadRelatedFNOEvent());
    });

    on<InitializeWithMarketItem>((event, emit) {
      emit(
        state.copyWith(
          marketItem: event.item,
          position: null,
          candles: [],
          chartData: [],
          relatedFNO: [],
          optionStrikes: [],
          availableExpiries: [],
          selectedExpiry: '',
          lastPrice: 0,
          optionChainError: '',
          isChartLoading: false,
          duration: ChartDuration.d1,
        ),
      );
      add(const LoadChartEvent(ChartDuration.d1));
      add(LoadRelatedFNOEvent());
      // Option chain is loaded on-demand when user taps Options tab — not pre-loaded here

      // Subscribe this stock to live price feed immediately
      final seg = _getApiSegment(
        event.item.exchange,
        event.item.exchangeSegment,
      );
      LivePriceService.instance.subscribe([
        {'ExchangeSegment': seg, 'SecurityId': event.item.securityId},
      ]);
    });

    on<ChangeDuration>((event, emit) {
      add(LoadChartEvent(event.duration));
    });

    on<ChangeInterval>((event, emit) {
      emit(state.copyWith(chartInterval: event.interval));
      add(const LoadChartEvent(ChartDuration.d1));
    });

    // ── Real chart data — instant cache then background intraday overlay ──────
    on<LoadChartEvent>((event, emit) async {
      emit(state.copyWith(isChartLoading: true, duration: event.duration));
      try {
        final secId = state.securityId;
        final segment = state.exchangeSegment;

        if (secId.isEmpty) {
          emit(state.copyWith(isChartLoading: false));
          return;
        }

        final now        = DateTime.now();
        final tradingDay = _lastTradingDay();
        final exchange   = state.marketItem?.exchange ?? '';
        final apiSegment = _getApiSegment(exchange, segment);
        final instrument = _getInstrumentType(apiSegment);
        final isIndex    = instrument == 'INDEX';
        final maxCode    = isIndex ? 0 : 3;
        final interval   = state.chartInterval;

        // Phase 1: load cached daily candles and render immediately
        List<ChartCandle> candles = [];
        try {
          final cachedResp = await ApiHelper.post(ApiEndpoints.historicalCachedApi, {
            'securityId': secId,
            'exchangeSegment': apiSegment,
            'instrument': instrument,
          });
          if (cachedResp != null && cachedResp['status'] == true) {
            candles = ChartCandle.fromApiResponse(cachedResp['data'] ?? {});
          }
        } catch (e) {
          print('[Chart] cached API error: $e');
        }

        // Fallback: direct Dhan API if no cache at all (first-time only)
        if (candles.isEmpty) {
          candles = await _smartHistoricalFetch(
            secId: secId, apiSegment: apiSegment,
            instrument: instrument, maxCode: maxCode,
            fromDate: _fmt(now.subtract(const Duration(days: 365))),
            toDateStart: tradingDay,
          );
        }

        // Emit daily candles immediately — chart is visible now
        if (candles.isNotEmpty) {
          emit(state.copyWith(
            isChartLoading: false,
            candles: candles,
            chartData: candles.map((c) => c.close).toList(),
          ));
        }

        // Phase 2: overlay intraday history if a minute interval is selected.
        // Pulls a real multi-day window from the DB-backed intraday cache
        // (populated from Dhan's charts/intraday, stored server-side) instead
        // of a live, today-only Dhan passthrough — this is what actually makes
        // intraday history available across days, not just "today".
        if (interval > 0) {
          final windowStart = now.subtract(const Duration(days: 30));
          final fromEpoch = windowStart.toUtc().millisecondsSinceEpoch ~/ 1000;
          final toEpoch   = now.toUtc().millisecondsSinceEpoch ~/ 1000;

          List<ChartCandle> intraday = [];
          try {
            final resp = await ApiHelper.post(ApiEndpoints.intradayCachedApi, {
              'securityId': secId,
              'exchangeSegment': apiSegment,
              'instrument': instrument,
              'interval': interval.toString(),
              'fromDate': fromEpoch.toString(),
              'toDate': toEpoch.toString(),
            });
            if (resp != null && resp['status'] == true) {
              intraday = ChartCandle.fromApiResponse(resp['data'] ?? {});
            }
          } catch (_) {}

          if (intraday.isNotEmpty) {
            final todayStr = _fmt(now);
            var dailyOpen = 0.0;
            for (final c in intraday) {
              if (_fmt(c.time) == todayStr) { dailyOpen = c.open; break; }
            }
            if (dailyOpen == 0.0) {
              for (final c in candles) {
                if (_fmt(c.time) == todayStr) { dailyOpen = c.open; break; }
              }
            }
            if (dailyOpen == 0.0) {
              for (int code = 0; code <= maxCode && dailyOpen == 0.0; code++) {
                try {
                  final todayResp = await ApiHelper.post(ApiEndpoints.historicalApi, {
                    'securityId': secId,
                    'exchangeSegment': apiSegment,
                    'instrument': instrument,
                    'expiryCode': code,
                    'oi': false,
                    'fromDate': _fmt(now),
                    'toDate': _fmt(now),
                  });
                  if (todayResp != null && todayResp['status'] == true) {
                    final tc = ChartCandle.fromApiResponse(todayResp['data'] ?? {});
                    if (tc.isNotEmpty) dailyOpen = tc.first.open;
                  }
                } catch (_) {}
              }
            }
            // Replace daily candles inside the fetched intraday window with
            // the intraday candles themselves — ascending order preserved.
            final windowStartStr = _fmt(windowStart);
            final withoutWindow = candles.where((c) => _fmt(c.time).compareTo(windowStartStr) < 0).toList();
            final finalCandles = [...withoutWindow, ...intraday]
              ..sort((a, b) => a.time.compareTo(b.time));
            emit(state.copyWith(
              isChartLoading: false,
              candles: finalCandles,
              chartData: finalCandles.map((c) => c.close).toList(),
              dailyOpen: dailyOpen,
              hasMoreIntradayHistory: true,
            ));
          }
        }

        // If nothing loaded at all, clear loading state
        if (candles.isEmpty) {
          emit(state.copyWith(isChartLoading: false));
        }
      } catch (e) {
        print('[Chart] ERROR: $e');
        emit(state.copyWith(isChartLoading: false));
      }
    });

    // ── Progressive intraday history — triggered by panning back past the
    // currently-loaded window in OverviewChart ────────────────────────────
    on<LoadOlderCandlesEvent>((event, emit) async {
      if (state.isLoadingOlderCandles || !state.hasMoreIntradayHistory) return;
      if (state.candles.isEmpty || state.chartInterval <= 0) return;

      emit(state.copyWith(isLoadingOlderCandles: true));
      try {
        final secId      = state.securityId;
        final exchange    = state.marketItem?.exchange ?? '';
        final apiSegment  = _getApiSegment(exchange, state.exchangeSegment);
        final instrument  = _getInstrumentType(apiSegment);
        final interval    = state.chartInterval;

        const backfillFloorDays = 180;
        const windowDays = 30;
        const maxEmptySteps = 4; // rides out weekend/holiday clusters

        final floor = DateTime.now().subtract(const Duration(days: backfillFloorDays));
        DateTime windowEnd = state.candles.first.time.subtract(const Duration(seconds: 1));

        List<ChartCandle> older = [];
        int emptySteps = 0;
        while (emptySteps < maxEmptySteps && windowEnd.isAfter(floor)) {
          final rawStart = windowEnd.subtract(const Duration(days: windowDays));
          final clampedStart = rawStart.isBefore(floor) ? floor : rawStart;
          final fromEpoch = clampedStart.toUtc().millisecondsSinceEpoch ~/ 1000;
          final toEpoch   = windowEnd.toUtc().millisecondsSinceEpoch ~/ 1000;

          List<ChartCandle> fetched = [];
          try {
            final resp = await ApiHelper.post(ApiEndpoints.intradayCachedApi, {
              'securityId': secId,
              'exchangeSegment': apiSegment,
              'instrument': instrument,
              'interval': interval.toString(),
              'fromDate': fromEpoch.toString(),
              'toDate': toEpoch.toString(),
            });
            if (resp != null && resp['status'] == true) {
              fetched = ChartCandle.fromApiResponse(resp['data'] ?? {});
            }
          } catch (_) {}

          if (fetched.isNotEmpty) { older = fetched; break; }
          emptySteps++;
          if (!clampedStart.isAfter(floor)) break; // hit the retention floor
          windowEnd = clampedStart.subtract(const Duration(seconds: 1));
        }

        if (older.isEmpty) {
          emit(state.copyWith(isLoadingOlderCandles: false, hasMoreIntradayHistory: false));
          return;
        }

        // Merge + dedupe by timestamp + re-sort ascending
        final merged = <int, ChartCandle>{};
        for (final c in older) { merged[c.time.millisecondsSinceEpoch] = c; }
        for (final c in state.candles) { merged[c.time.millisecondsSinceEpoch] = c; }
        final sorted = merged.values.toList()..sort((a, b) => a.time.compareTo(b.time));

        emit(state.copyWith(
          isLoadingOlderCandles: false,
          candles: sorted,
          chartData: sorted.map((c) => c.close).toList(),
        ));
      } catch (e) {
        print('[Chart] LoadOlderCandles ERROR: $e');
        emit(state.copyWith(isLoadingOlderCandles: false));
      }
    });

    // ── Option chain from Dhan API ──────────────────────────────────────────
    on<LoadOptionChainEvent>((event, emit) async {
      emit(state.copyWith(isOptionChainLoading: true, optionChainError: ''));
      try {
        // Use SELF market token (same as live price feed) for option chain
        final selfToken = LivePriceService.instance.marketAccessToken;
        final accessToken = selfToken.isNotEmpty
            ? selfToken
            : (await _prefs.getAccessToken() ?? '');
        final secId = state.securityId;
        final segment = state.exchangeSegment;

        if (accessToken.isEmpty || secId.isEmpty) {
          emit(
            state.copyWith(
              isOptionChainLoading: false,
              optionChainError: 'No credentials',
            ),
          );
          return;
        }

        // Determine underlying for option chain (NSE/BSE, not IDX_I)
        final exchange = state.marketItem?.exchange ?? '';
        final underlyingSeg = _getUnderlyingSegment(segment, exchange);

        // Expiry: event → state → MarketItem.expiry
        String expiry = event.expiry.isNotEmpty
            ? event.expiry
            : state.selectedExpiry.isNotEmpty
            ? state.selectedExpiry
            : state.marketItem?.expiry ?? '';

        // Map option name → underlying index security ID
        final underlyingScrip = _getUnderlyingScrip(state.displayName, secId);

        // Format expiry as YYYY-MM-DD
        final expiryFormatted = _formatExpiry(expiry);

        // Update selectedExpiry in state so the picker shows it
        if (state.selectedExpiry != expiryFormatted &&
            expiryFormatted.isNotEmpty) {
          emit(state.copyWith(selectedExpiry: expiryFormatted));
        }

        print('[OptionChain] Request:');
        print('  secId           = $secId');
        print('  displayName     = ${state.displayName}');
        print(
          '  underlyingScrip = $underlyingScrip  underlyingSeg = $underlyingSeg',
        );
        print('  expiry          = $expiryFormatted');
        print(
          '  tokenType       = ${selfToken.isNotEmpty ? 'SELF' : 'PARTNER'}',
        );

        var resp = await ApiHelper.post(ApiEndpoints.optionChainApi, {
          'dhanAccessToken': accessToken,
          'UnderlyingScrip': underlyingScrip,
          'UnderlyingSeg': underlyingSeg,
          'Expiry': expiryFormatted,
        });

        var rawMsg = resp?['message'];
        var respMsg = rawMsg is String ? rawMsg : rawMsg?.toString() ?? '';
        print('[OptionChain] Response: status=${resp?['status']} msg=$respMsg');

        // ── Retry up to 3 times on Dhan 805 "Too many requests" ─────────────
        if (resp != null && resp['status'] == false && respMsg.contains('805')) {
          const delays = [2000, 3000, 5000]; // ms between retries
          Map<String, dynamic>? successResp;
          for (int attempt = 0; attempt < delays.length; attempt++) {
            print('[OptionChain] 805 rate limit — retry ${attempt + 1} in ${delays[attempt]}ms...');
            await Future.delayed(Duration(milliseconds: delays[attempt]));
            final retryResp = await ApiHelper.post(ApiEndpoints.optionChainApi, {
              'dhanAccessToken': accessToken,
              'UnderlyingScrip': underlyingScrip,
              'UnderlyingSeg': underlyingSeg,
              'Expiry': expiryFormatted,
            });
            rawMsg  = retryResp?['message'];
            respMsg = rawMsg is String ? rawMsg : rawMsg?.toString() ?? '';
            print('[OptionChain] Retry ${attempt + 1} status=${retryResp?['status']} msg=$respMsg');
            if (retryResp != null && retryResp['status'] == true) {
              successResp = retryResp;
              break;
            }
            if (retryResp == null || !respMsg.contains('805')) break; // non-rate-limit error — stop retrying
          }
          if (successResp != null) {
            // Use successResp below by falling through — re-assign resp alias
            resp = successResp;
            rawMsg  = resp['message'];
            respMsg = rawMsg is String ? rawMsg : rawMsg?.toString() ?? '';
          } else {
            emit(state.copyWith(
              isOptionChainLoading: false,
              optionChainError: 'Too many requests to Dhan. Please wait a moment and try again.',
            ));
            return;
          }
        }

        if (resp != null && resp['status'] == true) {
          final oc =
              resp['data']?['data']?['oc'] as Map<String, dynamic>? ?? {};
          final lastPrice =
              (resp['data']?['data']?['last_price'] as num?)?.toDouble() ?? 0;

          final strikes = oc.entries.map((e) {
            final strike = double.tryParse(e.key) ?? 0;
            final ce = e.value['ce'] as Map<String, dynamic>?;
            final pe = e.value['pe'] as Map<String, dynamic>?;
            return OptionStrike(strike: strike, ce: ce, pe: pe);
          }).toList()..sort((a, b) => a.strike.compareTo(b.strike));

          emit(
            state.copyWith(
              isOptionChainLoading: false,
              lastPrice: lastPrice,
              optionStrikes: strikes,
            ),
          );

          // Subscribe all CE + PE security IDs for live prices
          final instruments = <Map<String, String>>[];
          for (final s in strikes) {
            final ceId = s.ce?['security_id']?.toString();
            final peId = s.pe?['security_id']?.toString();
            if (ceId != null && ceId.isNotEmpty) {
              instruments.add({
                'ExchangeSegment': 'NSE_FNO',
                'SecurityId': ceId,
              });
            }
            if (peId != null && peId.isNotEmpty) {
              instruments.add({
                'ExchangeSegment': 'NSE_FNO',
                'SecurityId': peId,
              });
            }
          }
          if (instruments.isNotEmpty) {
            print(
              '[OptionChain] Subscribing ${instruments.length} CE+PE security IDs for live prices',
            );
            LivePriceService.instance.subscribe(instruments);
          }
        } else {
          emit(
            state.copyWith(
              isOptionChainLoading: false,
              optionChainError: respMsg.isNotEmpty
                  ? respMsg
                  : 'Failed to load option chain',
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            isOptionChainLoading: false,
            optionChainError: e.toString(),
          ),
        );
      }
    });

    on<ChangeOptionExpiryEvent>((event, emit) {
      // Clear previous data immediately so UI shows loading
      emit(state.copyWith(
        selectedExpiry: event.expiry,
        optionStrikes: [],
        optionChainError: '',
      ));
      // Debounce: cancel pending timer then wait 600ms before hitting Dhan
      _expiryDebounce?.cancel();
      _expiryDebounce = Timer(const Duration(milliseconds: 600), () {
        if (!isClosed) add(LoadOptionChainEvent(event.expiry));
      });
    });

    // ── Related F&O instruments ────────────────────────────────────────────
    on<LoadRelatedFNOEvent>((event, emit) async {
      try {
        final secId = state.securityId;
        final name = state.displayName;
        if (secId.isEmpty || name.isEmpty) return;

        // Use symbol field when available (avoids "MIDCAP NIFTY" → "MIDCAP" split issue)
        final symbol = state.marketItem?.symbol ?? '';
        final underlying = symbol.isNotEmpty ? symbol : name.split(' ').first;
        // Extract expiry from name (e.g. "19 MAY" -> find in DB by date)
        final strike = state.marketItem?.strikePrice ?? '0';
        // Extract expiry date
        final expiry =
            state.marketItem?.expiry?.toString().split('T').first ?? '';

        final params = StringBuffer(
          '?underlyingSymbol=${Uri.encodeComponent(underlying)}',
        );
        if (expiry.isNotEmpty) params.write('&expiry=$expiry');
        if (strike != '0') params.write('&strike=$strike');

        final resp = await ApiHelper.get(
          '${ApiEndpoints.relatedFNOApi}$params',
        );
        if (resp != null && resp['status'] == true) {
          final List data = resp['data'] ?? [];
          final items = data
              .map<MarketItem>(
                (e) => MarketItem(
                  securityId: e['securityId']?.toString() ?? '',
                  name: e['name'] ?? '',
                  symbol: e['name'] ?? '',
                  exchangeSegment: e['exchangeSegment'] ?? '',
                  exchange: e['exchange'] ?? '',
                  lotSize: e['lotSize']?.toString() ?? '1',
                  isUp: true,
                  strikePrice: e['strikePrice']?.toString(),
                  optionType: e['optionType']?.toString(),
                  expiry: e['expiry']?.toString(),
                ),
              )
              .where((i) => i.securityId != secId)
              .take(4)
              .toList();

          emit(state.copyWith(relatedFNO: items));

          // Subscribe to LivePriceService for live prices
          LivePriceService.instance.subscribe(
            items
                .map(
                  (i) => {
                    'ExchangeSegment': i.exchangeSegment,
                    'SecurityId': i.securityId,
                  },
                )
                .toList(),
          );
        }
      } catch (_) {}
    });

    // ── Load available expiry dates for current underlying ─────────────────
    on<LoadExpiryDatesEvent>((event, emit) async {
      try {
        final name = state.displayName;
        if (name.isEmpty) return;
        final underlying = _getUnderlyingName(name, state.marketItem?.symbol ?? '');

        final resp = await ApiHelper.get(
          '${ApiEndpoints.expiryDatesApi}?underlyingSymbol=${Uri.encodeComponent(underlying)}',
        );

        print(resp);
        print("dhhjadgaghshdsad");
        if (resp != null && resp['status'] == true) {
          final List raw = resp['data'] ?? [];
          final dates = raw.map((e) => e.toString()).toList();
          emit(state.copyWith(availableExpiries: dates));

          // Auto-select first date and load chain only when not already loading
          if (dates.isNotEmpty && state.selectedExpiry.isEmpty && !state.isOptionChainLoading) {
            final expiry = dates.first;
            emit(state.copyWith(selectedExpiry: expiry));
            add(LoadOptionChainEvent(expiry));
          }
        }
      } catch (_) {}
    });

    on<ChangeConstituentDuration>((event, emit) {
      emit(state.copyWith(selectedDropdown: event.duration));
      add(LoadConstituents());
    });

    on<LoadConstituents>((event, emit) {
      emit(
        state.copyWith(
          constituents: [
            const ConstituentStock(
              name: "Reliance Industries",
              exchange: "NSE",
              price: "35.00",
              weekLow: "1517.60",
              changePercent: "1.2",
              volume: "4901",
              isUp: true,
            ),
            const ConstituentStock(
              name: "TCS",
              exchange: "NSE",
              price: "42.50",
              weekLow: "3600.25",
              changePercent: "0.8",
              volume: "4500",
              isUp: true,
            ),
            const ConstituentStock(
              name: "Infosys",
              exchange: "NSE",
              price: "28.75",
              weekLow: "1450.80",
              changePercent: "-0.8",
              volume: "3601",
              isUp: false,
            ),
            const ConstituentStock(
              name: "HDFC Bank",
              exchange: "NSE",
              price: "50.00",
              weekLow: "1602.90",
              changePercent: "-0.5",
              volume: "6000",
              isUp: false,
            ),
          ],
        ),
      );
    });

    on<LoadNews>((event, emit) async {
      final secId  = state.securityId;
      final symbol = state.displayName;
      if (secId.isEmpty) return;

      emit(state.copyWith(isNewsLoading: true, newsError: ''));
      try {
        final resp = await ApiHelper.post(ApiEndpoints.newsHeadlineApi, {
          'securityId': secId,
          'symbol': symbol,
        });

        final rawList = resp?['news'] as List? ?? [];
        final newsList = rawList
            .map((e) => StockNews.fromJson(e as Map<String, dynamic>))
            .where((n) => n.title.isNotEmpty)
            .toList();

        emit(state.copyWith(
          isNewsLoading: false,
          newsError: '',
          news: newsList,
        ));
      } catch (e) {
        emit(state.copyWith(
          isNewsLoading: false,
          newsError: 'Failed to load news',
        ));
      }
    });

    add(const ChangeDetailsTab(DetailsTab.overview));
    add(LoadConstituents());
    add(LoadNews());
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Returns the most recent trading day (Mon–Fri).
  // Returns the most recent weekend-free day (Mon–Fri).
  // Holidays are handled separately by _smartHistoricalFetch.
  DateTime _lastTradingDay() {
    var d = DateTime.now();
    if (d.weekday == DateTime.saturday) return d.subtract(const Duration(days: 1));
    if (d.weekday == DateTime.sunday)   return d.subtract(const Duration(days: 2));
    return d;
  }

  // Skips Saturday / Sunday when stepping backwards.
  DateTime _prevWeekday(DateTime d) {
    var prev = d.subtract(const Duration(days: 1));
    if (prev.weekday == DateTime.saturday) prev = prev.subtract(const Duration(days: 1));
    if (prev.weekday == DateTime.sunday)   prev = prev.subtract(const Duration(days: 2));
    return prev;
  }

  // Fetches historical candles, automatically stepping toDate backward by
  // 1 trading day at a time (max 4 retries) when Dhan returns empty data.
  // This handles market holidays without a hardcoded holiday calendar:
  //   - today (might be holiday) → empty
  //   - yesterday (last trading day) → returns data  ✓
  Future<List<ChartCandle>> _smartHistoricalFetch({
    required String secId,
    required String apiSegment,
    required String instrument,
    required int maxCode,
    required String fromDate,
    required DateTime toDateStart,
  }) async {
    DateTime toDate = toDateStart;
    for (int attempt = 0; attempt < 5; attempt++) {
      for (int code = 0; code <= maxCode; code++) {
        final resp = await ApiHelper.post(ApiEndpoints.historicalApi, {
          'securityId': secId,
          'exchangeSegment': apiSegment,
          'instrument': instrument,
          'expiryCode': code,
          'oi': false,
          'fromDate': fromDate,
          'toDate': _fmt(toDate),
        });
        print('[Chart] hist attempt=$attempt code=$code toDate=${_fmt(toDate)} status=${resp?['status']} msg=${resp?['message']}');
        if (resp != null && resp['status'] == true) {
          final candles = ChartCandle.fromApiResponse(resp['data'] ?? {});
          if (candles.isNotEmpty) {
            print('[Chart] hist got ${candles.length} candles attempt=$attempt code=$code');
            return candles;
          }
        }
      }
      // No data for this toDate — step back one trading day (handles holidays)
      toDate = _prevWeekday(toDate);
    }
    return [];
  }


  // Extracts the underlying index name for the expiry dates API.
  // e.g. "NIFTY 26 MAY 25500 CALL" → "NIFTY", "BANKNIFTY" → "BANKNIFTY"
  String _getUnderlyingName(String displayName, String symbol) {
    const knownIndices = ['NIFTY', 'BANKNIFTY', 'FINNIFTY', 'MIDCAPNIFTY', 'SENSEX', 'BANKEX'];
    // If symbol is already one of the known index names, use it directly
    if (knownIndices.contains(symbol.toUpperCase())) return symbol.toUpperCase();
    // Derive from display name
    final n = displayName.toUpperCase();
    if (n.contains('BANKNIFTY') || n.contains('BANK NIFTY')) return 'BANKNIFTY';
    if (n.contains('FINNIFTY')  || n.contains('FIN NIFTY'))  return 'FINNIFTY';
    if (n.contains('MIDCAPNIFTY') || n.contains('MIDCAP'))   return 'MIDCAPNIFTY';
    if (n.contains('SENSEX'))                                  return 'SENSEX';
    if (n.contains('BANKEX'))                                  return 'BANKEX';
    if (n.contains('NIFTY'))                                   return 'NIFTY';
    // Fallback: first word of display name
    return displayName.split(' ').first.toUpperCase();
  }

  // Maps raw DB segment (D/E) + exchange → proper Dhan API segment
  String _getApiSegment(String exchange, String segment) {
    final exch = exchange.toUpperCase();
    final seg = segment.toUpperCase();
    // Already a proper segment — return as-is
    if (seg == 'NSE_FNO' ||
        seg == 'BSE_FNO' ||
        seg == 'NSE_EQ' ||
        seg == 'BSE_EQ' ||
        seg == 'IDX_I') {
      return seg;
    }
    // Raw DB codes
    if (seg == 'D' && exch == 'NSE') return 'NSE_FNO';
    if (seg == 'D' && exch == 'BSE') return 'BSE_FNO';
    if (seg == 'D') return 'NSE_FNO'; // default for D
    if (seg == 'E' && exch == 'NSE') return 'NSE_EQ';
    if (seg == 'E' && exch == 'BSE') return 'BSE_EQ';
    if (seg == 'E') return 'NSE_EQ'; // default for E
    return segment;
  }

  String _getInstrumentType(String segment) {
    final s = segment.toUpperCase();
    if (s == 'NSE_EQ' || s == 'BSE_EQ' || s == 'E') return 'EQUITY';
    if (s == 'IDX_I') return 'INDEX';
    if (s == 'NSE_FNO' || s == 'BSE_FNO' || s == 'D') return 'OPTIDX';
    return 'EQUITY';
  }

  // Dhan option chain API needs UnderlyingSeg = 'NSE' or 'BSE' (not 'IDX_I')
  String _getUnderlyingSegment(String segment, String exchange) {
    final s = segment.toUpperCase();
    final exch = exchange.toUpperCase();

    // INDEX
    if (s == 'IDX_I') return 'IDX_I';

    // EQUITY
    if (s == 'NSE_EQ') return 'NSE_EQ';
    if (s == 'BSE_EQ') return 'BSE_EQ';

    // FNO
    if (s == 'NSE_FNO') return 'IDX_I';
    if (s == 'BSE_FNO') return 'IDX_I';

    // Raw DB values
    if (s == 'D') return 'IDX_I';
    if (s == 'E') return exch == 'BSE' ? 'BSE_EQ' : 'NSE_EQ';

    return 'IDX_I';
  }

  // Map option display name → underlying index security ID
  // Used for option chain API (UnderlyingScrip must be the INDEX, not the option)
  dynamic _getUnderlyingScrip(String displayName, String fallbackSecId) {
    final name = displayName.toUpperCase();
    if (name.contains('BANKNIFTY') || name.contains('BANK NIFTY')) return 25;
    if (name.contains('FINNIFTY') || name.contains('FIN NIFTY')) return 27;
    if (name.contains('MIDCAPNIFTY') || name.contains('MIDCAP')) return 442;
    if (name.contains('SENSEX')) return 51;
    if (name.contains('BANKEX')) return 51; // BSE
    if (name.contains('NIFTY')) return 13;
    // Fallback: use the securityId as-is (might work for equity options)
    return int.tryParse(fallbackSecId) ?? fallbackSecId;
  }

  // Format expiry date to YYYY-MM-DD for Dhan API
  String _formatExpiry(String expiry) {
    if (expiry.isEmpty) return '';
    // Already YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(expiry)) return expiry;
    // Remove time part if present (e.g. "2026-05-19T00:00:00.000")
    if (expiry.contains('T')) return expiry.split('T').first;
    // Remove time part if space-separated
    if (expiry.contains(' ')) return expiry.split(' ').first;
    return expiry;
  }

  @override
  Future<void> close() {
    _expiryDebounce?.cancel();
    return super.close();
  }
}
