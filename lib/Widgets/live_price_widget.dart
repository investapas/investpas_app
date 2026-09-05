import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../data/services/live_price_service.dart';
import '../presentation/bloc/trading_terminal/terminal_bloc.dart';
import '../presentation/bloc/trading_terminal/terminal_state.dart';

/// Live price widget with percentage change pill and graceful closed-market fallback.
///
/// Priority:
///   1. Live LTP from TerminalBloc or direct Dhan WebSocket
///   2. Last seen LTP (cached in GetStorage, survives market close + app restart)
///   3. prevClose from WebSocket (only if neither LTP nor lastSeen is available)
///   4. "—" placeholder
///
/// - [showChange]  = true → shows `+X.XX (X.XX%)` pill below the price
/// - [prevClose]   = explicit previous-close override (0 = auto from WebSocket)
class LivePriceWidget extends StatefulWidget {
  final String securityId;
  final TextStyle? style;
  final bool showChange;
  final double prevClose;

  const LivePriceWidget({
    super.key,
    required this.securityId,
    this.style,
    this.showChange = false,
    this.prevClose = 0,
  });

  @override
  State<LivePriceWidget> createState() => _LivePriceWidgetState();
}

class _LivePriceWidgetState extends State<LivePriceWidget> {
  double _prevClose = 0;
  StreamSubscription? _priceSub;

  @override
  void initState() {
    super.initState();
    _readPrevClose();
    _priceSub = LivePriceService.instance.stream.listen((_) => _readPrevClose());
  }

  void _readPrevClose() {
    final pc = widget.prevClose > 0
        ? widget.prevClose
        : LivePriceService.instance.prevCloseOf(widget.securityId);
    if (pc != _prevClose && mounted) setState(() => _prevClose = pc);
  }

  @override
  void didUpdateWidget(LivePriceWidget old) {
    super.didUpdateWidget(old);
    if (old.prevClose != widget.prevClose) _readPrevClose();
  }

  @override
  void dispose() {
    _priceSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalBloc, TerminalState>(
      buildWhen: (prev, curr) =>
          prev.livePrices[widget.securityId] !=
          curr.livePrices[widget.securityId],
      builder: (context, state) {
        // ── Resolve the price to display ────────────────────────────────────
        double? ltp = state.livePrices[widget.securityId];
        if (ltp == null || ltp <= 0) {
          final direct = LivePriceService.instance.priceOf(widget.securityId);
          if (direct > 0) ltp = direct;
        }

        final bool isLive      = ltp != null && ltp > 0;
        final bool marketOpen  = LivePriceService.isMarketOpen;

        // Fallback: last seen price (persisted closing price / last tick)
        double? displayPrice = isLive ? ltp : null;
        if (!isLive) {
          final cached = LivePriceService.instance.lastSeenPriceOf(widget.securityId);
          if (cached > 0) displayPrice = cached;
        }

        // Last resort: prevClose itself (when no LTP has ever been received)
        if ((displayPrice == null || displayPrice <= 0) && _prevClose > 0) {
          displayPrice = _prevClose;
        }

        final hasData  = displayPrice != null && displayPrice > 0;
        final hasPc    = _prevClose > 0 && hasData;
        final change   = hasPc ? displayPrice - _prevClose : 0.0;
        final changePct = hasPc ? (change / _prevClose) * 100 : 0.0;
        final isUp      = change >= 0;

        // Color: full brightness when live, slightly muted when market is closed
        final baseColor = hasData
            ? (hasPc
                ? (isUp ? Colorz.greenColor : Colorz.redColor)
                : Colorz.primary)
            : Colorz.hintTextColor;
        final priceColor = (!isLive && !marketOpen && hasData)
            ? baseColor.withValues(alpha: 0.75)
            : baseColor;

        final priceStyle =
            (widget.style ?? AppTextStyles.semiBold).copyWith(color: priceColor);

        if (!widget.showChange) {
          return Text(
            hasData ? displayPrice.toStringAsFixed(2) : '—',
            style: priceStyle,
          );
        }

        // ── Price + change pill ──────────────────────────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasData ? displayPrice.toStringAsFixed(2) : '—',
              style: priceStyle,
            ),
            if (hasPc) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Closed" label when market is not open and we're on a non-live price
                  if (!isLive && !marketOpen) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colorz.hintTextColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'Closed',
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallerFont,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isUp ? Colorz.greenColor : Colorz.redColor)
                          .withValues(alpha: isLive ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${isUp ? '+' : ''}${change.toStringAsFixed(2)}  (${changePct.toStringAsFixed(2)}%)',
                      style: AppTextStyles.medium.copyWith(
                        color: (isUp ? Colorz.greenColor : Colorz.redColor)
                            .withValues(alpha: isLive ? 1.0 : 0.7),
                        fontSize: SizeConfig.smallerFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (hasData) ...[
              const SizedBox(height: 3),
              Text(
                !isLive ? 'Closed' : '—',
                style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallerFont,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
