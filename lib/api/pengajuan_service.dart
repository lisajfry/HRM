import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KasbonService {
  final String apiUrl = 'http://192.168.200.33:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Mengajukan kasbon
  Future<Map<String, dynamic>> ajukanKasbon(String tanggalPengajuan, double jumlahKasbon, String? keterangan) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/kasbon'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'tanggal_pengajuan': tanggalPengajuan,
        'jumlah_kasbon': jumlahKasbon,
        'keterangan': keterangan ?? '',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit kasbon: ${response.body}');
    }

    // Mengembalikan data kasbon yang berhasil diajukan
    return json.decode(response.body);
  }
}
