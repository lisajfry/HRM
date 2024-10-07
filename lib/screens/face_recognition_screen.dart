import 'dart:convert';
import 'dart:io'; // For file handling
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class FaceRecognitionScreen extends StatelessWidget {
  final String action;
  final XFile? pickedImage;
  final String time;
  final String date;

  const FaceRecognitionScreen({
    Key? key,
    required this.action,
    required this.pickedImage,
    required this.time,
    required this.date,
  }) : super(key: key);

  Future<void> _submitAttendance(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    print("Token: $token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan. Silakan login kembali.')),
      );
      return;
    }

    // Ambil profil karyawan
    final profileResponse = await ApiService.getRequest(
      'profile',
      {'Authorization': 'Bearer $token'},
    );

    if (profileResponse.statusCode == 200) {
      final karyawanData = json.decode(profileResponse.body)['profile'];
      final String idKaryawan = karyawanData['id'].toString();

      // Ambil waktu secara dinamis
      final DateTime now = DateTime.now();
      final String formattedTime = DateFormat('HH:mm:ss').format(now);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Ambil lokasi secara dinamis
      Position? position;
      try {
        position = await _determinePosition(); // Fungsi untuk cek izin dan ambil posisi
      } catch (e) {
        print('Failed to get location: $e');
      }

      double? latitude = position?.latitude;
      double? longitude = position?.longitude;

      final endpoint = action == 'Clock In' ? 'absensi/masuk' : 'absensi/keluar';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        'id_karyawan': idKaryawan,
        'tanggal': formattedDate,
        'jam_masuk': action == 'Clock In' ? formattedTime : null,
        'jam_keluar': action == 'Clock Out' ? formattedTime : null,
        'foto_masuk': action == 'Clock In' ? await getFileAsBase64(pickedImage?.path) : null,
        'foto_keluar': action == 'Clock Out' ? await getFileAsBase64(pickedImage?.path) : null,
        'latitude_masuk': action == 'Clock In' ? latitude : null,
        'longitude_masuk': action == 'Clock In' ? longitude : null,
        'latitude_keluar': action == 'Clock Out' ? latitude : null,
        'longitude_keluar': action == 'Clock Out' ? longitude : null,
        'lokasi_masuk': action == 'Clock In' ? 'Lokasi Dinamis' : null,
        'lokasi_keluar': action == 'Clock Out' ? 'Lokasi Dinamis' : null,
        'status': 'hadir',
      };

      print("Sending Attendance Data:");
      body.forEach((key, value) {
        print('$key: ${value != null ? value : 'null'}');
      });

      final attendanceResponse = await ApiService.postRequest(endpoint, headers, body);

      print("Response Status: ${attendanceResponse.statusCode}");
      print("Response Body: ${attendanceResponse.body}");

      if (attendanceResponse.statusCode == 201 || attendanceResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Absensi berhasil dicatat')),
        );
        _showData(context, body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat absensi')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data karyawan')),
      );
    }
  }

  // Fungsi untuk menentukan posisi perangkat dan izin
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak permanen, tidak bisa meminta izin lagi.');
    }

    // Jika izin diberikan, ambil posisi perangkat
    return await Geolocator.getCurrentPosition();
  }

  // Convert image file to Base64 string for API submission
  Future<String?> getFileAsBase64(String? filePath) async {
    if (filePath == null) return null;
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  // Display data in a dialog
  void _showData(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Data Absensi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: data.entries.map((entry) {
                return Text('${entry.key}: ${entry.value != null ? entry.value : 'null'}');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Kehadiran'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Catat Kehadiran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: pickedImage != null
                  ? Image.file(
                      File(pickedImage!.path),
                      fit: BoxFit.cover,
                    )
                  : Center(child: Text('Face Recognition Placeholder')),
            ),
            SizedBox(height: 20),
            Text(action == 'Catat Kehadiran' ? 'Jam Masuk: $time' : 'Jam Keluar: $time'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitAttendance(context),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
