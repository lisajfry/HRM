import 'dart:convert';
import 'package:hrm/api/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:hrm/model/izin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IzinService {
  final String apiUrl = 'http://192.168.200.27:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<Izin>> getIzin() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/izin'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Izin.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load izin');
    }
  }

  Future<void> addIzin(Izin izin) async {
  String? token = await getToken();

  if (token == null) {
    throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
  }

  final response = await http.post(
    Uri.parse('$apiUrl/izin'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json', // Tambahkan header ini
    },
    body: json.encode({
      'tgl_mulai': izin.tgl_mulai,
      'tgl_selesai': izin.tgl_selesai,
      'alasan': izin.alasan,
      'keterangan': izin.keterangan,
    }),
  );

  // Jika terjadi redirect, tangani error
  if (response.statusCode == 302 || response.statusCode == 301) {
    throw Exception('Redirect detected. Please check your API route and authentication.');
  }

  if (response.statusCode != 201) {
    throw Exception('Failed to add izin: ${response.body}');
  }
}


  // Update izin with id_karyawan from token
  Future<void> updateIzin(Izin izin) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.put(
      Uri.parse('$apiUrl/izin/${izin.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'tgl_mulai': izin.tgl_mulai,
        'tgl_selesai': izin.tgl_selesai,
        'alasan': izin.alasan,
        'keterangan': izin.keterangan,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update izin: ${response.body}');
    }
  }

  // Delete izin
  Future<void> deleteIzin(int id) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.delete(
      Uri.parse('$apiUrl/izin/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete izin: ${response.body}');
    }
  }
}