import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_bloc.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_event.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';
import 'package:investapas/presentation/bloc/technical/technical_bloc.dart';
import 'package:investapas/presentation/bloc/technical/technical_event.dart';
import 'package:investapas/presentation/pages/stock_details/widget/news_widget.dart';
import 'package:investapas/presentation/pages/stock_details/widget/option_chain_widget.dart';
import 'package:investapas/presentation/pages/stock_details/widget/overview_widget.dart';
import 'package:investapas/presentation/pages/stock_details/widget/technical_widget.dart';
import 'package:investapas/data/models/market_item.dart';
import 'package:investapas/data/models/portfolio_position.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../../routes/appRoutes.dart';
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/trading_terminal/terminal_state.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../bloc/watchlist/watchlist_state.dart';

class StockDetailPage extends StatefulWidget {
  final PortfolioPosition? position;
  final MarketItem? marketItem;

  const StockDetailPage({super.key, this.position, this.marketItem});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<StockDetailsBloc>().add(const ChangeDetailsTab(DetailsTab.overview));
    if (widget.marketItem != null) {
      context.read<StockDetailsBloc>().add(InitializeWithMarketItem(widget.marketItem!));
      // Subscribe via TerminalBloc relay so TerminalBloc.state.livePrices updates
      context.read<TerminalBloc>().add(SubscribeAdditionalItemsEvent([widget.marketItem!]));
    } else if (widget.position != null) {
      context.read<StockDetailsBloc>().add(InitializeWithPosition(widget.position!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocBuilder<StockDetailsBloc, StockDetailsState>(
              builder: (context,state) {
                return Container(
                  margin: EdgeInsets.only(
                    top: 50.sp,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: (){
                                NavigatorService.goBack();
                              },
                              child: CircleWidget(
                                backgroundColor: Colorz.white,
                                child: Icon(Icons.arrow_back_rounded,color: Colorz.hintTextColor2,),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Watchlist button
                                  BlocBuilder<WatchlistBloc, WatchlistState>(
                                    builder: (context, wState) {
                                      final securityId = state.marketItem?.securityId ?? state.position?.securityId ?? '';
                                      final isInWatchlist = securityId.isNotEmpty && wState.watchlistIds.contains(securityId);
                                      return _ActionButton(
                                        icon: isInWatchlist ? Icons.star_rounded : Icons.star_border_rounded,
                                        label: "Watchlist",
                                        iconColor: isInWatchlist ? const Color(0xFFFFC107) : Colorz.hintTextColor2,
                                        onTap: () {
                                          if (securityId.isNotEmpty && !isInWatchlist) {
                                            context.read<WatchlistBloc>().add(AddToWatchlist(securityId));
                                          }
                                          context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
                                          context.read<TerminalBloc>().add(const ChangeTerminalSubViewEvent(TerminalSubView.watchlist));
                                          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homePage);
                                        },
                                      );
                                    },
                                  ),
                                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.8),
                                  // Option Chain button
                                  _ActionButton(
                                    icon: Icons.account_tree_outlined,
                                    label: "Options",
                                    iconColor: Colorz.hintTextColor2,
                                    onTap: () => NavigatorService.pushNamed(AppRoutes.optionChangePage),
                                  ),
                                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.8),
                                  // Chart button
                                  _ActionButton(
                                    icon: Icons.candlestick_chart_outlined,
                                    label: "Chart",
                                    iconColor: Colorz.hintTextColor2,
                                    onTap: () => context.read<StockDetailsBloc>().add(const ChangeDetailsTab(DetailsTab.overview)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.displayName.isNotEmpty ? state.displayName : "Stock Details",
                                style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerTwoFont),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween * 2,
                        ),
                        child: Text(
                          state.displayExchange.isNotEmpty ? state.displayExchange : "",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont),
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                      _buildTopTabs(context, state),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                      Expanded(
                        child: _buildTabView(state),
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
      ),
    );
  }

  Widget _buildTopTabs(BuildContext context, StockDetailsState state) {

    Widget tab(String text, DetailsTab targetTab) {
      final active = state.marketTab == targetTab;

      return Expanded(
        child: InkWell(
          onTap: () {
            context.read<StockDetailsBloc>().add(ChangeDetailsTab(targetTab));
            if (targetTab == DetailsTab.technical && state.securityId.isNotEmpty) {
              final seg = state.exchangeSegment;
              final instr = seg == 'IDX_I' ? 'INDEX' : seg.contains('FNO') ? 'OPTIDX' : 'EQUITY';
              context.read<TechnicalBloc>().add(LoadTechnicalDataEvent(
                securityId: state.securityId,
                exchangeSegment: seg,
                instrument: instr,
              ));
            }
            if (targetTab == DetailsTab.news) {
              context.read<StockDetailsBloc>().add(LoadNews());
            }
          },
          child: Column(
            children: [
              Text(
                text,
                style: AppTextStyles.semiBold.copyWith(
                    color: active ? Colorz.textColor : Colorz.hintTextColor,
                    fontSize: SizeConfig.largeFont
                ),
              ),
              SizedBox(height: 8),
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                height: 3,
                width: double.infinity,
                color: active ? Colorz.primary : Colors.transparent,
              )
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tab("Overview", DetailsTab.overview),
        tab("Technical", DetailsTab.technical),
        tab("Options", DetailsTab.options),
        tab("News", DetailsTab.news),
      ],
    );
  }

  Widget _buildTabView(StockDetailsState state) {
    switch (state.marketTab) {
      case DetailsTab.overview:
        return const OverviewWidget();
      case DetailsTab.technical:
        return const TechnicalWidget();
      case DetailsTab.options:
        return const OptionChainWidget();
      case DetailsTab.news:
        return const NewsWidget();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colorz.bottomPillBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.medium.copyWith(
              fontSize: SizeConfig.smallerFont,
              color: Colorz.hintTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
