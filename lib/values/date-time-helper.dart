import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class DateTimeHelper {
  static String timeAgo(String dateInput) {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    var formatString = "yyyy-MM-ddThh:mm:ssZ";
    DateTime format1 = new DateFormat(formatString).parse(dateInput, true).toLocal();
    return timeago.format(format1, locale: 'eng');
  }
}
