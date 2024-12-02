import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';




String getFormattedDateTime(DateTime dateTime) {
  final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(dateTime);
  final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
  return '$formattedDate, $formattedTime WIB';
}



Future<String> getFileAsBase64(String? filePath) async {
  if (filePath == null) {
    return ''; // Return empty string if there's no file
  }

  final File file = File(filePath);
  final bytes = await file.readAsBytes();
  return base64Encode(bytes); // Encode file to base64
}

