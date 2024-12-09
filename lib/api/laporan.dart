import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LaporanKasbonService {
  final String apiUrl = 'http://192.168.200.33:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Mendapatkan laporan kasbon
  Future<Map<String, double>> getLaporanKasbon() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/laporan'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return {
        'total_kasbon': jsonResponse['total_kasbon'],
        'total_dibayar': jsonResponse['total_dibayar'],
        'sisa_kasbon': jsonResponse['sisa_kasbon'],
      };
    } else {
      throw Exception('Failed to fetch kasbon report');
    }
  }
}
