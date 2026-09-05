import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../Widgets/live_price_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/navigationService.dart';
import '../../../data/models/market_item.dart';
import '../../../data/services/live_price_service.dart';
import '../../../routes/appRoutes.dart';
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';
import '../../bloc/watchlist/watchlist_state.dart';

class WatchlistPage extends StatefulWidget {
  final VoidCallback? onBack;
  const WatchlistPage({super.key, this.onBack});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  // ── Normal-mode local filter ───────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // ── Add-stock search mode ──────────────────────────────────────────────────
  bool _isAddMode = false;
  final TextEditingController _addController = TextEditingController();
  Timer? _addDebounce;
  List<MarketItem> _apiResults = [];
  bool _isApiLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<WatchlistBloc>().add(LoadWatchlist());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addController.dispose();
    _addDebounce?.cancel();
    super.dispose();
  }

  // ── Subscribe loaded items for live prices ─────────────────────────────────
  void _subscribeWatchlistPrices(List<MarketItem> items) {
    if (items.isNotEmpty && mounted) {
      context.read<TerminalBloc>().add(SubscribeAdditionalItemsEvent(items));
    }
  }

  // ── Enter / exit add mode ──────────────────────────────────────────────────
  void _enterAddMode() {
    setState(() {
      _isAddMode = true;
      _apiResults = [];
      _isApiLoading = false;
    });
  }

  void _exitAddMode() {
    _addDebounce?.cancel();
    _addController.clear();
    setState(() {
      _isAddMode = false;
      _apiResults = [];
      _isApiLoading = false;
    });
  }

  // ── Debounced API search ───────────────────────────────────────────────────
  void _onAddSearch(String query) {
    _addDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() { _apiResults = []; _isApiLoading = false; });
      return;
    }
    setState(() => _isApiLoading = true);
    _addDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final resp = await ApiHelper.get(
            '${ApiEndpoints.searchApi}?search=${Uri.encodeComponent(query.trim())}');
        if (!mounted) return;
        final list = ((resp['data'] as List?) ?? []).map<MarketItem>((e) => MarketItem(
          securityId:      e['securityId']?.toString() ?? '',
          name:            e['name']            ?? '',
          symbol:          e['symbol']          ?? '',
          exchange:        e['exchange']        ?? '',
          exchangeSegment: e['exchangeSegment'] ?? '',
          lotSize:         e['lotSize']?.toString() ?? '1',
          isUp:            true,
          strikePrice:     e['strikePrice']?.toString(),
          optionType:      e['optionType']?.toString(),
          expiry:          e['expiry']?.toString(),
        )).toList();
        // Subscribe results for live prices
        if (list.isNotEmpty) {
          LivePriceService.instance.subscribe(list
              .map((i) => {
                    'ExchangeSegment': i.exchangeSegment,
                    'SecurityId':      i.securityId,
                  })
              .toList());
        }
        setState(() { _apiResults = list; _isApiLoading = false; });
      } catch (_) {
        if (mounted) setState(() => _isApiLoading = false);
      }
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isAddMode) {
          _exitAddMode();
        } else if (widget.onBack != null) {
          widget.onBack!();
        } else {
          NavigatorService.goBack();
        }
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          // "+" FAB — only visible in normal mode
          floatingActionButton: _isAddMode
              ? null
              : FloatingActionButton(
                  onPressed: _enterAddMode,
                  backgroundColor: Colorz.primary,
                  elevation: 4,
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: _isAddMode ? _buildAddMode() : _buildNormalMode(),
          ),
        ),
      ),
    );
  }

  // ── Normal mode ────────────────────────────────────────────────────────────
  Widget _buildNormalMode() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state.allItems.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => _subscribeWatchlistPrices(state.allItems));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.sp),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  InkWell(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        NavigatorService.goBack();
                      }
                    },
                    child: CircleWidget(
                      backgroundColor: Colorz.white,
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colorz.hintTextColor),
                    ),
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween),
                  Text(
                    "Watchlist",
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.headerTwoFont,
                      color: Colorz.textColor,
                    ),
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween * 1.5),
                  // Local filter search
                  Container(
                    decoration: BoxDecoration(
                      color: Colorz.bottomPillBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colorz.hintTextColor),
                        SizeConfig.horizontalSpace(
                            width: SizeConfig.spaceBetween * 0.5),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.medium
                                .copyWith(color: Colorz.textColor),
                            decoration: InputDecoration(
                              hintText: "Filter watchlist...",
                              hintStyle: AppTextStyles.medium
                                  .copyWith(color: Colorz.hintTextColor),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) => context
                                .read<WatchlistBloc>()
                                .add(SearchWatchlistLocal(v)),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context
                                  .read<WatchlistBloc>()
                                  .add(SearchWatchlistLocal(''));
                            },
                            child: Icon(Icons.close_rounded,
                                color: Colorz.hintTextColor, size: 18),
                          ),
                      ],
                    ),
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween * 1.5),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colorz.primary))
                  : state.visibleItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 2),
                          itemCount: state.visibleItems.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Colorz.dividerColor, thickness: 1),
                          itemBuilder: (context, index) {
                            final item = state.visibleItems[index];
                            return _WatchlistItemRow(
                              item: item,
                              onRemove: () => context
                                  .read<WatchlistBloc>()
                                  .add(RemoveFromWatchlist(item.securityId)),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  // ── Add-stock mode ─────────────────────────────────────────────────────────
  Widget _buildAddMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50.sp),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  GestureDetector(
                    onTap: _exitAddMode,
                    child: CircleWidget(
                      backgroundColor: Colorz.white,
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colorz.hintTextColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Add Stock",
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: SizeConfig.headerTwoFont,
                      color: Colorz.textColor,
                    ),
                  ),
                ],
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
              // API search bar
              Container(
                decoration: BoxDecoration(
                  color: Colorz.bottomPillBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colorz.primary),
                    SizeConfig.horizontalSpace(
                        width: SizeConfig.spaceBetween * 0.5),
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        autofocus: true,
                        style: AppTextStyles.medium
                            .copyWith(color: Colorz.textColor),
                        decoration: InputDecoration(
                          hintText: 'Search stocks (e.g. TCS, BANKNIFTY)',
                          hintStyle: AppTextStyles.medium
                              .copyWith(color: Colorz.hintTextColor),
                          border: InputBorder.none,
                        ),
                        onChanged: _onAddSearch,
                      ),
                    ),
                    if (_addController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _addController.clear();
                          setState(() {
                            _apiResults = [];
                            _isApiLoading = false;
                          });
                        },
                        child: Icon(Icons.close_rounded,
                            color: Colorz.hintTextColor, size: 18),
                      ),
                  ],
                ),
              ),
              SizeConfig.verticalSpace(
                  height: SizeConfig.spaceBetween * 1.5),
            ],
          ),
        ),
        // Results area
        Expanded(child: _buildAddResults()),
      ],
    );
  }

  Widget _buildAddResults() {
    if (_isApiLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colorz.primary));
    }
    if (_addController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 56, color: Colorz.hintTextColor),
            const SizedBox(height: 12),
            Text(
              'Search for any stock or index',
              style: AppTextStyles.medium
                  .copyWith(color: Colorz.hintTextColor),
            ),
          ],
        ),
      );
    }
    if (_apiResults.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: AppTextStyles.semiBold.copyWith(
              color: Colorz.textColor, fontSize: SizeConfig.largeFont),
        ),
      );
    }
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, wState) {
        return ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spaceBetween * 2),
          itemCount: _apiResults.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colorz.dividerColor, thickness: 1),
          itemBuilder: (context, index) {
            final item = _apiResults[index];
            final inWatchlist =
                wState.watchlistIds.contains(item.securityId);
            return _AddStockRow(
              item: item,
              inWatchlist: inWatchlist,
              onAdd: () => context
                  .read<WatchlistBloc>()
                  .add(AddToWatchlist(item.securityId)),
              onRemove: () => context
                  .read<WatchlistBloc>()
                  .add(RemoveFromWatchlist(item.securityId)),
              onTap: () async {
                await NavigatorService.pushNamed(
                    AppRoutes.stockDetailsPage,
                    arguments: item);
                if (mounted) _exitAddMode();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.candlestick_chart_outlined,
              size: 64, color: Colorz.hintTextColor),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
          Text(
            "Nothing Here",
            style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.headerThreeFont,
              color: Colorz.textColor,
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          Text(
            "Tap the  +  button to add stocks\nto your watchlist",
            textAlign: TextAlign.center,
            style:
                AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
          ),
        ],
      ),
    );
  }
}

// ── Watchlist item row (existing watchlist) ────────────────────────────────────
class _WatchlistItemRow extends StatelessWidget {
  final MarketItem item;
  final VoidCallback onRemove;

  const _WatchlistItemRow({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          NavigatorService.pushNamed(AppRoutes.stockDetailsPage, arguments: item),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 0.8),
        child: Row(
          children: [
            // Name + exchange
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.hintTextColor2,
                      fontSize: SizeConfig.mediumFont,
                    ),
                  ),
                  SizeConfig.verticalSpace(height: 3),
                  Text(
                    "${item.exchange}  •  ${item.symbol}",
                    style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallFont,
                    ),
                  ),
                ],
              ),
            ),
            // Live price
            Padding(
              padding: EdgeInsets.only(right: SizeConfig.spaceBetween),
              child: LivePriceWidget(
                securityId: item.securityId,
                showChange: true,
                prevClose: item.close,
                style: AppTextStyles.semiBold
                    .copyWith(fontSize: SizeConfig.mediumFont),
              ),
            ),
            // Option type badge
            if (item.optionType != null && item.optionType!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(right: SizeConfig.spaceBetween),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colorz.bottomPillBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.optionType!,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: SizeConfig.smallerFont,
                    color: Colorz.textColor,
                  ),
                ),
              ),
            // Remove button
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colorz.redColor, width: 1.5),
                ),
                child: Icon(Icons.remove_rounded,
                    color: Colorz.redColor, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add-stock search result row ────────────────────────────────────────────────
class _AddStockRow extends StatelessWidget {
  final MarketItem item;
  final bool inWatchlist;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _AddStockRow({
    required this.item,
    required this.inWatchlist,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Name + lot size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.medium
                        .copyWith(color: Colorz.hintTextColor2),
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween * 0.5),
                  Text(
                    '${item.exchange}  •  ${item.symbol}',
                    style: AppTextStyles.medium
                        .copyWith(color: Colorz.hintTextColor,
                            fontSize: SizeConfig.smallFont),
                  ),
                ],
              ),
            ),
            // Live price
            LivePriceWidget(
              securityId: item.securityId,
              showChange: true,
              prevClose: item.close,
              style: AppTextStyles.semiBold
                  .copyWith(fontSize: SizeConfig.mediumFont),
            ),
            const SizedBox(width: 10),
            // Add / Remove button
            GestureDetector(
              onTap: inWatchlist ? onRemove : onAdd,
              child: inWatchlist
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colorz.redColor, width: 1.5),
                      ),
                      child: Icon(Icons.remove_rounded,
                          color: Colorz.redColor, size: 16),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colorz.primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: Colorz.primary, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            'Add',
                            style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.primary,
                              fontSize: SizeConfig.smallerFont,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
