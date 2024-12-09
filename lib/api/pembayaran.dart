import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PembayaranService {
  final String apiUrl = 'http://192.168.200.33:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Menambahkan pembayaran kasbon
  Future<void> bayarKasbon(int kasbonId, String tanggalPembayaran, double jumlahDibayar) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/pembayaran'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'kasbon_id': kasbonId,
        'tanggal_pembayaran': tanggalPembayaran,
        'jumlah_dibayar': jumlahDibayar,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit pembayaran: ${response.body}');
    }
  }
}
