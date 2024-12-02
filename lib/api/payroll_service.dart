import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PayrollService {
  final String _baseUrl = 'http://192.168.200.33:8000/api'; // Ganti dengan URL API Anda


  Future<Map<String, dynamic>> fetchPayrollSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token'); // Asumsi token disimpan di SharedPreferences

      if (token == null) {
        throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/payroll-summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Log respons dari server untuk debugging
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Gagal memuat ringkasan payroll: ${response.statusCode}');
      }
    } catch (e) {
      // Memberikan informasi kesalahan yang lebih spesifik
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
