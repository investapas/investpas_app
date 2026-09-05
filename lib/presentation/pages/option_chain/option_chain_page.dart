import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_bloc.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_state.dart';
import 'package:investapas/presentation/bloc/option_chain/option_change_event.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../Widgets/live_price_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../../data/services/live_price_service.dart';
import '../trade_sheet/trade_sheet.dart';
import '../../bloc/stock_details/stock_details_bloc.dart';
import '../../bloc/stock_details/stock_details_event.dart';
import '../../bloc/stock_details/stock_details_state.dart';

// ── Layout constants ──────────────────────────────────────────────────────
const double _kStrikeW  = 90.0;
const double _kGreekW   = 68.0;   // Greek column width
const double _kGreekSideW = _kGreekW * 6;  // 408 — Gamma, Vega, Theta, Delta, IV, LTP
const double _kRowH     = 64.0;
const double _kHdrH     = 34.0;

// ── ATM-based display strike range (UI window only — never affects the full
// raw chain used for PCR/Max Pain/ATM IV, which always uses the complete
// list Dhan returns) ─────────────────────────────────────────────────────
// Strike COUNTS around ATM, not price limits — the window follows ATM as
// the underlying moves, instead of being pinned to a fixed price band.
class _StrikeDisplayRange {
  final int below;
  final int above;
  const _StrikeDisplayRange({required this.below, required this.above});
}

// NIFTY's 34-below/51-above matches the reference range (22150–26400
// around ATM 23850 @ 50pt strike spacing). Other indices don't have a
// confirmed reference yet, so they get a neutral symmetric default —
// tune per-underlying here as needed, never in the UI/render code.
const Map<String, _StrikeDisplayRange> _kStrikeDisplayRangeByUnderlying = {
  'NIFTY':       _StrikeDisplayRange(below: 34, above: 51),
  'BANKNIFTY':   _StrikeDisplayRange(below: 30, above: 30),
  'FINNIFTY':    _StrikeDisplayRange(below: 30, above: 30),
  'MIDCAPNIFTY': _StrikeDisplayRange(below: 30, above: 30),
  'SENSEX':      _StrikeDisplayRange(below: 30, above: 30),
  'BANKEX':      _StrikeDisplayRange(below: 30, above: 30),
};
const _StrikeDisplayRange _kDefaultStrikeDisplayRange =
    _StrikeDisplayRange(below: 30, above: 30);

// Same normalization order as StockDetailsBloc._getUnderlyingName — BANKNIFTY
// /FINNIFTY/MIDCAPNIFTY must be checked before the generic 'NIFTY' substring
// match, since they all contain "NIFTY" too.
String _normalizeUnderlying(String displayName) {
  final n = displayName.toUpperCase();
  if (n.contains('BANKNIFTY') || n.contains('BANK NIFTY')) return 'BANKNIFTY';
  if (n.contains('FINNIFTY')  || n.contains('FIN NIFTY'))  return 'FINNIFTY';
  if (n.contains('MIDCAPNIFTY') || n.contains('MIDCAP'))   return 'MIDCAPNIFTY';
  if (n.contains('SENSEX'))                                  return 'SENSEX';
  if (n.contains('BANKEX'))                                  return 'BANKEX';
  if (n.contains('NIFTY'))                                   return 'NIFTY';
  return n.split(' ').first;
}

class OptionChainPage extends StatefulWidget {
  const OptionChainPage({super.key});

  @override
  State<OptionChainPage> createState() => _OptionChainPageState();
}

class _OptionChainPageState extends State<OptionChainPage>
    with SingleTickerProviderStateMixin {
  // ── Scroll ──────────────────────────────────────────────────────────────
  final ScrollController _vertCtrl = ScrollController();
  // ONE master horizontal offset - both Call and Put use this
  final ValueNotifier<double> _masterHOff = ValueNotifier(0.0);
  // Drives momentum/fling deceleration after a Greeks horizontal drag release.
  late final AnimationController _flingCtrl =
      AnimationController.unbounded(vsync: this)
        ..addListener(() {
          final maxScroll = _maxHScroll(_kGreekSideW);
          final clamped = _flingCtrl.value.clamp(0.0, maxScroll);
          _masterHOff.value = clamped;
          if (clamped != _flingCtrl.value) _flingCtrl.stop();
        });

  // ── Trading state ────────────────────────────────────────────────────────
  String? _selectedSecId;
  String? _selectedName;
  String? _selectedExchangeSegment;
  bool _selectedIsCe = true;
  double? _selectedStrike;

  // ── Summary metrics ──────────────────────────────────────────────────────
  double _pcr = 0;
  String _maxPain = '—';
  String _atmIv = '—';
  String _ivLabel = '—';

  // ── Live auto-refresh ────────────────────────────────────────────────────
  // A single periodic timer, owned by this page's State (created once on
  // mount, cancelled on dispose) — switching between the OI/Greeks tabs does
  // NOT recreate this State (it's the same page, just a different
  // OptionChainBloc tab value), so no duplicate timers are possible.
  // 15s is conservative against Dhan's option-chain rate limit; the
  // `isOptionChainLoading` guard additionally prevents overlapping requests
  // if one fetch is still in flight (e.g. after a slow network response or
  // the existing 805-retry backoff) when the next tick fires.
  static const Duration _kRefreshInterval = Duration(seconds: 15);
  Timer? _refreshTimer;
  // Expiry we last auto-scrolled to ATM for — guards against re-scrolling
  // on every periodic refresh of the same expiry (see listener below).
  String? _scrolledForExpiry;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sBloc = context.read<StockDetailsBloc>();
      sBloc.add(LoadExpiryDatesEvent());
      if (sBloc.state.optionStrikes.isNotEmpty) {
        _computeSummary(sBloc.state);
        // Scroll against the same windowed list the table actually renders.
        _scrollToAtm(_displayStrikesFor(sBloc.state), sBloc.state.lastPrice);
      }
    });
    _refreshTimer = Timer.periodic(_kRefreshInterval, (_) {
      if (!mounted) return;
      final sBloc = context.read<StockDetailsBloc>();
      final s = sBloc.state;
      // Overlap guard: skip this tick if a fetch is already in flight, or
      // there's no expiry selected yet (nothing to refresh).
      if (s.isOptionChainLoading || s.selectedExpiry.isEmpty) return;
      sBloc.add(LoadOptionChainEvent(s.selectedExpiry));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _vertCtrl.dispose();
    _masterHOff.dispose();
    _flingCtrl.dispose();
    super.dispose();
  }

  // ── ATM-centered display window ──────────────────────────────────────────
  // Pure function, no side effects: slices the FULL raw strike list (from
  // Dhan, unfiltered) down to a strike-COUNT window around ATM for the UI
  // to render. This never touches `s.optionStrikes` itself — PCR/Max
  // Pain/ATM IV in _computeSummary always use the full list, independent
  // of whatever this returns.
  List<OptionStrike> _displayStrikesFor(StockDetailsState s) {
    final all = s.optionStrikes;
    if (all.isEmpty || s.lastPrice <= 0) return all;

    int atmIdx = 0;
    double minDiff = double.maxFinite;
    for (int i = 0; i < all.length; i++) {
      final d = (all[i].strike - s.lastPrice).abs();
      if (d < minDiff) { minDiff = d; atmIdx = i; }
    }

    final range = _kStrikeDisplayRangeByUnderlying[_normalizeUnderlying(s.displayName)]
        ?? _kDefaultStrikeDisplayRange;
    final start = max(0, atmIdx - range.below);
    final end = min(all.length - 1, atmIdx + range.above);
    return all.sublist(start, end + 1);
  }

  // ── Summary ──────────────────────────────────────────────────────────────
  void _computeSummary(StockDetailsState s) {
    if (s.optionStrikes.isEmpty) return;

    double totalCall = 0, totalPut = 0;
    for (final st in s.optionStrikes) {
      totalCall += (st.ce?['oi'] as num?)?.toDouble() ?? 0;
      totalPut  += (st.pe?['oi'] as num?)?.toDouble() ?? 0;
    }
    final pcr = totalCall > 0 ? totalPut / totalCall : 0.0;

    // Max Pain — computed BEFORE the debug log below so the log can report
    // the actual calculated value, not just its inputs.
    // Call Pain(K) = Σ CE_OI(i) × max(0, K − Strike(i))
    // Put  Pain(K) = Σ PE_OI(i) × max(0, Strike(i) − K)
    // Total Pain(K) = Call Pain(K) + Put Pain(K); Max Pain = argmin_K Total Pain(K)
    // Uses the full raw s.optionStrikes for both the candidate-K loop and
    // the inner per-strike loop — never the ATM-filtered display window.
    String maxPain = '—';
    double minPain = double.maxFinite;
    for (final target in s.optionStrikes) {
      final tv = target.strike;
      double pain = 0;
      for (final st in s.optionStrikes) {
        final sv = st.strike;
        if (tv > sv) pain += ((st.ce?['oi'] as num?)?.toDouble() ?? 0) * (tv - sv);
        if (tv < sv) pain += ((st.pe?['oi'] as num?)?.toDouble() ?? 0) * (sv - tv);
      }
      if (pain < minPain) { minPain = pain; maxPain = target.strike.toStringAsFixed(0); }
    }

    // ── Debug snapshot: PCR + Max Pain, both from the full raw chain ────────
    // ignore: avoid_print
    print('[OptionChainDebug] ${{
      'underlying': s.displayName,
      'expiry': s.selectedExpiry,
      'timestamp': DateTime.now().toIso8601String(),
      'strikeCount': s.optionStrikes.length,
      'totalCallOI': totalCall,
      'totalPutOI': totalPut,
      'pcr': pcr,
      'maxPain': maxPain,
    }}');
    // ignore: avoid_print
    print('[OptionChainDebug] per-strike OI (strike | CE OI | PE OI):');
    for (final st in s.optionStrikes) {
      final ceOi = (st.ce?['oi'] as num?)?.toDouble() ?? 0;
      final peOi = (st.pe?['oi'] as num?)?.toDouble() ?? 0;
      // ignore: avoid_print
      print('  ${st.strike.toStringAsFixed(0)} | $ceOi | $peOi');
    }

    // [OptionChainRangeDebug] — confirms the full raw chain is retained
    // (used for PCR/Max Pain/ATM IV above, unaffected by the display
    // window) while the UI renders only the ATM-centered slice below.
    final displayStrikes = _displayStrikesFor(s);
    // ignore: avoid_print
    print('[OptionChainRangeDebug] '
        'rawStrikeCount=${s.optionStrikes.length} '
        'rawFirst=${s.optionStrikes.isNotEmpty ? s.optionStrikes.first.strike : null} '
        'rawLast=${s.optionStrikes.isNotEmpty ? s.optionStrikes.last.strike : null} '
        'displayStrikeCount=${displayStrikes.length} '
        'displayFirst=${displayStrikes.isNotEmpty ? displayStrikes.first.strike : null} '
        'displayLast=${displayStrikes.isNotEmpty ? displayStrikes.last.strike : null}');

    // ATM IV
    String atmIv = '—', ivLabel = '—';
    if (s.lastPrice > 0) {
      OptionStrike? atm;
      double minDiff = double.maxFinite;
      for (final st in s.optionStrikes) {
        final d = (st.strike - s.lastPrice).abs();
        if (d < minDiff) { minDiff = d; atm = st; }
      }
      if (atm != null) {
        final ceIv = atm.ce?['implied_volatility'];
        final peIv = atm.pe?['implied_volatility'];
        // ignore: avoid_print
        print('[ATMIVDebug] spot=${s.lastPrice} atmStrike=${atm.strike} '
            'ceIv=$ceIv peIv=$peIv currentAtmIvFormula=CE_only');
        if (ceIv != null) {
          final v = (ceIv as num).toDouble();
          atmIv = v.toStringAsFixed(2);
          ivLabel = v < 12 ? 'Low' : v < 25 ? 'Medium' : 'High';
        }
      }
    }

    setState(() {
      _pcr = pcr;
      _maxPain = maxPain;
      _atmIv = atmIv;
      _ivLabel = ivLabel;
    });
  }

  // ── Scroll to ATM ─────────────────────────────────────────────────────────
  void _scrollToAtm(List<OptionStrike> strikes, double lp) {
    if (!_vertCtrl.hasClients || strikes.isEmpty || lp <= 0) return;
    int idx = 0; double minD = double.maxFinite;
    for (int i = 0; i < strikes.length; i++) {
      final d = (strikes[i].strike - lp).abs();
      if (d < minD) { minD = d; idx = i; }
    }
    final target = idx * _kRowH - _vertCtrl.position.viewportDimension / 2 + _kRowH / 2;
    _vertCtrl.animateTo(
      target.clamp(0, _vertCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  // ── Trading ───────────────────────────────────────────────────────────────
  void _selectCe(OptionStrike st, StockDetailsState s) {
    final secId = st.ce?['security_id']?.toString() ?? '';
    if (secId.isEmpty) return;
    setState(() {
      _selectedSecId = secId;
      _selectedName  = '${s.displayName.split(' ').first} ${st.strike.toStringAsFixed(0)} CE';
      _selectedExchangeSegment = _apiSeg(s.marketItem?.exchange ?? '', s.exchangeSegment);
      _selectedIsCe  = true;
      _selectedStrike = st.strike;
    });
  }

  void _selectPe(OptionStrike st, StockDetailsState s) {
    final secId = st.pe?['security_id']?.toString() ?? '';
    if (secId.isEmpty) return;
    setState(() {
      _selectedSecId = secId;
      _selectedName  = '${s.displayName.split(' ').first} ${st.strike.toStringAsFixed(0)} PE';
      _selectedExchangeSegment = _apiSeg(s.marketItem?.exchange ?? '', s.exchangeSegment);
      _selectedIsCe  = false;
      _selectedStrike = st.strike;
    });
  }

  String _apiSeg(String exch, String seg) {
    final e = exch.toUpperCase(), s = seg.toUpperCase();
    if (s == 'BSE_FNO' || s == 'NSE_FNO') return s;
    if (s == 'D' && e == 'BSE') return 'BSE_FNO';
    return 'NSE_FNO';
  }

  void _onBuy(StockDetailsState sState) {
    if (_selectedSecId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tap a CE or PE row first')));
      return;
    }
    TradeSheet.show(context, item: MarketItem(
      securityId: _selectedSecId!,
      name: _selectedName ?? '', symbol: _selectedName ?? '',
      exchangeSegment: _selectedExchangeSegment ?? 'NSE_FNO',
      exchange: sState.marketItem?.exchange ?? 'NSE',
      lotSize: sState.marketItem?.lotSize ?? '1', isUp: true,
    ), isBuy: true);
  }

  void _onSell(StockDetailsState sState) {
    if (_selectedSecId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tap a CE or PE row first')));
      return;
    }
    TradeSheet.show(context, item: MarketItem(
      securityId: _selectedSecId!,
      name: _selectedName ?? '', symbol: _selectedName ?? '',
      exchangeSegment: _selectedExchangeSegment ?? 'NSE_FNO',
      exchange: sState.marketItem?.exchange ?? 'NSE',
      lotSize: sState.marketItem?.lotSize ?? '1', isUp: false,
    ), isBuy: false);
  }

  // ── Formatting ────────────────────────────────────────────────────────────
  String _oiLakhs(dynamic v) {
    if (v == null) return '—';
    final n = (v as num).toDouble();
    return n <= 0 ? '—' : (n / 100000).toStringAsFixed(2);
  }

  String _pct(double? v) {
    if (v == null || v.isNaN || v.isInfinite) return '';
    return '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';
  }

  double? _oiChgPct(dynamic oi, dynamic prev) {
    if (oi == null || prev == null) return null;
    final p = (prev as num).toDouble();
    if (p == 0) return null;
    return ((oi as num).toDouble() - p) / p * 100;
  }

  double? _ltpChgPct(dynamic changePct) {
    if (changePct == null) return null;
    return (changePct as num).toDouble();
  }

  String _fmtGreek(dynamic v, {int d = 2}) {
    if (v == null) return '—';
    return (v as num).toDouble().toStringAsFixed(d);
  }

  double _maxHScroll(double sideWidth) => max(0.0, sideWidth - _estimatedSideViewportWidth());

  double _estimatedSideViewportWidth() {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - _kStrikeW) / 2 - 16; // rough estimate
  }

  // Wraps Greek header/row content so it lays out at its true full width
  // (_kGreekSideW) regardless of the narrow ambient constraint from the
  // surrounding Expanded/Stack — without OverflowBox, SizedBox(width:...)
  // silently gets clamped down to the visible pane's width, so Transform
  // has nothing extra to reveal and horizontal scroll appears to do nothing.
  //
  // Put's column order is near→far (LTP,IV,Delta,Theta,Vega,Gamma), so
  // offset=0 already shows LTP next to Strike. Call's order is far→near
  // (Gamma,Vega,Theta,Delta,IV,LTP) so its LTP sits at the END of the
  // strip — anchorRight mirrors the transform so offset=0 shows THAT end
  // by construction, instead of needing a fragile one-time initial-offset
  // hack. Both sides then reveal further Greeks together as offset grows.
  Widget _scrollableGreekContent(Widget content, {required bool anchorRight}) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: _kGreekSideW,
        maxWidth: _kGreekSideW,
        child: ValueListenableBuilder<double>(
          valueListenable: _masterHOff,
          builder: (_, off, __) {
            final maxScroll = _maxHScroll(_kGreekSideW);
            final dx = anchorRight ? -(maxScroll - off) : -off;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: SizedBox(width: _kGreekSideW, child: content),
            );
          },
        ),
      ),
    );
  }

  void _onHDragStart(DragStartDetails d) {
    _flingCtrl.stop(); // a new touch interrupts any in-flight momentum
  }

  void _onHDrag(DragUpdateDetails d) {
    final newOffset = (_masterHOff.value - d.delta.dx)
        .clamp(0.0, _maxHScroll(_kGreekSideW)); // Greeks tab is the only one that scrolls
    _masterHOff.value = newOffset;
  }

  void _onHDragEnd(DragEndDetails d) {
    final velocity = -(d.primaryVelocity ?? 0.0); // matches _onHDrag's sign convention
    final maxScroll = _maxHScroll(_kGreekSideW);
    final current = _masterHOff.value;
    // Ignore a slow release right at either edge — nothing to decelerate into.
    if (velocity.abs() < 80 ||
        (current <= 0.0 && velocity < 0) ||
        (current >= maxScroll && velocity > 0)) {
      return;
    }
    final sim = ClampingScrollSimulation(
      position: current,
      velocity: velocity,
      friction: 0.09,
    );
    _flingCtrl.value = current;
    _flingCtrl.animateWith(sim);
  }

  String _expiryLabel(String expiry) {
    try {
      final date = DateTime.parse(expiry.split('T').first);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final now = DateTime.now();
      final days = date.difference(DateTime(now.year, now.month, now.day)).inDays;
      final dl = days == 0 ? 'Today'
          : days == 1 ? '1 Day'
          : days < 7  ? '$days Days'
          : '${(days / 7).round()} Week${(days / 7).round() > 1 ? 's' : ''}';
      return '${date.day} ${m[date.month - 1]} ($dl)';
    } catch (_) {
      return expiry.split('T').first;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: MultiBlocListener(
          listeners: [
            // Recompute summary on any relevant change (strikes or live price).
            BlocListener<StockDetailsBloc, StockDetailsState>(
              listenWhen: (p, c) =>
                  p.optionStrikes != c.optionStrikes || p.lastPrice != c.lastPrice,
              listener: (ctx, s) => _computeSummary(s),
            ),
            // Auto-scroll to ATM only the first time data arrives for a given
            // expiry (initial load / expiry switch) — NOT on every periodic
            // background refresh of the SAME expiry, otherwise the vertical
            // scroll animation restarts every _kRefreshInterval and fights
            // any in-progress user gesture (esp. Greeks horizontal drag).
            BlocListener<StockDetailsBloc, StockDetailsState>(
              listenWhen: (p, c) => c.optionStrikes.isNotEmpty,
              listener: (ctx, s) {
                if (_scrolledForExpiry == s.selectedExpiry) return;
                if (s.optionStrikes.isNotEmpty && s.lastPrice > 0) {
                  _scrolledForExpiry = s.selectedExpiry;
                  // Scroll against the same windowed list the table renders.
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToAtm(_displayStrikesFor(s), s.lastPrice));
                }
              },
            ),
          ],
          child: BlocBuilder<StockDetailsBloc, StockDetailsState>(
            builder: (ctx, sState) {
              return BlocBuilder<OptionChainBloc, OptionChainState>(
                builder: (ctx, ocState) {
                  return SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(children: [
                      _buildAppBar(sState, ocState),
                      _buildUnderlyingHeader(sState),
                      if (sState.availableExpiries.isNotEmpty)
                        _buildExpiryTabs(sState),
                      _buildColumnHeader(ocState.marketTab),
                      Expanded(
                        child: RefreshIndicator(
                          color: Colorz.primary,
                          onRefresh: () async {
                            final bloc = context.read<StockDetailsBloc>();
                            bloc.add(LoadOptionChainEvent(sState.selectedExpiry));
                            await bloc.stream
                                .firstWhere((s) => !s.isOptionChainLoading)
                                .timeout(const Duration(seconds: 8),
                                    onTimeout: () => bloc.state);
                          },
                          child: _buildTableSynchronized(sState, ocState),
                        ),
                      ),
                      _buildBottomBar(sState),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Single-list synchronized table (one Row per strike = perfect sync) ─────
  Widget _buildTableSynchronized(StockDetailsState sState, OptionChainState ocState) {
    // Only show the full-screen spinner on the genuine first load (no data
    // yet). A background auto-refresh also flips isOptionChainLoading, but
    // once we already have strikes on screen we keep showing them as-is and
    // let the table swap seamlessly when the fresh data lands — otherwise
    // the whole table would flash to a spinner every _kRefreshInterval.
    if (sState.isOptionChainLoading && sState.optionStrikes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colorz.primary));
    }
    // Same reasoning as above: only show the full error screen if we have
    // no data to fall back on. A failed background refresh with existing
    // data on screen just leaves the table as-is (stale-but-valid) rather
    // than replacing it with an error.
    if (sState.optionChainError.isNotEmpty && sState.optionStrikes.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(sState.optionChainError,
            style: AppTextStyles.medium.copyWith(color: Colorz.redColor),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<StockDetailsBloc>()
              .add(LoadOptionChainEvent(sState.selectedExpiry)),
          child: const Text('Retry'),
        ),
      ]));
    }
    if (sState.optionStrikes.isEmpty) {
      return Center(child: Text('No option chain data',
          style: AppTextStyles.medium.copyWith(color: Colorz.textColor)));
    }

    // ATM-centered display window — rendering only. PCR/Max Pain/ATM IV in
    // _computeSummary always use the full sState.optionStrikes, untouched.
    final strikes = _displayStrikesFor(sState);
    final lp = sState.lastPrice;
    final tab = ocState.marketTab;

    // Compute max OI for bar sizing
    double maxCallOi = 1, maxPutOi = 1;
    for (final st in strikes) {
      final co = (st.ce?['oi'] as num?)?.toDouble() ?? 0;
      final po = (st.pe?['oi'] as num?)?.toDouble() ?? 0;
      if (co > maxCallOi) maxCallOi = co;
      if (po > maxPutOi) maxPutOi = po;
    }

    return ListView.builder(
      controller: _vertCtrl,
      itemCount: strikes.length,
      itemBuilder: (ctx, i) {
        final st = strikes[i];
        final isAtm = lp > 0 && (st.strike - lp).abs() <
            (i + 1 < strikes.length
                ? (strikes[i + 1].strike - strikes[i].strike) / 2 + 1
                : 50);
        final ceSelected = _selectedSecId != null &&
            _selectedSecId == st.ce?['security_id']?.toString();
        final peSelected = _selectedSecId != null &&
            _selectedSecId == st.pe?['security_id']?.toString();
        final callOi = (st.ce?['oi'] as num?)?.toDouble() ?? 0;
        final putOi = (st.pe?['oi'] as num?)?.toDouble() ?? 0;
        final callOiRatio = (callOi / maxCallOi).clamp(0.0, 1.0);
        final putOiRatio = (putOi / maxPutOi).clamp(0.0, 1.0);

        return Container(
          height: _kRowH,
          decoration: BoxDecoration(
            color: isAtm ? const Color(0xFFF0F4FF) : null,
            border: Border(bottom: BorderSide(color: Colorz.dividerColor, width: 0.5)),
          ),
          child: Row(children: [
            // ── CALL PANE ─────────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () => _selectCe(st, sState),
                onHorizontalDragStart: tab == optionTab.greeks ? _onHDragStart : null,
                onHorizontalDragUpdate: tab == optionTab.greeks ? _onHDrag : null,
                onHorizontalDragEnd: tab == optionTab.greeks ? _onHDragEnd : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: ceSelected ? Colorz.greenColor.withValues(alpha: 0.06) : null,
                  child: Stack(children: [
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: FractionallySizedBox(
                        widthFactor: callOiRatio,
                        child: Container(
                          color: const Color(0xFFFF3737).withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    tab == optionTab.oi
                        ? _oiCallRowFlex(st)
                        : _scrollableGreekContent(_greekCallRow(st), anchorRight: true),
                  ]),
                ),
              ),
            ),

            // ── STRIKE PANE (fixed center, no scroll) ───────────────────────
            Container(
              width: _kStrikeW,
              color: const Color(0xFFF3F4F7),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                isAtm
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2F3A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(st.strike.toStringAsFixed(0),
                            style: AppTextStyles.semiBold.copyWith(
                                color: Colors.white, fontSize: SizeConfig.smallFont)),
                      )
                    : Text(st.strike.toStringAsFixed(0),
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.textColor, fontSize: SizeConfig.smallFont)),
                const SizedBox(height: 4),
                Builder(builder: (_) {
                  final total = callOiRatio + putOiRatio;
                  final redStop = total > 0
                      ? (callOiRatio / total).clamp(0.08, 0.92)
                      : 0.5;
                  const red = Color(0xFFFF5252);
                  const green = Color(0xFF3AAE00);
                  return Container(
                    height: 3,
                    width: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [red, Color.lerp(red, green, 0.5)!, green],
                        stops: [0.0, redStop, 1.0],
                      ),
                    ),
                  );
                }),
              ]),
            ),

            // ── PUT PANE ─────────────────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () => _selectPe(st, sState),
                onHorizontalDragStart: tab == optionTab.greeks ? _onHDragStart : null,
                onHorizontalDragUpdate: tab == optionTab.greeks ? _onHDrag : null,
                onHorizontalDragEnd: tab == optionTab.greeks ? _onHDragEnd : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: peSelected ? Colorz.redColor.withValues(alpha: 0.06) : null,
                  child: Stack(children: [
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: FractionallySizedBox(
                        widthFactor: putOiRatio,
                        child: Container(
                          color: const Color(0xFF3AAE00).withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    tab == optionTab.oi
                        ? _oiPutRowFlex(st)
                        : _scrollableGreekContent(_greekPutRow(st), anchorRight: false),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(StockDetailsState sState, OptionChainState ocState) {
    return Container(
      color: Colorz.white,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 6,
          bottom: 6,
          left: 4,
          right: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => NavigatorService.goBack(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: Colorz.textColor,
            padding: const EdgeInsets.all(8),
          ),
          // OI tab
          _tabPill('OI', optionTab.oi, ocState.marketTab),
          const SizedBox(width: 8),
          // Greeks tab
          _tabPill('Greeks', optionTab.greeks, ocState.marketTab),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _tabPill(String label, optionTab tab, optionTab activeTab) {
    final active = activeTab == tab;
    return GestureDetector(
      onTap: () {
        context.read<OptionChainBloc>().add(ChangeOptionTab(tab));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.largeFont,
                  color: active ? Colorz.primary : Colorz.hintTextColor2)),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            width: label.length * 8.0,
            color: active ? Colorz.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Underlying header ──────────────────────────────────────────────────────
  Widget _buildUnderlyingHeader(StockDetailsState sState) {
    return Container(
      color: Colorz.white,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colorz.offWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colorz.dividerColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9AA5B4)),
            const SizedBox(width: 8),
            Text(sState.displayName.isNotEmpty ? sState.displayName : 'Option Chain',
                style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
            const Spacer(),
            if (sState.securityId.isNotEmpty)
              LivePriceWidget(
                securityId: sState.securityId,
                style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.smallFont, color: Colorz.greenColor),
              )
            else if (sState.lastPrice > 0)
              Text(sState.lastPrice.toStringAsFixed(2),
                  style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.smallFont, color: Colorz.greenColor)),
          ],
        ),
      ),
    );
  }

  // ── Expiry tabs ────────────────────────────────────────────────────────────
  Widget _buildExpiryTabs(StockDetailsState sState) {
    return Container(
      color: Colorz.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Divider(color: Colorz.dividerColor, height: 1),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: sState.availableExpiries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final expiry = sState.availableExpiries[i];
              final isActive = sState.selectedExpiry == expiry ||
                  sState.selectedExpiry.startsWith(expiry) ||
                  expiry.startsWith(sState.selectedExpiry);
              return GestureDetector(
                onTap: () => context.read<StockDetailsBloc>()
                    .add(ChangeOptionExpiryEvent(expiry)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? Colorz.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Colorz.primary : Colorz.dividerColor,
                      width: 1.2,
                    ),
                  ),
                  child: Text(_expiryLabel(expiry),
                      style: AppTextStyles.medium.copyWith(
                          color: isActive ? Colorz.white : Colorz.hintTextColor,
                          fontSize: SizeConfig.smallerFont)),
                ),
              );
            },
          ),
        ),
        Divider(color: Colorz.dividerColor, height: 1),
      ]),
    );
  }

  // ── Column header ──────────────────────────────────────────────────────────
  Widget _buildColumnHeader(optionTab tab) {
    return Container(
      height: _kHdrH,
      color: Colorz.bottomPillBg,
      child: Row(children: [
        // Call header
        Expanded(
          child: tab == optionTab.oi
              ? _oiCallHeaderFlex()
              : _scrollableGreekContent(_greekCallHeader(), anchorRight: true),
        ),
        // Strike header (fixed)
        Container(
          width: _kStrikeW,
          color: const Color(0xFFEDEEF2),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('STRIKE',
                style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.smallerFont, color: Colorz.hintTextColor)),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_up_rounded, size: 14, color: Color(0xFF9AA5B4)),
          ]),
        ),
        // Put header
        Expanded(
          child: tab == optionTab.oi
              ? _oiPutHeaderFlex()
              : _scrollableGreekContent(_greekPutHeader(), anchorRight: false),
        ),
      ]),
    );
  }

  Widget _gHdrCell(String text, {TextAlign align = TextAlign.right}) {
    return SizedBox(
      width: _kGreekW,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            textAlign: align,
            style: AppTextStyles.medium.copyWith(
                fontSize: 10, color: Colorz.hintTextColor)),
      ),
    );
  }

  Widget _oiCallHeaderFlex() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text('OI (in lakhs)',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      fontSize: 10, color: Colorz.hintTextColor)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Call LTP',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                      fontSize: 10, color: Colorz.hintTextColor)),
            ),
          ],
        ),
      );

  Widget _oiPutHeaderFlex() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text('Put LTP',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.medium.copyWith(
                      fontSize: 10, color: Colorz.hintTextColor)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text('OI (in lakhs)',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.medium.copyWith(
                      fontSize: 10, color: Colorz.hintTextColor)),
            ),
          ],
        ),
      );

  // Order (left→right): Gamma, Vega, Theta, Delta, IV, LTP — LTP sits
  // closest to the Strike column, matching the default (unscrolled) view.
  Widget _greekCallHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _gHdrCell('Gamma'),
          _gHdrCell('Vega'),
          _gHdrCell('Theta'),
          _gHdrCell('Delta'),
          _gHdrCell('IV'),
          _gHdrCell('LTP'),
        ],
      );

  Widget _greekPutHeader() => Row(
        children: [
          _gHdrCell('LTP', align: TextAlign.left),
          _gHdrCell('IV', align: TextAlign.left),
          _gHdrCell('Delta', align: TextAlign.left),
          _gHdrCell('Theta', align: TextAlign.left),
          _gHdrCell('Vega', align: TextAlign.left),
          _gHdrCell('Gamma', align: TextAlign.left),
        ],
      );

  // ── OI tab row cells ──────────────────────────────────────────────────────

  Widget _oiCallRowFlex(OptionStrike st) {
    final oi    = st.ce?['oi'];
    final prev  = st.ce?['previous_oi'];
    final ltp   = st.ce?['last_price'];
    final chPct = _ltpChgPct(st.ce?['change_percentage']);
    final oiPct = _oiChgPct(oi, prev);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        // OI column (flexible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_oiLakhs(oi),
                  style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
              if (oiPct != null)
                Text(_pct(oiPct),
                    style: AppTextStyles.medium.copyWith(
                        fontSize: 10,
                        color: oiPct >= 0 ? Colorz.greenColor : Colorz.redColor)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Call LTP column (live, flexible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _liveLtp(st.ce?['security_id']?.toString() ?? '',
                  ltp != null ? (ltp as num).toDouble().toStringAsFixed(2) : '—',
                  Colorz.textColor),
              if (chPct != null)
                Text(_pct(chPct),
                    style: AppTextStyles.medium.copyWith(
                        fontSize: 10,
                        color: chPct >= 0 ? Colorz.greenColor : Colorz.redColor)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _oiPutRowFlex(OptionStrike st) {
    final oi    = st.pe?['oi'];
    final prev  = st.pe?['previous_oi'];
    final ltp   = st.pe?['last_price'];
    final chPct = _ltpChgPct(st.pe?['change_percentage']);
    final oiPct = _oiChgPct(oi, prev);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [
        // Put LTP column (live, flexible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _liveLtp(st.pe?['security_id']?.toString() ?? '',
                  ltp != null ? (ltp as num).toDouble().toStringAsFixed(2) : '—',
                  Colorz.textColor),
              if (chPct != null)
                Text(_pct(chPct),
                    style: AppTextStyles.medium.copyWith(
                        fontSize: 10,
                        color: chPct >= 0 ? Colorz.greenColor : Colorz.redColor)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // OI column (flexible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_oiLakhs(oi),
                  style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.smallFont, color: Colorz.textColor)),
              if (oiPct != null)
                Text(_pct(oiPct),
                    style: AppTextStyles.medium.copyWith(
                        fontSize: 10,
                        color: oiPct >= 0 ? Colorz.greenColor : Colorz.redColor)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Greeks tab row cells ──────────────────────────────────────────────────

  Widget _greekCallRow(OptionStrike st) {
    final ltp = st.ce?['last_price'];
    final g = st.ce?['greeks'] as Map<String, dynamic>?;
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      // Gamma
      _greekCell(_fmtGreek(g?['gamma'], d: 5), align: TextAlign.right),
      // Vega
      _greekCell(_fmtGreek(g?['vega'], d: 2), align: TextAlign.right),
      // Theta
      _greekCell(_fmtGreek(g?['theta'], d: 2), align: TextAlign.right),
      // Delta
      _greekCell(_fmtGreek(g?['delta'], d: 4), align: TextAlign.right),
      // IV (highlighted)
      _greekCell(_fmtGreek(st.ce?['implied_volatility'], d: 2), isIv: true, align: TextAlign.right),
      // LTP (live, closest to Strike)
      _liveLtpGreek(st.ce?['security_id']?.toString() ?? '',
          ltp != null ? (ltp as num).toDouble().toStringAsFixed(2) : '—',
          Colorz.textColor, align: TextAlign.right),
    ]);
  }

  Widget _greekPutRow(OptionStrike st) {
    final ltp = st.pe?['last_price'];
    final g = st.pe?['greeks'] as Map<String, dynamic>?;
    return Row(children: [
      // LTP (live, closest to Strike)
      _liveLtpGreek(st.pe?['security_id']?.toString() ?? '',
          ltp != null ? (ltp as num).toDouble().toStringAsFixed(2) : '—',
          Colorz.textColor, align: TextAlign.left),
      // IV (highlighted)
      _greekCell(_fmtGreek(st.pe?['implied_volatility'], d: 2), isIv: true, align: TextAlign.left),
      // Delta
      _greekCell(_fmtGreek(g?['delta'], d: 4), align: TextAlign.left),
      // Theta
      _greekCell(_fmtGreek(g?['theta'], d: 2), align: TextAlign.left),
      // Vega
      _greekCell(_fmtGreek(g?['vega'], d: 2), align: TextAlign.left),
      // Gamma
      _greekCell(_fmtGreek(g?['gamma'], d: 5), align: TextAlign.left),
    ]);
  }

  // ── Reusable cell widgets ─────────────────────────────────────────────────

  Widget _greekCell(String value, {bool isIv = false, TextAlign align = TextAlign.right}) {
    return SizedBox(
      width: _kGreekW,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(value,
            textAlign: align,
            style: AppTextStyles.medium.copyWith(
                fontSize: SizeConfig.smallFont,
                color: isIv ? Colorz.primary : Colorz.textColor)),
      ),
    );
  }

  Widget _liveLtp(String secId, String fallback, Color color) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (_, snap) {
        final live = secId.isNotEmpty ? (snap.data?[secId] ?? 0) : 0;
        final text = live > 0 ? live.toStringAsFixed(2) : fallback;
        return Text(text,
            style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.smallFont, color: color));
      },
    );
  }

  Widget _liveLtpGreek(String secId, String fallback, Color color, {TextAlign align = TextAlign.right}) {
    return SizedBox(
      width: _kGreekW,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: StreamBuilder<Map<String, double>>(
          stream: LivePriceService.instance.stream,
          initialData: LivePriceService.instance.prices,
          builder: (_, snap) {
            final live = secId.isNotEmpty ? (snap.data?[secId] ?? 0) : 0;
            final text = live > 0 ? live.toStringAsFixed(2) : fallback;
            return Text(text,
                textAlign: align,
                style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.smallFont, color: color));
          },
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(StockDetailsState sState) {
    return Container(
      decoration: BoxDecoration(
        color: Colorz.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, -3),
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Summary: PCR | Max Pain | ATM IV | IV Level (magnitude bucket, not a real historical percentile — no historical IV series available)
        Container(
          color: Colorz.bottomPillBg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            _summaryChip('PCR', _pcr > 0 ? _pcr.toStringAsFixed(2) : '—'),
            _summaryDiv(),
            _summaryChip('Max Pain', _maxPain),
            _summaryDiv(),
            _summaryChip('ATM IV', _atmIv.isNotEmpty ? _atmIv : '—'),
            _summaryDiv(),
            _summaryChip('IV Level', _ivLabel),
          ]),
        ),

        // Selected option + price
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedName ??
                      (sState.displayName.isNotEmpty
                          ? sState.displayName : 'Select an option'),
                  style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.smallFont, color: Colorz.textColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (_selectedSecId != null)
                  LivePriceWidget(securityId: _selectedSecId!,
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont,
                          color: _selectedIsCe ? Colorz.greenColor : Colorz.redColor))
                else if (sState.securityId.isNotEmpty)
                  LivePriceWidget(securityId: sState.securityId,
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont, color: Colorz.primary))
                else
                  Text('Tap CE or PE to select',
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont, color: Colorz.hintTextColor)),
              ],
            )),
          ]),
        ),

        // Sell / Buy buttons
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).padding.bottom + 12),
          child: Row(children: [
            Expanded(child: Button(
              text: 'Sell', isOutlined: true, isBig: true, radius: 100,
              valueColor: Colorz.primary, textColor: Colorz.primary,
              buttonColor: Colors.transparent,
              onPressed: () => _onSell(sState),
            )),
            const SizedBox(width: 12),
            Expanded(child: Button(
              text: 'Buy', isOutlined: false, isBig: true, radius: 100,
              gradient: Colorz.primaryButtonGradient,
              onPressed: () => _onBuy(sState),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _summaryChip(String label, String value) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      Text(label,
          style: AppTextStyles.medium.copyWith(
              fontSize: 10, color: Colorz.hintTextColor)),
      const SizedBox(height: 2),
      Text(value,
          style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.smallFont, color: Colorz.textColor),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _summaryDiv() =>
      Container(height: 28, width: 1, color: Colorz.dividerColor);
}
