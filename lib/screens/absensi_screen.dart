import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/face_recognition_screen.dart'; // Import yang benar
import 'package:hrm/api/absensi_service.dart'; // Import yang benar
import 'package:hrm/model/absen.dart'; // Import yang benar
import 'package:hrm/utils/utils.dart';
import 'package:hrm/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'dart:convert';
import 'dart:typed_data';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  Map<String, dynamic>? karyawanData;
  bool isLoading = true;
  late DateTime currentDateTime;
  List<Absensi> riwayatAbsensi = [];

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    _fetchKaryawanData();
    fetchRiwayatAbsensi(); // Panggil fungsi untuk mengambil riwayat absensi
  }

  // Mengambil data karyawan dari API
  Future<void> _fetchKaryawanData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      _showMessage('No token found', isError: true);
      return;
    }

    try {
      final response = await ApiService.getRequest(
        'profile',
        {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          karyawanData = json.decode(response.body)['profile'];
          isLoading = false;
        });
      } else {
        _showMessage('Failed to load user data', isError: true);
      }
    } catch (e) {
      _showMessage('Error loading user data: $e', isError: true);
    }
  }


  void fetchRiwayatAbsensi() async {
  AbsensiService absensiService = AbsensiService();

  try {
    // Mengambil data dari AbsensiService
    List<Absensi> absensi = await absensiService.getAbsensi();

    // Simpan data ke dalam state dan perbarui UI
    setState(() {
      riwayatAbsensi = absensi;
    });

    print('Data Riwayat Absensi: $riwayatAbsensi');
  } catch (e) {
    _showMessage('Error fetching attendance history: $e', isError: true);
  }
}



  // Menampilkan pesan menggunakan snackbar
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Absent'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (karyawanData != null)
                    buildProfileSection(karyawanData!, currentDateTime),
                  SizedBox(height: 20),
                  buildAttendanceSegment(),
                  SizedBox(height: 20),
                  buildActionButtons(context), // Tombol aksi
                  SizedBox(height: 20),
                  buildRiwayatAbsensiList(), // Tambahkan list riwayat absensi
                ],
              ),
            ),
    );
  }


// Widget untuk menampilkan daftar riwayat absensi
Widget buildRiwayatAbsensiList() {
  if (riwayatAbsensi.isEmpty) {
    return Text('Tidak ada data absensi.');
  }

  return Expanded(
    child: ListView.builder(
      itemCount: riwayatAbsensi.length,
      itemBuilder: (context, index) {
        final absensi = riwayatAbsensi[index];

        // Decode Base64 menjadi Uint8List
        Uint8List? imageBytes;
        if (absensi.fotoMasuk != null && absensi.fotoMasuk!.isNotEmpty) {
          print('Riwayat Absensi: $riwayatAbsensi');
          try {
            imageBytes = base64Decode(absensi.fotoMasuk!);
          } catch (e) {
            imageBytes = null; // Jika gagal decode, set null
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image_not_supported, color: Colors.grey), // Ikon default jika gambar kosong
            title: Text('Tanggal: ${absensi.tanggal ?? '-'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jam Masuk: ${absensi.jamMasuk ?? '-'}'),
                Text('Status: ${absensi.status ?? '-'}'),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      },
    ),
  );
}



  // Menampilkan tombol untuk absensi
  Widget buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Ambil waktu dan tanggal saat ini
            final now = DateTime.now();
            final String time = DateFormat('HH:mm:ss').format(now);
            final String date = DateFormat('yyyy-MM-dd').format(now);

            // Navigasi ke FaceRecognitionScreen untuk melakukan absensi masuk
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FaceRecognitionScreen(
                  action: 'Clock In', // Aksi saat navigasi
                  time: time,
                  date: date,
                ),
              ),
            );
          },
          child: const Text('Clock In'),
        ),
        SizedBox(width: 20),
        // Tombol lain bisa ditambahkan di sini jika diperlukan
      ],
    );
  }
}
