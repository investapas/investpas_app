import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../bloc/trading_journal/journal_bloc.dart';
import '../../../../bloc/trading_journal/journal_event.dart';
import '../../../../bloc/trading_journal/journal_state.dart';

class JournalListView extends StatelessWidget {
  const JournalListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final startOfWeek =
        state.selectedDate.subtract(Duration(days: state.selectedDate.weekday % 7));
        final days = List.generate(
          7,
              (i) => startOfWeek.add(Duration(days: i)),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week navigation: left arrow | date label | right arrow
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<JournalBloc>().add(
                      SelectJournalDate(
                        state.selectedDate.subtract(const Duration(days: 7)),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colorz.bottomPillBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.chevron_left_rounded,
                          size: 20, color: Colorz.textColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${DateFormat('d MMM').format(startOfWeek)} – '
                        '${DateFormat('d MMM yyyy').format(startOfWeek.add(const Duration(days: 6)))}',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.smallFont,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<JournalBloc>().add(
                      SelectJournalDate(
                        state.selectedDate.add(const Duration(days: 7)),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colorz.bottomPillBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 20, color: Colorz.textColor),
                    ),
                  ),
                ],
              ),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (_, index) {
                  final day = days[index];
                  final selected = isSameDay(day, state.selectedDate);

                  return GestureDetector(
                    onTap: () {
                      context.read<JournalBloc>().add(SelectJournalDate(day));
                    },
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                          Text(
                            DateFormat('E').format(day)[0],
                            style: AppTextStyles.small.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.mediumFont
                            ),
                          ),
                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                          Stack(
                            children: [
                              Container(
                                height: 76,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selected
                                        ? Colorz.primary
                                        : Colorz.bottomPillBg,
                                    width: selected ? 1.3 : 1,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colorz.primary
                                        : Colorz.calenderDateBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    day.day.toString(),
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: SizeConfig.smallerFont,
                                      color: selected
                                          ? Colors.white
                                          : Colorz.textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colorz.bottomPillBg,thickness: 2),
            _Tabs(),
          ],
        );
      },
    );
  }
}

class _Tabs extends StatefulWidget {
  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> {
  int index = 0; // Changed from 1 to 0 to start with Notes tab

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        // Get date string
        final dateKey = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';
        
        // Get trades for selected date
        final tradesForDate = state.tradesByDate[dateKey] ?? [];
        
        // Get positions (today's only for now, or based on positionsDate)
        final todayPositions = state.positions;
        
        // Get orders from trades
        final allOrders = <String, List<dynamic>>{}; // date -> orders
        state.tradesByDate.forEach((date, trades) {
          for (var trade in trades) {
            allOrders.putIfAbsent(date, () => []);
            allOrders[date]!.addAll(trade.buyOrders);
            allOrders[date]!.addAll(trade.sellOrders);
          }
        });

        final items = [
          ("Notes", tradesForDate.length),
          ("Positions", todayPositions.length),
          ("Orders", allOrders[dateKey]?.length ?? 0),
        ];

        return Column(
          children: [
            Row(
              children: List.generate(items.length, (i) {
                final active = index == i;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                i == 0 ? Assets.notesSvg : (i == 1 ? Assets.positionSvg : Assets.notesSvg),
                                height: 15,
                                width: 15,
                                colorFilter: ColorFilter.mode(
                                  active ? Colorz.primary : Colorz.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.8),
                              Text(
                                "${items[i].$1} (${items[i].$2})",
                                style: AppTextStyles.small.copyWith(
                                  color: active ? Colorz.primary : Colorz.textColor,
                                )
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 1,
                          color: active ? Colorz.primary : Colors.transparent,
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            // Tab content
            if (index == 0) // Notes tab - show trades
              _buildNotesTab(state, tradesForDate)
            else if (index == 1) // Positions tab
              _buildPositionsTab(todayPositions)
            else // Orders tab
              _buildOrdersTab(allOrders, dateKey),
          ],
        );
      },
    );
  }

  Widget _buildNotesTab(JournalState state, List<dynamic> trades) {
    if (state.isLoadingTrades) {
      return Padding(
        padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
        child: Center(child: CircularProgressIndicator(color: Colorz.primary)),
      );
    }

    if (trades.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
        child: Center(
          child: Text(
            "No trades for this date",
            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: trades.map((trade) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween, vertical: SizeConfig.spaceBetween * 0.5),
            margin: EdgeInsets.only(bottom: SizeConfig.spaceBetween),
            decoration: BoxDecoration(
              border: Border.all(color: Colorz.bottomPillBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trade.customSymbol,
                        style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trade.status == 'COMPLETED'
                            ? Colorz.primary.withValues(alpha: 0.1)
                            : (trade.status == 'PARTIAL'
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trade.status,
                        style: AppTextStyles.small.copyWith(
                          color: trade.status == 'COMPLETED'
                              ? Colorz.primary
                              : (trade.status == 'PARTIAL' ? Colors.orange : Colors.grey),
                          fontSize: SizeConfig.smallerFont,
                        ),
                      ),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Buy: ${trade.totalBuyQty} @ ₹${trade.avgBuyPrice.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                    Text(
                      "Sell: ${trade.totalSellQty} @ ₹${trade.avgSellPrice.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Gross: ₹${trade.grossPnL?.toStringAsFixed(2) ?? '0.00'}",
                      style: AppTextStyles.small.copyWith(
                        color: (trade.grossPnL ?? 0) >= 0 ? Colorz.primary : Colorz.redColor,
                      ),
                    ),
                    Text(
                      "Net: ₹${trade.netPnL?.toStringAsFixed(2) ?? '0.00'}",
                      style: AppTextStyles.semiBold.copyWith(
                        color: (trade.netPnL ?? 0) >= 0 ? Colorz.primary : Colorz.redColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPositionsTab(List<dynamic> positions) {
    if (positions.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
        child: Center(
          child: Text(
            "No open positions today",
            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: positions.map((position) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween, vertical: SizeConfig.spaceBetween * 0.5),
            margin: EdgeInsets.only(bottom: SizeConfig.spaceBetween),
            decoration: BoxDecoration(
              border: Border.all(color: Colorz.bottomPillBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        position.tradingSymbol,
                        style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colorz.lightPurpleColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        position.productType,
                        style: AppTextStyles.small.copyWith(color: Colorz.purpleColor),
                      ),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Qty: ${position.netQty}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                    Text(
                      "Avg: ₹${position.buyAvg.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                    Text(
                      "LTP: ₹${position.ltp.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      position.exchangeSegment,
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                    Text(
                      "P&L: ₹${position.pnl.toStringAsFixed(2)}",
                      style: AppTextStyles.semiBold.copyWith(
                        color: position.pnl >= 0 ? Colorz.primary : Colorz.redColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersTab(Map<String, List<dynamic>> allOrders, String dateKey) {
    final ordersForDate = allOrders[dateKey] ?? [];

    if (ordersForDate.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
        child: Center(
          child: Text(
            "No orders for this date",
            style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: ordersForDate.map((order) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween, vertical: SizeConfig.spaceBetween * 0.5),
            margin: EdgeInsets.only(bottom: SizeConfig.spaceBetween),
            decoration: BoxDecoration(
              border: Border.all(color: Colorz.bottomPillBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order ID: ${order.orderId.substring(0, 8)}...",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                    Text(
                      "Qty: ${order.tradedQuantity}",
                      style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Price: ₹${order.tradedPrice.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                    ),
                    Text(
                      "Charges: ₹${order.charges.toStringAsFixed(2)}",
                      style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                Text(
                  order.exchangeTime,
                  style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
