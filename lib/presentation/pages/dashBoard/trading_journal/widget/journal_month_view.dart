import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../bloc/trading_journal/journal_bloc.dart';
import '../../../../bloc/trading_journal/journal_event.dart';

class JournalMonthView extends StatelessWidget {
  final DateTime selectedDate;
  const JournalMonthView({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.spaceBetween * 2,
          ),
          child: Text(
            DateFormat('MMMM yyyy').format(selectedDate),
            style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor)
          ),
        ),
        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime(2020),
          lastDay: DateTime(3000),
          rowHeight: 68,
          daysOfWeekHeight: 28,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            context.read<JournalBloc>().add(SelectJournalDate(selectedDay));
          },
          headerVisible: false,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,
            isTodayHighlighted: false,
            cellMargin: EdgeInsets.zero,
            cellPadding: EdgeInsets.zero,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.small,
            weekendStyle: AppTextStyles.small,
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text = ['S','M','T','W','T','F','S'][day.weekday % 7];
              return Center(
                child: Text(
                  text,
                  style: AppTextStyles.small.copyWith(
                    color: Colorz.textColor,
                    fontSize: SizeConfig.mediumFont
                  ),
                ),
              );
            },
            defaultBuilder: (context, date, _) {
              return _tableCell(date, selectedDate, false);
            },
            outsideBuilder: (context, date, _) {
              return _tableCell(date, selectedDate, true);
            },
            selectedBuilder: (context, date, _) {
              return _selectedCell(date);
            },
          ),
        ),
      ],
    );
  }

  bool _isFirstRow(DateTime date, DateTime focusedMonth) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    return date.day <= (7 - firstWeekday);
  }

  Widget _tableCell(DateTime date, DateTime selectedDate, bool outside) {
    final bool isFirstRow = _isFirstRow(date, selectedDate);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colorz.bottomPillBg),
          top: isFirstRow ? BorderSide(color: Colorz.bottomPillBg) : BorderSide.none,
          bottom: BorderSide(color: Colorz.bottomPillBg),
        ),
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: outside ? Colors.transparent : Colorz.calenderDateBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          date.day.toString().padLeft(2, '0'),
          style: AppTextStyles.small.copyWith(color: Colorz.textColor),
        ),
      ),
    );
  }

  Widget _selectedCell(DateTime date) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colorz.primary, width: 1.3),
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: Colorz.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          date.day.toString().padLeft(2, '0'),
          style: AppTextStyles.small.copyWith(color: Colorz.white),
        ),
      ),
    );
  }
}