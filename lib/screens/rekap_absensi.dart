import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart'; // Import ApiService yang sudah dibuat
import 'home_screen.dart'; // Import halaman HomeScreen

class RekapAbsensiScreen extends StatefulWidget {
  @override
  _RekapAbsensiScreenState createState() => _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen> {
  List<dynamic> _rekapAbsensi = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRekapAbsensi();
  }

  Future<void> _fetchRekapAbsensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      setState(() {
        _errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.getRequest(
        'absensi', // Endpoint API Laravel
        {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Parse respons JSON

        setState(() {
          _rekapAbsensi = data; // Langsung assign array JSON ke _rekapAbsensi
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data, status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigasi ke HomeScreen saat tombol back ditekan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti dengan HomeScreen Anda
        );
        return false; // Jangan biarkan halaman ini pop
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigasi ke HomeScreen saat tombol back di app bar ditekan
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti dengan HomeScreen Anda
              );
            },
          ),
          title: Text('Riwayat Absensi'),
          backgroundColor: Colors.blue[800],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue)) // Custom Loading
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                : ListView.builder(
                    itemCount: _rekapAbsensi.length,
                    itemBuilder: (context, index) {
                      final absensi = _rekapAbsensi[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tanggal: ${absensi['tanggal']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Jam Masuk: ${absensi['jam_masuk'] ?? 'N/A'}',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Jam Keluar: ${absensi['jam_keluar'] ?? 'N/A'}',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        backgroundColor: Colors.white, // Latar belakang putih
      ),
    );
  }
}
