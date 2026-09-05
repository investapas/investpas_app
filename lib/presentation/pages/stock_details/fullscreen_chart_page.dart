import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../bloc/stock_details/stock_details_bloc.dart';
import '../../bloc/stock_details/stock_details_event.dart';
import '../../bloc/stock_details/stock_details_state.dart';
// TODO: Uncomment when TradingView library is received
// import 'tradingview_chart_page.dart';
import 'widget/overview_chart.dart';

class FullscreenChartPage extends StatefulWidget {
  const FullscreenChartPage({super.key});

  @override
  State<FullscreenChartPage> createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends State<FullscreenChartPage> {
  static const _intervals = [
    (1,  '1m'),
    (5,  '5m'),
    (15, '15m'),
    (25, '25m'),
    (60, '1H'),
  ];

  @override
  void initState() {
    super.initState();
    // Force landscape for full-screen chart
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore portrait + UI when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockDetailsBloc, StockDetailsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colorz.white,
          body: Stack(
            children: [
              // ── Full-screen chart ───────────────────────────────────
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (ctx, constraints) => state.isChartLoading
                      ? const Center(child: CircularProgressIndicator(color: Colorz.primary))
                      : OverviewChart(
                          candles: state.candles,
                          isLoading: false,
                          securityId: state.securityId,
                          height: constraints.maxHeight - 52,
                          onNeedOlderData: () => context.read<StockDetailsBloc>()
                              .add(const LoadOlderCandlesEvent()),
                        ),
                ),
              ),

              // ── Top bar overlay ─────────────────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  color: Colorz.white.withValues(alpha: 0.92),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colorz.bottomPillBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colorz.hintTextColor2, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Stock name
                      Expanded(
                        child: Text(
                          state.displayName,
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.mediumFont),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // ── Interval chips ─────────────────────────────
                      Row(
                          children: _intervals.map((item) {
                            final isActive = state.chartInterval == item.$1 && state.chartInterval > 0;
                            return GestureDetector(
                              onTap: () => context
                                  .read<StockDetailsBloc>()
                                  .add(ChangeInterval(isActive ? 0 : item.$1)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? Colorz.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive
                                        ? Colorz.primary
                                        : Colorz.dividerColor,
                                  ),
                                ),
                                child: Text(item.$2,
                                    style: AppTextStyles.semiBold.copyWith(
                                      color: isActive
                                          ? Colors.white
                                          : Colorz.hintTextColor,
                                      fontSize: SizeConfig.smallerFont,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),

                      // TODO: Uncomment when TradingView library is received
                      // const SizedBox(width: 6),
                      // GestureDetector(
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => TradingViewChartPage(
                      //         securityId:      state.securityId,
                      //         exchangeSegment: state.exchangeSegment,
                      //         displayName:     state.displayName,
                      //       ),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //     decoration: BoxDecoration(
                      //       color: Colorz.primary.withValues(alpha: 0.1),
                      //       borderRadius: BorderRadius.circular(6),
                      //       border: Border.all(color: Colorz.primary.withValues(alpha: 0.4)),
                      //     ),
                      //     child: Text(
                      //       'TV Chart',
                      //       style: AppTextStyles.semiBold.copyWith(
                      //         color: Colorz.primary,
                      //         fontSize: SizeConfig.smallerFont,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 6),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
