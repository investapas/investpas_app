import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/navigationService.dart';
import '../../../../data/models/market_item.dart';
import '../../../../data/services/live_price_service.dart';
import '../../../../routes/appRoutes.dart';
import '../../../bloc/trading_terminal/terminal_bloc.dart';
import '../../../bloc/trading_terminal/terminal_event.dart';
import '../../../bloc/trading_terminal/terminal_state.dart';
import '../../orders/order_page.dart';
import '../../position/position_page.dart';
import '../../watchlist/watchlist_page.dart';
import 'widget/indices_view.dart';

class TradingTerminalTab extends StatefulWidget {
  const TradingTerminalTab({super.key});

  @override
  State<TradingTerminalTab> createState() => _TradingTerminalTabState();
}

class _TradingTerminalTabState extends State<TradingTerminalTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<TerminalBloc>().add(SearchStockEvent(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TerminalBloc, TerminalState>(
      listenWhen: (prev, curr) => prev.searchQuery.isNotEmpty && curr.searchQuery.isEmpty,
      listener: (ctx, state) {
        _searchController.clear();
      },
      child: BlocBuilder<TerminalBloc, TerminalState>(
      builder: (context, state) {
        if (state.subView != TerminalSubView.main) {
          return _buildSubView(context, state);
        }

        final isSearching = state.searchQuery.isNotEmpty;

        return Container(
          margin: EdgeInsets.only(top: 50.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App logo (replaces Overview + description) ──────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Image.asset(
                  Assets.logoTransparent,
                  height: 36.sp,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // ── Search bar ──────────────────────────────────────────────
              _buildSearchBar(context),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              // ── Horizontal indices mini-cards (hidden while searching) ──
              if (!isSearching) ...[
                _IndicesMiniCards(state: state),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

                // ── Section label ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Market Indices',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.mediumFont,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => NavigatorService.pushNamed(AppRoutes.marketPage),
                        child: Row(
                          children: [
                            Text(
                              'Market',
                              style: AppTextStyles.medium.copyWith(
                                color: Colorz.primary,
                                fontSize: SizeConfig.smallFont,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colorz.primary, size: 16.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
              ],

              // ── Indices list ────────────────────────────────────────────
              Expanded(
                child: isSearching
                    ? IndicesView(
                        items: state.searchItems,
                        onItemTap: () {
                          _searchController.clear();
                          context.read<TerminalBloc>().add(SearchStockEvent(''));
                        },
                      )
                    : const IndicesView(items: []),
              ),

              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
              _buildBottomTabs(context, state),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
            ],
          ),
        );
      },
    ),
    );
  }

  // ── Sub-view (Positions / Watchlist / Orders) ───────────────────────────────
  Widget _buildSubView(BuildContext context, TerminalState state) {
    void goBack() => context
        .read<TerminalBloc>()
        .add(const ChangeTerminalSubViewEvent(TerminalSubView.main));

    Widget page;
    switch (state.subView) {
      case TerminalSubView.positions:
        page = PositionPage(onBack: goBack);
        break;
      case TerminalSubView.watchlist:
        page = WatchlistPage(onBack: goBack);
        break;
      case TerminalSubView.orders:
        page = OrderPage(onBack: goBack);
        break;
      default:
        page = const SizedBox.shrink();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: Column(
        children: [
          Expanded(child: page),
          _buildBottomTabs(context, state),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
        ],
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.sp),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colorz.primary),
          SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colorz.textColor),
              decoration: InputDecoration(
                hintText: 'Search stocks (e.g. TCS)',
                hintStyle: TextStyle(color: Colorz.hintTextColor),
                border: InputBorder.none,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<TerminalBloc>().add(SearchStockEvent(''));
              },
              child: Icon(Icons.close_rounded, color: Colorz.hintTextColor, size: 18),
            ),
        ],
      ),
    );
  }

  // ── Bottom tabs (Watchlist / Positions / Orders) ────────────────────────────
  Widget _buildBottomTabs(BuildContext context, TerminalState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.sp),
      child: Row(
        children: [
          _bottomItem(context, state, Assets.watchlistSvg,   'Watchlist', TerminalSubView.watchlist),
          _bottomItem(context, state, Assets.positionNewSvg, 'Positions', TerminalSubView.positions),
          _bottomItem(context, state, Assets.ordersSvg,      'Orders',    TerminalSubView.orders),
        ],
      ),
    );
  }

  Widget _bottomItem(BuildContext context, TerminalState state,
      String svgIcon, String text, TerminalSubView view) {
    final active = state.subView == view;
    return Expanded(
      child: InkWell(
        onTap: () => context.read<TerminalBloc>().add(ChangeTerminalSubViewEvent(view)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: active ? Colorz.primary.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: active ? Colorz.primary : Colorz.textColor,
              width: 1,
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgIcon,
                  height: 15, width: 15,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    active ? Colorz.primary : Colorz.hintTextColor2,
                    BlendMode.srcIn,
                  )),
              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
              Text(text,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.smallFont,
                    color: active ? Colorz.primary : Colorz.hintTextColor2,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Horizontal scrollable index mini-cards ──────────────────────────────────
class _IndicesMiniCards extends StatelessWidget {
  final TerminalState state;
  const _IndicesMiniCards({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
        itemCount: kMajorIndices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _MiniCard(idx: kMajorIndices[i], state: state),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IndexInfo idx;
  final TerminalState state;
  const _MiniCard({required this.idx, required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalBloc, TerminalState>(
      buildWhen: (p, c) =>
          p.livePrices[idx.securityId] != c.livePrices[idx.securityId],
      builder: (context, st) {
        double ltp = st.livePrices[idx.securityId] ?? 0;
        if (ltp <= 0) ltp = state.livePrices[idx.securityId] ?? 0;

        final prevClose = _prevClose(idx.securityId);
        final hasPc   = prevClose > 0 && ltp > 0;
        final change  = hasPc ? ltp - prevClose : 0.0;
        final pct     = hasPc ? (change / prevClose) * 100 : 0.0;
        final isUp    = change >= 0;
        final hasData = ltp > 0;

        final priceColor = hasData
            ? (hasPc ? (isUp ? Colorz.greenColor : Colorz.redColor) : Colorz.primary)
            : Colorz.hintTextColor;

        return GestureDetector(
          onTap: () {
            final item = MarketItem(
              securityId:      idx.securityId,
              name:            idx.name,
              symbol:          idx.symbol,
              exchangeSegment: 'IDX_I',
              exchange:        idx.exchange,
              lotSize:         '1',
              isUp:            isUp,
            );
            NavigatorService.pushNamed(AppRoutes.stockDetailsPage, arguments: item);
          },
          child: Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colorz.bottomPillBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPc
                    ? (isUp ? Colorz.greenColor : Colorz.redColor).withValues(alpha: 0.25)
                    : Colorz.dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Index name + exchange badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        idx.name,
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.smallFont,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colorz.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        idx.exchange,
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.primary,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                // LTP
                Text(
                  hasData ? ltp.toStringAsFixed(2) : '—',
                  style: AppTextStyles.semiBold.copyWith(
                    color: priceColor,
                    fontSize: SizeConfig.mediumFont,
                  ),
                ),

                // Change pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasPc
                        ? (isUp ? Colorz.greenColor : Colorz.redColor).withValues(alpha: 0.12)
                        : Colorz.bottomPillBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hasPc
                        ? '${isUp ? '+' : ''}${pct.toStringAsFixed(2)}%'
                        : '—',
                    style: AppTextStyles.semiBold.copyWith(
                      color: hasPc
                          ? (isUp ? Colorz.greenColor : Colorz.redColor)
                          : Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _prevClose(String secId) {
    try {
      return LivePriceService.instance.prevCloseOf(secId);
    } catch (_) {
      return 0;
    }
  }
}
