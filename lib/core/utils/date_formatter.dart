import 'package:intl/intl.dart';

class DateFormatter {
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDayDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }
  
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}
