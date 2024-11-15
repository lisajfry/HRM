import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Tambahkan import untuk Provider
import 'package:hrm/model/TotalLembur.dart'; // Pastikan path ini sesuai

class LemburScreen extends StatefulWidget {
  @override
  _LemburScreenState createState() => _LemburScreenState();
}

class _LemburScreenState extends State<LemburScreen> {
  List<dynamic> _lemburData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLemburData();
  }

  Future<void> _fetchLemburData() async {
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
        'absensi',
        {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lemburData = data
              .where((absensi) => _calculateOvertime(absensi['jam_keluar']) > 0)
              .toList();
          
          // Update total lembur
          Provider.of<TotalLemburProvider>(context, listen: false).updateTotalLembur(_lemburData.length);
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

  int _calculateOvertime(String? jamKeluar) {
    if (jamKeluar == null) return 0;

    // Menggunakan format yang Anda inginkan
    final jamKeluarTime = DateFormat('HH:mm').parse(jamKeluar);
    final batasJamKerja = DateFormat('HH:mm').parse('17:00');

    if (jamKeluarTime.isAfter(batasJamKerja)) {
      final overtimeDuration = jamKeluarTime.difference(batasJamKerja);
      return overtimeDuration.inHours;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lembur'),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: _lemburData.length,
                  itemBuilder: (context, index) {
                    final lembur = _lemburData[index];
                    final overtimeHours = _calculateOvertime(lembur['jam_keluar']);
                    
                    // Format tanggal
                    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(lembur['tanggal']));

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
                                  'Tanggal: $formattedDate',
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
                                  'Jam Keluar: ${lembur['jam_keluar'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.timer, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Lembur: $overtimeHours jam',
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
      backgroundColor: Colors.white,
    );
  }
}
