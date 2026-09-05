import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../Widgets/live_price_widget.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../core/utils/navigationService.dart';
import '../../../../../data/models/market_item.dart';
import '../../../../../presentation/bloc/trading_terminal/terminal_bloc.dart';
import '../../../../../presentation/bloc/trading_terminal/terminal_event.dart';
import '../../../../../routes/appRoutes.dart';

class GlobalView extends StatefulWidget {
  final List<MarketItem> items;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const GlobalView({
    super.key,
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  @override
  State<GlobalView> createState() => _GlobalViewState();
}

class _GlobalViewState extends State<GlobalView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // When Global tab becomes visible, re-subscribe instruments for live prices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.items.isNotEmpty) {
        context.read<TerminalBloc>().add(SubscribeAdditionalItemsEvent(widget.items));
      }
    });
  }

  @override
  void didUpdateWidget(GlobalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-subscribe when items change (new page loaded)
    if (widget.items != oldWidget.items && widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TerminalBloc>().add(SubscribeAdditionalItemsEvent(widget.items));
        }
      });
    }
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
          "No instruments found",
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
        return _item(widget.items[index]);
      },
      separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor, thickness: 1),
    );
  }

  Widget _item(MarketItem item) {
    return InkWell(
      onTap: () => NavigatorService.pushNamed(AppRoutes.stockDetailsPage, arguments: item),
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
                  Text(
                    '${item.exchange}  •  Lot: ${item.lotSize}',
                    style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont,
                    ),
                  ),
                ],
              ),
            ),
            LivePriceWidget(
              securityId: item.securityId,
              showChange: true,
              prevClose: item.close,
              style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont),
            ),
          ],
        ),
      ),
    );
  }
}
