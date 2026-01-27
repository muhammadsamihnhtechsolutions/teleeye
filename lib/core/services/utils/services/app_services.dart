import 'package:intl/intl.dart';

class AppServices {
  String formatedDateAndTime(DateTime date) {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String formatedDate = DateFormat('dd/MM/yyyy').format(date);

    if (formatedDate == currentDate) {
      return DateFormat('hh:mm a').format(date);
    } else {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }
  }
}
