part of './Extensions.dart';

// ignore: public_member_api_docs
extension Extension on int {
  ///Returns the name of the month if the given number is a valid month index
  String get toMonthName {
    return this > 0 ? months[this - 1] : '$this';
  }

  ///Returns the given value in the format of [25%]
  String get toPercentage => toDouble().toPercentage;

  ///List of month names
  static const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  ///Checks if this number is a leap year or not
  bool get isLeapYear {
    final int year = toInt();
    if (year % 400 == 0) {
      return true;
    } else if (year % 100 == 0) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    } else {
      return false;
    }
  }

  ///Returns [DateTime] from the given number
  DateTime get toDate => DateTime.fromMillisecondsSinceEpoch(toInt());
}
