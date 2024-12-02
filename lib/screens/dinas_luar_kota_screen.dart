import 'package:flutter/material.dart';
import 'package:hrm/api/dinasluarkota_service.dart';
import 'package:hrm/model/dinasluarkota.dart';
import 'package:hrm/screens/add_dinas_luar_kota_screen.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class DinasLuarKotaScreen extends StatefulWidget {
  @override
  _DinasLuarKotaScreenState createState() => _DinasLuarKotaScreenState();
}

class _DinasLuarKotaScreenState extends State<DinasLuarKotaScreen> {
  late Future<List<DinasLuarKota>> futureDinasLuarKota;

  @override
  void initState() {
    super.initState();
    futureDinasLuarKota = _fetchDinasLuarKota();
  }

  Future<List<DinasLuarKota>> _fetchDinasLuarKota() async {
    try {
      return await DinasLuarKotaService().getDinasLuarKota();
    } catch (e, stacktrace) {
      print('Error saat memuat data dinas luar kota: $e');
      print('Stacktrace: $stacktrace');
      throw Exception('Gagal memuat data dinas luar kota: $e');
    }
  }

  Future<void> _deleteDinasLuarKota(int id) async {
    try {
      await DinasLuarKotaService().deleteDinasLuarKota(id);
      _refreshData();
    } catch (e, stacktrace) {
      print('Error saat menghapus data dinas luar kota: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  void _refreshData() {
    setState(() {
      futureDinasLuarKota = _fetchDinasLuarKota(); // Refresh the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Dinas Luar Kota'),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<List<DinasLuarKota>>(
        future: futureDinasLuarKota,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error FutureBuilder: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data dinas luar kota.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final dinas = snapshot.data![index];
                // Format tanggal tanpa jam
                final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                final String formattedTglBerangkat = dateFormat.format(dinas.tglBerangkat);
                final String formattedTglKembali = dateFormat.format(dinas.tglKembali);

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$formattedTglBerangkat - $formattedTglKembali', // Tampilkan tanggal tanpa jam
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DinasLuarKotaForm(dinas: dinas)),
                                  ).then((_) {
                                    setState(() {
                                      futureDinasLuarKota = _fetchDinasLuarKota(); // Refresh data setelah kembali
                                    });
                                  });
                                },
                              ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _deleteDinasLuarKota(dinas.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          dinas.kotaTujuan,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Keperluan: ${dinas.keperluan}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Total Biaya: ${dinas.totalBiaya?.toStringAsFixed(2) ?? 'Belum dihitung'}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DinasLuarKotaForm()),
          ).then((_) {
            // Refresh data setelah kembali
            setState(() {
              futureDinasLuarKota = _fetchDinasLuarKota();
            });
          });
        
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Dinas Luar Kota',
      ),
    );
  }
}
