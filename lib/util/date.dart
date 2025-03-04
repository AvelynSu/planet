import 'package:intl/intl.dart';

enum DateType { month, day }

enum TimeType { am, pm }

class Date {
  static DateTime clearDate(DateTime? date, {DateType queryBy = DateType.day}) {
    var clearDate = date ?? DateTime.now();
    if (queryBy == DateType.month) {
      return DateTime(clearDate.year, clearDate.month, 1);
    }
    return DateTime(clearDate.year, clearDate.month, clearDate.day);
  }

  static String dateFormat({required String pattern, DateTime? date}) {
    if (date == null) {
      return "";
    } else {
      return DateFormat(pattern).format(date);
    }
  }

  static bool isSame(DateTime a, DateTime b) => clearDate(a) == clearDate(b);

  static bool isSameMonth(DateTime a, DateTime b) =>
      clearDate(DateTime(a.year, a.month, 1)) ==
      clearDate(DateTime(b.year, b.month, 1));

  static String getKoreanWeeks(int value) {
    if (value == 1) {
      return '월';
    } else if (value == 2) {
      return '화';
    } else if (value == 3) {
      return '수';
    } else if (value == 4) {
      return '목';
    } else if (value == 5) {
      return '금';
    } else if (value == 6) {
      return '토';
    } else if (value == 7) {
      return '일';
    }
    return '';
  }
}
