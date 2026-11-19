import 'package:intl/intl.dart';

class Utils {
  static String formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';

  static String formatDate(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).format(date);

  static String formateTimeNow(DateTime time, {String? locale}) =>
      DateFormat.Hm(locale).format(time);
}
