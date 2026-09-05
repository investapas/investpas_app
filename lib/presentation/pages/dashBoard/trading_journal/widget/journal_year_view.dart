import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../bloc/trading_journal/journal_bloc.dart';
import '../../../../bloc/trading_journal/journal_event.dart';

class JournalYearView extends StatelessWidget {
  final int year;
  const JournalYearView({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*0.8),
      child: Column(
        children: [
          Text(
            year.toString(),
            style: AppTextStyles.headerTwo.copyWith(color: Colorz.textColor),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (_, index) {
              return _MiniMonth(year: year, month: index + 1);
            },
          ),
        ],
      ),
    );
  }
}

class _MiniMonth extends StatelessWidget {
  final int year;
  final int month;

  const _MiniMonth({required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startWeekday = firstDay.weekday % 7;

    final totalCells = daysInMonth + startWeekday;
    final rows = (totalCells / 7).ceil();

    return GestureDetector(
      onTap: () {
        context.read<JournalBloc>().add(
          SelectYearMonth(year, month),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              DateFormat('MMM').format(firstDay).toUpperCase(),
              style: AppTextStyles.semiBold.copyWith(
                fontWeight: FontWeight.w600,
                color: Colorz.textColor,
                fontSize: SizeConfig.smallerFont,
              ),
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['M','T','W','T','F','S','S']
                .map((e) => Expanded(
              child: Center(
                child: Text(
                  e,
                  style: AppTextStyles.semiBold.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colorz.textColor,
                    fontSize: SizeConfig.smallerCalenderFont,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.3),
          Column(
            children: List.generate(rows, (row) {
              return Row(
                children: List.generate(7, (col) {
                  final index = row * 7 + col;
                  final day = index - startWeekday + 1;

                  if (index < startWeekday || day > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 16));
                  }

                  return Expanded(
                    child: SizedBox(
                      height: 16,
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: AppTextStyles.semiBold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colorz.calenderDayColor,
                            fontSize: SizeConfig.smallerCalenderFont,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

}