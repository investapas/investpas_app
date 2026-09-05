import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../../core/constants/constants.dart';
import '../../../../data/models/chart_data.dart';
import '../../../../data/services/live_price_service.dart';
import '../../../../presentation/bloc/trading_terminal/terminal_bloc.dart';
import '../../../../presentation/bloc/trading_terminal/terminal_state.dart';

class OverviewChart extends StatefulWidget {
  final List<ChartCandle> candles;
  final bool isLoading;
  final String securityId;
  /// Override chart area height. Null = default 240.sp (portrait inline).
  final double? height;
  /// Called (once per pan gesture, until new candles arrive) when the user
  /// pans back to the oldest currently-loaded candle — hook for progressive
  /// history loading.
  final VoidCallback? onNeedOlderData;

  const OverviewChart({
    super.key,
    required this.candles,
    this.isLoading = false,
    this.securityId = '',
    this.height,
    this.onNeedOlderData,
  });

  @override
  State<OverviewChart> createState() => _OverviewChartState();
}

class _OverviewChartState extends State<OverviewChart> {
  bool _showCandles = true;
  ChartCandle? _hovered;
  double _scrollOffset = 0;
  // Debounces onNeedOlderData — reset whenever the candle list changes, so it
  // can fire again once new (older) data has actually been merged in.
  bool _requestedOlder = false;

  static const double _candleW = 8.0;
  static const double _candleGap = 2.0;
  static const double _step = _candleW + _candleGap;
  static const double _labelW = 58.0;

  @override
  void didUpdateWidget(OverviewChart old) {
    super.didUpdateWidget(old);
    if (widget.candles.isEmpty || old.candles.length == widget.candles.length) return;

    final isPrepend = old.candles.isNotEmpty &&
        widget.candles.length > old.candles.length &&
        widget.candles.first.time.isBefore(old.candles.first.time);

    if (isPrepend) {
      // Older candles were prepended by a backward pan — shift the scroll
      // offset by the same amount instead of jumping to "newest", so the
      // user's view doesn't get yanked away from where they just panned to.
      final delta = (widget.candles.length - old.candles.length) * _step;
      setState(() {
        _scrollOffset += delta;
        _requestedOlder = false;
      });
      return;
    }

    _requestedOlder = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Scroll to show newest candles on the right
      final chartW = (context.size?.width ?? 350) - _labelW;
      final visible = (chartW / _step).floor();
      final maxScroll = math.max(0.0, (widget.candles.length - visible) * _step);
      setState(() => _scrollOffset = maxScroll);
    });
  }

  void _maybeRequestOlder() {
    if (_scrollOffset <= 0 && !_requestedOlder && widget.onNeedOlderData != null) {
      _requestedOlder = true;
      widget.onNeedOlderData!();
    }
  }

  double _getLivePrice(BuildContext ctx) {
    try {
      final p = ctx.read<TerminalBloc>().state.livePrices[widget.securityId];
      if (p != null && p > 0) return p;
    } catch (_) {}
    final d = LivePriceService.instance.priceOf(widget.securityId);
    return d > 0 ? d : 0;
  }

  List<ChartCandle> _withLiveCandle(BuildContext ctx, List<ChartCandle> candles) {
    if (candles.isEmpty) return candles;
    final live = _getLivePrice(ctx);
    if (live <= 0) return candles;
    final last = candles.last;
    return [
      ...candles.sublist(0, candles.length - 1),
      ChartCandle(
        time:   last.time,
        open:   last.open,
        high:   live > last.high ? live : last.high,
        low:    live < last.low  ? live : last.low,
        close:  live,
        volume: last.volume,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalBloc, TerminalState>(
      buildWhen: (p, c) =>
          (p.livePrices[widget.securityId]) != (c.livePrices[widget.securityId]),
      builder: (ctx, _) {
        final live    = _getLivePrice(ctx);
        final candles = _withLiveCandle(ctx, widget.candles);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Btn('Candle', Icons.candlestick_chart_outlined, _showCandles,   () => setState(() => _showCandles = true)),
                  const SizedBox(width: 6),
                  _Btn('Line',   Icons.show_chart_rounded,          !_showCandles, () => setState(() => _showCandles = false)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Chart area
            SizedBox(
              height: widget.height ?? 240.sp,
              child: widget.isLoading
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colorz.primary)))
                  : candles.isEmpty
                      ? Center(child: Text('No chart data',
                          style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)))
                      : _showCandles
                          ? _candleView(candles, live)
                          : _lineView(candles, live),
            ),
          ],
        );
      },
    );
  }

  // ── Candlestick view ────────────────────────────────────────────────────────
  Widget _candleView(List<ChartCandle> candles, double live) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        setState(() {
          final chartW = (context.size?.width ?? 350) - _labelW;
          final maxScroll = math.max(0.0, (candles.length - (chartW / _step).floor()) * _step);
          _scrollOffset = (_scrollOffset - d.delta.dx).clamp(0.0, maxScroll);
        });
        _maybeRequestOlder();
      },
      onTapUp: (d) {
        final start = (_scrollOffset / _step).floor();
        final idx   = start + (d.localPosition.dx / _step).floor();
        if (idx >= 0 && idx < candles.length) setState(() => _hovered = candles[idx]);
        else setState(() => _hovered = null);
      },
      child: Stack(
        children: [
          // Chart painter
          Positioned.fill(
            child: CustomPaint(
              painter: _CandlePainter(
                candles:      candles,
                livePrice:    live > 0 ? live : null,
                scrollOffset: _scrollOffset,
                hovered:      _hovered,
                candleW:      _candleW,
                gap:          _candleGap,
                labelW:       _labelW,
              ),
            ),
          ),

          // OHLC tooltip on tap
          if (_hovered != null)
            Positioned(
              top: 4, left: 8,
              child: _OhlcTooltip(candle: _hovered!),
            ),

          // Live price badge (top-right)
          if (live > 0)
            Positioned(
              top: 4, right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colorz.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  live.toStringAsFixed(2),
                  style: AppTextStyles.semiBold.copyWith(
                    color: Colors.white,
                    fontSize: SizeConfig.smallFont,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Line view ───────────────────────────────────────────────────────────────
  Widget _lineView(List<ChartCandle> candles, double live) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        setState(() {
          final chartW = (context.size?.width ?? 350) - _labelW;
          final maxScroll = math.max(0.0, (candles.length - (chartW / _step).floor()) * _step);
          _scrollOffset = (_scrollOffset - d.delta.dx).clamp(0.0, maxScroll);
        });
        _maybeRequestOlder();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LinePainter(
                candles:      candles,
                livePrice:    live > 0 ? live : null,
                labelW:       _labelW,
                scrollOffset: _scrollOffset,
                step:         _step,
              ),
            ),
          ),
          if (live > 0)
            Positioned(
              top: 4, right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colorz.primary, borderRadius: BorderRadius.circular(4)),
                child: Text(live.toStringAsFixed(2),
                    style: AppTextStyles.semiBold.copyWith(color: Colors.white, fontSize: SizeConfig.smallFont)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Candlestick painter ───────────────────────────────────────────────────────
class _CandlePainter extends CustomPainter {
  final List<ChartCandle> candles;
  final double? livePrice;
  final double scrollOffset;
  final ChartCandle? hovered;
  final double candleW;
  final double gap;
  final double labelW;

  const _CandlePainter({
    required this.candles,
    this.livePrice,
    required this.scrollOffset,
    this.hovered,
    required this.candleW,
    required this.gap,
    required this.labelW,
  });

  static const double _volRatio = 0.15;
  static const double _pad      = 6.0;
  static const double _xAxisH   = 18.0;
  static const Color _green     = Color(0xFF26A69A);
  static const Color _red       = Color(0xFFEF5350);
  static const Color _gridColor = Color(0xFFEEEEEE);

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final step   = candleW + gap;
    final chartW = size.width - labelW;
    final priceH = size.height - _xAxisH;
    final chartH = priceH * (1 - _volRatio);
    final volH   = priceH * _volRatio;

    final startIdx = (scrollOffset / step).floor().clamp(0, candles.length - 1);
    final visible  = (chartW / step).ceil() + 2;
    final endIdx   = math.min(startIdx + visible, candles.length);
    final sub      = candles.sublist(startIdx, endIdx);
    if (sub.isEmpty) return;

    double hi = sub.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double lo = sub.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    if (livePrice != null) { hi = math.max(hi, livePrice!); lo = math.min(lo, livePrice!); }
    final margin = (hi - lo) * 0.05;
    hi += margin; lo -= margin;
    final range = (hi - lo).abs();
    if (range < 0.01) return;

    double yP(double v) => _pad + (1 - (v - lo) / range) * (chartH - _pad * 2);
    final maxVol = sub.fold<double>(0, (m, c) => c.volume > m ? c.volume.toDouble() : m);

    // ── Background
    canvas.drawRect(Rect.fromLTWH(0, 0, chartW, priceH), Paint()..color = const Color(0xFFFAFAFA));

    // ── Horizontal grid + price labels
    for (int i = 0; i <= 5; i++) {
      final y = _pad + (chartH - _pad * 2) * i / 5;
      _dashedH(canvas, 0, chartW, y, _gridColor, 0.5);
      final price = hi - range * i / 5;
      _text(canvas, price.toStringAsFixed(2), Offset(chartW + 4, y - 6), 8, const Color(0xFF999999));
    }

    // ── Volume separator line
    canvas.drawLine(Offset(0, chartH), Offset(chartW, chartH), Paint()..color = _gridColor..strokeWidth = 0.5);

    // ── Detect intraday vs daily
    final isIntraday = sub.length >= 2 &&
        sub.first.time.year == sub.last.time.year &&
        sub.first.time.month == sub.last.time.month &&
        sub.first.time.day == sub.last.time.day;

    final xOffset = scrollOffset.remainder(step) > 0 ? step - scrollOffset.remainder(step) : 0.0;
    final labelInterval = sub.length > 100 ? 40 : sub.length > 30 ? 15 : 5;

    // ── Candles + Volume + Date labels
    for (int i = 0; i < sub.length; i++) {
      final c  = sub[i];
      final cx = xOffset + i * step + candleW / 2;
      if (cx < 0 || cx > chartW) continue;
      final isUp = c.close >= c.open;
      final col  = isUp ? _green : _red;

      final top = yP(isUp ? c.close : c.open);
      final bot = yP(isUp ? c.open  : c.close);
      final bh  = math.max(bot - top, 1.0);

      // Wick (thin line)
      canvas.drawLine(Offset(cx, yP(c.high)), Offset(cx, yP(c.low)), Paint()..color = col..strokeWidth = 0.8);

      // Body — green: hollow (outline only), red: filled (TradingView style)
      final bodyRect = Rect.fromLTWH(cx - candleW / 2, top, candleW, bh);
      if (isUp) {
        canvas.drawRect(bodyRect, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.0);
      } else {
        canvas.drawRect(bodyRect, Paint()..color = col);
      }

      // Volume bar (subtle, bottom section)
      if (maxVol > 0 && c.volume > 0) {
        final vh = (c.volume / maxVol) * (volH - 4);
        canvas.drawRect(
          Rect.fromLTWH(cx - candleW / 2 + 0.5, chartH + (volH - vh), candleW - 1, vh),
          Paint()..color = col.withValues(alpha: 0.20),
        );
      }

      // X-axis date/time labels
      if (i % labelInterval == 0 && cx > 20 && cx < chartW - 30) {
        final d = c.time;
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final label = isIntraday
            ? '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
            : '${d.day} ${months[d.month]}';
        // Vertical tick mark
        canvas.drawLine(Offset(cx, priceH), Offset(cx, priceH + 3), Paint()..color = const Color(0xFFCCCCCC)..strokeWidth = 0.5);
        _text(canvas, label, Offset(cx - 14, priceH + 4), 7.5, const Color(0xFF999999));
      }

      // Crosshair on hovered candle
      if (hovered != null && hovered!.time == c.time) {
        // Vertical dashed line
        _dashedV(canvas, cx, _pad, chartH, const Color(0xFF888888), 0.8);
        // Horizontal dashed line at close price
        _dashedH(canvas, 0, chartW, yP(c.close), const Color(0xFF888888), 0.8);
        // Price tag on Y-axis
        final tagY = yP(c.close);
        final tagRect = RRect.fromRectAndRadius(Rect.fromLTWH(chartW + 1, tagY - 8, labelW - 3, 16), const Radius.circular(3));
        canvas.drawRRect(tagRect, Paint()..color = col);
        _text(canvas, c.close.toStringAsFixed(2), Offset(chartW + 4, tagY - 6), 8, Colors.white, bold: true);
        // Date tag on X-axis
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final d = c.time;
        final dateTag = isIntraday
            ? '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
            : '${d.day} ${months[d.month]} ${d.year}';
        final dtRect = RRect.fromRectAndRadius(Rect.fromLTWH(cx - 28, priceH, 56, 16), const Radius.circular(3));
        canvas.drawRRect(dtRect, Paint()..color = const Color(0xFF555555));
        _text(canvas, dateTag, Offset(cx - 24, priceH + 2), 7.5, Colors.white, bold: true);
      }
    }

    // ── Live price dashed line + tag
    if (livePrice != null && livePrice! > 0) {
      final y    = yP(livePrice!);
      final isUp = candles.isNotEmpty && livePrice! >= candles.last.open;
      final lCol = isUp ? _green : _red;
      _dashedH(canvas, 0, chartW, y, lCol, 1.0);
      final rect = Rect.fromLTWH(chartW + 1, y - 9, labelW - 3, 18);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), Paint()..color = lCol);
      _text(canvas, livePrice!.toStringAsFixed(2), Offset(chartW + 4, y - 7), 8.5, Colors.white, bold: true);
    }
  }

  void _dashedH(Canvas c, double x1, double x2, double y, Color col, double w) {
    final p = Paint()..color = col..strokeWidth = w;
    double x = x1;
    while (x < x2) { c.drawLine(Offset(x, y), Offset(math.min(x + 4, x2), y), p); x += 7; }
  }

  void _dashedV(Canvas c, double x, double y1, double y2, Color col, double w) {
    final p = Paint()..color = col..strokeWidth = w;
    double y = y1;
    while (y < y2) { c.drawLine(Offset(x, y), Offset(x, math.min(y + 4, y2)), p); y += 7; }
  }


  void _text(Canvas c, String t, Offset o, double sz, Color col, {bool bold = false}) {
    (TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: col, fontSize: sz,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout()).paint(c, o);
  }

  @override
  bool shouldRepaint(_CandlePainter o) =>
      o.candles != candles || o.livePrice != livePrice ||
      o.scrollOffset != scrollOffset || o.hovered != hovered;
}

// ── Line painter ──────────────────────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<ChartCandle> candles;
  final double? livePrice;
  final double labelW;
  final double scrollOffset;
  final double step;

  const _LinePainter({
    required this.candles,
    this.livePrice,
    required this.labelW,
    required this.scrollOffset,
    required this.step,
  });

  static const double _pad = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2) return;
    final w = size.width - labelW;

    // Visible window — same logic as _CandlePainter so scrolling is consistent
    final startIdx = (scrollOffset / step).floor().clamp(0, candles.length - 1);
    final visible  = (w / step).ceil() + 2;
    final endIdx   = math.min(startIdx + visible, candles.length);
    final sub      = candles.sublist(startIdx, endIdx);
    if (sub.length < 2) return;

    final prices = sub.map((c) => c.close).toList();
    double hi = prices.reduce((a, b) => a > b ? a : b);
    double lo = prices.reduce((a, b) => a < b ? a : b);
    if (livePrice != null) { hi = math.max(hi, livePrice!); lo = math.min(lo, livePrice!); }
    final range = (hi - lo).abs();
    if (range < 0.01) return;

    final xOff = scrollOffset.remainder(step) > 0 ? step - scrollOffset.remainder(step) : 0.0;
    double xOf(int i) => (xOff + i * step).clamp(0.0, w);
    double y(double v) => _pad + (1 - (v - lo) / range) * (size.height - _pad * 2);

    final isUp = prices.last >= prices.first;
    final col  = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);

    // Grid
    for (int i = 0; i <= 4; i++) {
      final yy = _pad + (size.height - _pad * 2) * i / 4;
      canvas.drawLine(Offset(0, yy), Offset(w, yy),
          Paint()..color = Colors.grey.withValues(alpha: 0.08)..strokeWidth = 0.5);
      _text(canvas, (hi - range * i / 4).toStringAsFixed(2), Offset(w + 2, yy - 7));
    }

    // Line path
    final path = Path()..moveTo(xOf(0), y(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      final px = xOff + i * step;
      if (px < 0 || px > w) continue;
      path.lineTo(px, y(prices[i]));
    }

    // Fill under line
    final fill = Path()
      ..moveTo(xOf(0), size.height)
      ..lineTo(xOf(0), y(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      final px = xOff + i * step;
      if (px < 0 || px > w) continue;
      fill.lineTo(px, y(prices[i]));
    }
    fill.lineTo(xOf(prices.length - 1), size.height);
    fill.close();

    canvas.drawPath(fill, Paint()
      ..shader = LinearGradient(
        colors: [col.withValues(alpha: 0.3), Colors.transparent],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, size.height))
      ..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = col..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Live price dashed line
    if (livePrice != null && livePrice! > 0) {
      final yy   = y(livePrice!);
      final lCol = livePrice! >= prices.first ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
      _dashed(canvas, Offset(0, yy), Offset(w, yy), lCol);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w + 1, yy - 9, labelW - 3, 18), const Radius.circular(3)),
        Paint()..color = lCol,
      );
      _text(canvas, livePrice!.toStringAsFixed(2), Offset(w + 3, yy - 7), color: Colors.white, bold: true);
    }
  }

  void _dashed(Canvas c, Offset s, Offset e, Color col) {
    final p = Paint()..color = col..strokeWidth = 1;
    double d = 0;
    while (d < e.dx - s.dx) {
      c.drawLine(Offset(s.dx + d, s.dy), Offset(s.dx + math.min(d + 4, e.dx - s.dx), s.dy), p);
      d += 7;
    }
  }

  void _text(Canvas c, String t, Offset o, {double sz = 8.5, Color color = Colors.grey, bool bold = false}) {
    (TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: color, fontSize: sz,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout()).paint(c, o);
  }

  @override
  bool shouldRepaint(_LinePainter o) =>
      o.candles != candles || o.livePrice != livePrice || o.scrollOffset != scrollOffset;
}

// ── OHLC tooltip ──────────────────────────────────────────────────────────────
class _OhlcTooltip extends StatelessWidget {
  final ChartCandle candle;
  const _OhlcTooltip({required this.candle});

  String _formatDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final date = '${d.day} ${months[d.month]} ${d.year}';
    final hasTime = d.hour != 0 || d.minute != 0;
    if (hasTime) {
      return '$date  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final isUp  = candle.close >= candle.open;
    final color = isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    final change = candle.close - candle.open;
    final changePct = candle.open > 0 ? (change / candle.open) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colorz.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date & time
          Text(
            _formatDate(candle.time),
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          // OHLC row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cell('O', candle.open, color),
              const SizedBox(width: 8),
              _cell('H', candle.high, const Color(0xFF26A69A)),
              const SizedBox(width: 8),
              _cell('L', candle.low, const Color(0xFFEF5350)),
              const SizedBox(width: 8),
              _cell('C', candle.close, color),
            ],
          ),
          const SizedBox(height: 3),
          // Change + Volume row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${change >= 0 ? "+" : ""}${change.toStringAsFixed(2)}  (${changePct.toStringAsFixed(2)}%)',
                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
              ),
              if (candle.volume > 0) ...[
                const SizedBox(width: 10),
                Text(
                  'Vol: ${_formatVol(candle.volume)}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatVol(int vol) {
    if (vol >= 10000000) return '${(vol / 10000000).toStringAsFixed(1)}Cr';
    if (vol >= 100000) return '${(vol / 100000).toStringAsFixed(1)}L';
    if (vol >= 1000) return '${(vol / 1000).toStringAsFixed(1)}K';
    return vol.toString();
  }

  Widget _cell(String label, double val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(val.toStringAsFixed(2), style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Toggle button ─────────────────────────────────────────────────────────────
class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Btn(this.label, this.icon, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colorz.primary : Colorz.bottomPillBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : Colorz.hintTextColor),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.medium.copyWith(
              fontSize: SizeConfig.smallerFont,
              color: active ? Colors.white : Colorz.hintTextColor,
            )),
          ],
        ),
      ),
    );
  }
}
