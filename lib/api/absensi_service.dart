import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hrm/model/absen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiService {
  final String baseUrl = 'http://192.168.200.33:8000/api/';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Absen Masuk
  Future<Absensi> absenMasuk(Map<String, dynamic> data) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}absensi/masuk'), // gunakan endpoint yang benar
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'tanggal': data['tanggal'],
          'jam_masuk': data['jam_masuk'],
          'foto_masuk': data['foto_masuk'],
          'status': data['status'],
        }),
      );

      if (response.statusCode == 201) {
        // Menangani respons JSON dan mengembalikan objek Absensi
        return Absensi.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Gagal melakukan absen masuk: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}



