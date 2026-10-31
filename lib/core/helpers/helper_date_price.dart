import 'package:intl/intl.dart';

class Utils {
  static String formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';

  static String formatDate(DateTime date) => DateFormat.yMMMd().format(date);
  static String formateTimeNow(DateTime time) => DateFormat.Hm().format(time);
}
