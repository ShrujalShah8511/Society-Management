import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatArea(double? sqFt) {
    if (sqFt == null) return '0 sq. ft.';
    final formatter = NumberFormat('#,##0.##');
    return '${formatter.format(sqFt)} sq. ft.';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatEnumString(String value) {
    return value.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
