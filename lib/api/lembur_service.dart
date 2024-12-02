import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/lembur.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LemburService {
  final String baseUrl = 'http://192.168.200.33:8000/api'; // Ganti dengan URL backend Anda

  // Fetch token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Fetch lembur for the logged-in user with optional month and year parameters
  Future<List<Lembur>> fetchLembur({int? bulan, int? tahun}) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    // Build the query parameters for the API
    String url = '$baseUrl/lembur';
    if (bulan != null && tahun != null) {
      url = '$url?bulan=$bulan&tahun=$tahun'; // Adding query params for month and year
    }

    // Make the request to the API with the Bearer token
    final response = await http.get(Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'}); // Send token in the headers

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lembur.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data lembur');
    }
  }
}
