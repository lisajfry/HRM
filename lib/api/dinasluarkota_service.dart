import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hrm/model/dinasluarkota.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DinasLuarKotaService {
  final String apiUrl = 'http://192.168.200.33:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get Dinas Luar Kota
  Future<List<DinasLuarKota>> getDinasLuarKota() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/dinas-luar-kota'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Status Code: ${response.statusCode}');
    print('Respons Body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DinasLuarKota.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data dinas luar kota');
    }
  }

  // Add Dinas Luar Kota
  Future<void> addDinasLuarKota(DinasLuarKota dinas) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    // Format tanggal sesuai dengan format MySQL 'YYYY-MM-DD'
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedTglBerangkat = formatter.format(dinas.tglBerangkat);
    final String formattedTglKembali = formatter.format(dinas.tglKembali);

    final response = await http.post(
      Uri.parse('$apiUrl/dinas-luar-kota'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode({
        'id_karyawan': dinas.idKaryawan, // Pastikan untuk mengisi id_karyawan
        'tgl_berangkat': formattedTglBerangkat,
        'tgl_kembali': formattedTglKembali,
        'kota_tujuan': dinas.kotaTujuan,
        'keperluan': dinas.keperluan,
        'biaya_transport': dinas.biayaTransport,
        'biaya_penginapan': dinas.biayaPenginapan,
        'uang_harian': dinas.uangHarian,
        'total_biaya': dinas.totalBiaya,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Respons Body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Gagal menambah data dinas luar kota');
    }
  }

  // Update Dinas Luar Kota
  Future<void> updateDinasLuarKota(DinasLuarKota dinas) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/dinas-luar-kota/${dinas.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tgl_berangkat': dinas.tglBerangkat.toIso8601String(),
          'tgl_kembali': dinas.tglKembali.toIso8601String(),
          'kota_tujuan': dinas.kotaTujuan,
          'keperluan': dinas.keperluan,
          'biaya_transport': dinas.biayaTransport,
          'biaya_penginapan': dinas.biayaPenginapan,
          'uang_harian': dinas.uangHarian,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Respons Body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception('Gagal memperbarui data: ${error['message'] ?? 'Tidak diketahui'}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal memperbarui data dinas luar kota');
    }
  }

  // Delete Dinas Luar Kota
  Future<void> deleteDinasLuarKota(int id) async {
  String? token = await getToken();
  if (token == null) {
    throw Exception('Token tidak ditemukan');
  }

  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/dinas-luar-kota/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Respons Body: ${response.body}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Gagal menghapus data dinas luar kota');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Gagal menghapus data dinas luar kota');
  }
}

}
