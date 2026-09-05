import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/constants/constants.dart';

import '../../../../../Widgets/live_price_widget.dart';
import '../../../../../data/services/live_price_service.dart';
import '../../../../../presentation/bloc/trading_terminal/terminal_bloc.dart';
import '../../../../../presentation/bloc/trading_terminal/terminal_state.dart';
import '../../../../../core/utils/navigationService.dart';
import '../../../../../data/models/market_item.dart';
import '../../../../../presentation/bloc/watchlist/watchlist_bloc.dart';
import '../../../../../presentation/bloc/watchlist/watchlist_event.dart';
import '../../../../../presentation/bloc/watchlist/watchlist_state.dart';
import '../../../../../routes/appRoutes.dart';

// Hardcoded major indices — IDX_I segment, confirmed SecurityIds
const List<IndexInfo> kMajorIndices = [
  IndexInfo('13',  'NIFTY 50',     'NIFTY',       'NSE'),
  IndexInfo('25',  'BANKNIFTY',    'BANKNIFTY',   'NSE'),
  IndexInfo('27',  'FINNIFTY',     'FINNIFTY',    'NSE'),
  IndexInfo('51',  'SENSEX',       'SENSEX',      'BSE'),
  IndexInfo('442', 'MIDCAP NIFTY', 'MIDCAPNIFTY', 'NSE'),
];

class IndexInfo {
  final String securityId;
  final String name;
  final String symbol;
  final String exchange;
  const IndexInfo(this.securityId, this.name, this.symbol, this.exchange);
}

// ── Indices tab — shows 5 major live indices ─────────────────────────────────
class IndicesView extends StatelessWidget {
  // These params kept for compatibility (used when showing search results)
  final List<MarketItem> items;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  // Called after the user navigates to stock details (so caller can clear search)
  final VoidCallback? onItemTap;

  const IndicesView({
    super.key,
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // If items passed (search results), show them instead
    if (items.isNotEmpty) {
      return _InstrumentList(
        items: items,
        isLoadingMore: isLoadingMore,
        hasMore: hasMore,
        onLoadMore: onLoadMore,
        onItemTap: onItemTap,
      );
    }

    // Default: show major indices
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: kMajorIndices.length,
      separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor, thickness: 1),
      itemBuilder: (context, index) => _indexRow(context, kMajorIndices[index]),
    );
  }

  Widget _indexRow(BuildContext outerContext, IndexInfo idx) {
    return BlocBuilder<TerminalBloc, TerminalState>(
      buildWhen: (prev, curr) =>
          (prev.livePrices[idx.securityId]) != (curr.livePrices[idx.securityId]),
      builder: (context, state) {
        double? ltp = state.livePrices[idx.securityId];
        if (ltp == null || ltp <= 0) {
          final direct = LivePriceService.instance.priceOf(idx.securityId);
          if (direct > 0) ltp = direct;
        }
        final hasData  = ltp != null && ltp > 0;
        final prevClose = LivePriceService.instance.prevCloseOf(idx.securityId);
        final hasPc    = prevClose > 0 && hasData;
        final change   = hasPc ? ltp - prevClose : 0.0;
        final changePct = hasPc ? (change / prevClose) * 100 : 0.0;
        final isUp     = change >= 0;
        final priceColor = hasData
            ? (hasPc ? (isUp ? Colorz.greenColor : Colorz.redColor) : Colorz.primary)
            : Colorz.hintTextColor;

        return InkWell(
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                // Exchange badge
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colorz.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(idx.exchange,
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.primary, fontSize: SizeConfig.smallerFont)),
                  ),
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                // Name
                Expanded(
                  child: Text(idx.name,
                      style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor, fontSize: SizeConfig.mediumFont)),
                ),
                // Price + % change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasData ? ltp.toStringAsFixed(2) : '—',
                      style: AppTextStyles.semiBold.copyWith(
                          color: priceColor, fontSize: SizeConfig.mediumFont),
                    ),
                    if (hasPc) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isUp ? Colorz.greenColor : Colorz.redColor)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isUp ? '+' : ''}${change.toStringAsFixed(2)}  (${changePct.toStringAsFixed(2)}%)',
                          style: AppTextStyles.medium.copyWith(
                            color: isUp ? Colorz.greenColor : Colorz.redColor,
                            fontSize: SizeConfig.smallerFont,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Colorz.hintTextColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Instrument list (used for search results) ────────────────────────────────
class _InstrumentList extends StatefulWidget {
  final List<MarketItem> items;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final VoidCallback? onItemTap;

  const _InstrumentList({
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onItemTap,
  });

  @override
  State<_InstrumentList> createState() => _InstrumentListState();
}

class _InstrumentListState extends State<_InstrumentList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.offset >= threshold &&
        widget.hasMore &&
        !widget.isLoadingMore &&
        widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return Center(
        child: Text(
          "No Item Found",
          style: AppTextStyles.semiBold.copyWith(
            color: Colorz.textColor,
            fontSize: SizeConfig.largeFont,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.items.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: Colorz.primary)),
          );
        }
        return _item(context, widget.items[index]);
      },
      separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor, thickness: 1),
    );
  }

  Widget _item(BuildContext context, MarketItem item) {
    return InkWell(
      onTap: () async {
        await NavigatorService.pushNamed(AppRoutes.stockDetailsPage, arguments: item);
        widget.onItemTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor2)),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                  Text(item.lotSize,
                      style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor2)),
                ],
              ),
            ),
            LivePriceWidget(
              securityId: item.securityId,
              showChange: true,
              prevClose: item.close,
              style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont),
            ),
            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
            BlocBuilder<WatchlistBloc, WatchlistState>(
              builder: (context, wState) {
                final isInWatchlist = wState.watchlistIds.contains(item.securityId);
                if (isInWatchlist) {
                  return GestureDetector(
                    onTap: () => context.read<WatchlistBloc>().add(RemoveFromWatchlist(item.securityId)),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colorz.redColor, width: 1.5),
                      ),
                      child: Icon(Icons.remove_rounded, color: Colorz.redColor, size: 16),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => context.read<WatchlistBloc>().add(AddToWatchlist(item.securityId)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colorz.primary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colorz.primary, size: 14),
                        const SizedBox(width: 2),
                        Text("Add",
                            style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.primary,
                              fontSize: SizeConfig.smallerFont,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
