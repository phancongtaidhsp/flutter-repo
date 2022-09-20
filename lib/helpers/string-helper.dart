import 'package:easy_localization/easy_localization.dart';

class StringHelper {
  static String formatCurrency(num? value, {bool isDecimal = true}) {
    if(value != null) {
      NumberFormat numberFormat = NumberFormat(isDecimal ? "#,##0.00" : "#,##0", "en_US");
      return numberFormat.format(value);
    } else {
      return '';
    }
  }

  static String formatAddress(num? value, {bool isDecimal = true}) {
    if(value != null) {
      NumberFormat numberFormat = NumberFormat(isDecimal ? "#,##0.0" : "#,##0", "en_US");
      return numberFormat.format(value);
    } else {
      return '';
    }
  }
}