import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../Widgets/circle_border_icon.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../bloc/dashboard/bloc.dart';
import '../../../../bloc/dashboard/state.dart';

class RuleSummaryWidget extends StatelessWidget {
  const RuleSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        if (!state.hasChallenge) {
          return Center(
            child: Text(
              "No challenge set up yet",
              style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    svgImage: Assets.tradingCapitalSvg,
                    title: "Trading Capital",
                    value: "₹${_fmt(state.tradingCapital)}",
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                Expanded(
                  child: _summaryCard(
                    svgImage: Assets.dailyProfitSvg,
                    title: "Daily Profit Target",
                    value: "₹${_fmt(state.minProfit)} – ₹${_fmt(state.maxProfit)}",
                  ),
                ),
              ],
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    svgImage: Assets.dailyLossSvg,
                    title: "Daily Loss Limit",
                    value: "₹${_fmt(state.minLoss)} – ₹${_fmt(state.maxLoss)}",
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                Expanded(
                  child: _summaryCard(
                    svgImage: Assets.maxTradeSvg,
                    title: "Max Trades / Day",
                    value: "${state.maxTradesPerDay} trades",
                  ),
                ),
              ],
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            _PositionSizeCard(
              niftyLots:      state.niftyLots,
              bankNiftyLots:  state.bankNiftyLots,
              finNiftyLots:   state.finNiftyLots,
              midcapNiftyLots: state.midcapNiftyLots,
              sensexLots:     state.sensexLots,
            ),
          ],
        );
      },
    );
  }

  String _fmt(double value) {
    if (value >= 100000) return "${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 1)}L";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K";
    return value.toStringAsFixed(0);
  }

  Widget _summaryCard({
    required String svgImage,
    required String title,
    required String value,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Colorz.summaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleBorderIcon(svg: svgImage, size: 44, borderWidth: 0.8),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          Text(
            title,
            style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.smallerFont,
              color: Colorz.textColor,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.smallFont,
              color: Colorz.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PositionSizeCard extends StatefulWidget {
  final int niftyLots;
  final int bankNiftyLots;
  final int finNiftyLots;
  final int midcapNiftyLots;
  final int sensexLots;

  const _PositionSizeCard({
    required this.niftyLots,
    required this.bankNiftyLots,
    required this.finNiftyLots,
    required this.midcapNiftyLots,
    required this.sensexLots,
  });

  @override
  State<_PositionSizeCard> createState() => _PositionSizeCardState();
}

class _PositionSizeCardState extends State<_PositionSizeCard> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _slides {
    final all = [
      {'label': 'NIFTY',       'lots': widget.niftyLots},
      {'label': 'BANKNIFTY',   'lots': widget.bankNiftyLots},
      {'label': 'FINNIFTY',    'lots': widget.finNiftyLots},
      {'label': 'MIDCAPNIFTY', 'lots': widget.midcapNiftyLots},
      {'label': 'SENSEX',      'lots': widget.sensexLots},
    ];
    return all.where((e) => (e['lots'] as int) > 0).toList();
  }

  int get _totalLots =>
      widget.niftyLots + widget.bankNiftyLots +
      widget.finNiftyLots + widget.midcapNiftyLots + widget.sensexLots;

  void _prev() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Colorz.summaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // arrows + dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // dot indicators
              Expanded(
                child: Row(
                  children: List.generate(slides.length, (i) => Container(
                    width: i == _currentPage ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _currentPage ? Colorz.primary : Colorz.hintTextColor.withValues(alpha: 0.3),
                    ),
                  )),
                ),
              ),
              GestureDetector(
                onTap: _prev,
                child: CircleBorderIcon(
                  svg: Assets.arrowLeftSvg,
                  size: 30,
                  borderWidth: 1,
                  borderColor: _currentPage > 0 ? Colorz.primary : Colorz.hintTextColor,
                ),
              ),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.6),
              GestureDetector(
                onTap: _next,
                child: CircleBorderIcon(
                  svg: Assets.arrowRightSvg,
                  size: 30,
                  borderWidth: 1,
                  borderColor: _currentPage < slides.length - 1 ? Colorz.primary : Colorz.hintTextColor,
                ),
              ),
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
          // slide content
          SizedBox(
            height: 56,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.isEmpty ? 1 : slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                if (slides.isEmpty) {
                  return Row(
                    children: [
                      CircleBorderIcon(svg: Assets.sizeLimitSvg, size: 44, borderWidth: 0.8),
                      SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.6),
                      Text(
                        "Position Size Limits",
                        style: AppTextStyles.semiBold.copyWith(
                          fontSize: SizeConfig.smallFont,
                          color: Colorz.textColor,
                        ),
                      ),
                    ],
                  );
                }
                final slide = slides[i];
                final label = slide['label'] as String;
                final lots = slide['lots'] as int;
                return Row(
                  children: [
                    CircleBorderIcon(svg: Assets.sizeLimitSvg, size: 44, borderWidth: 0.8),
                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Position Size Limits",
                            style: AppTextStyles.semiBold.copyWith(
                              fontSize: SizeConfig.smallFont,
                              color: Colorz.textColor,
                            ),
                          ),
                          Text(
                            "Total $_totalLots lot${_totalLots != 1 ? 's' : ''}  •  ${i + 1}/${slides.length}",
                            style: AppTextStyles.medium.copyWith(
                              fontSize: SizeConfig.smallerFont,
                              color: Colorz.hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$label: $lots lot${lots != 1 ? 's' : ''}",
                      style: AppTextStyles.headerThree.copyWith(
                        fontSize: 13,
                        color: Colorz.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
