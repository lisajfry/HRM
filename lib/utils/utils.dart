import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(dateTime);
  final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
  return '$formattedDate, $formattedTime WIB';
}
