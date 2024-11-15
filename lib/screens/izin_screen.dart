import 'package:flutter/material.dart';
import 'package:hrm/api/izin_service.dart';
import 'package:hrm/model/izin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/screens/Add_izin.dart'; // Pastikan untuk mengimpor IzinForm

class IzinScreen extends StatefulWidget {
  @override
  _IzinScreenState createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  late Future<List<Izin>> futureIzin;

  @override
  void initState() {
    super.initState();
    futureIzin = _fetchIzin(); // Panggil fungsi untuk mendapatkan izin
  }

  Future<List<Izin>> _fetchIzin() async {
    try {
      return await IzinService().getIzin(); // Panggil fungsi getIzin tanpa token
    } catch (e) {
      throw Exception('Gagal memuat data izin: $e'); // Tangani kesalahan
    }
  }

  Future<void> _deleteIzin(int izinId) async {
    try {
      await IzinService().deleteIzin(izinId); // Panggil fungsi deleteIzin
      setState(() {
        futureIzin = _fetchIzin(); // Refresh data setelah penghapusan
      });
    } catch (e) {
      print('Gagal menghapus izin: $e'); // Tangani kesalahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Daftar Izin'),
  backgroundColor: Colors.blue[800], // Menggunakan warna biru dengan shade 800
),
      body: FutureBuilder<List<Izin>>(
        future: futureIzin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data izin.'));
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final izin = snapshot.data![index];
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row untuk durasi hari dan status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Durasi
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '${izin.durasi}', // Durasi hari
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Rentang Tanggal Izin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${izin.tgl_mulai} - ${izin.tgl_selesai}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    // Status izin
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Izin',
                                        style: TextStyle(color: Colors.green[800]),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      izin.status,
                                      style: TextStyle(
                                        color: izin.status == 'Disetujui' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Tombol Edit dan Delete
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Navigasi ke halaman edit dengan data izin
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => IzinForm(izin: izin)),
                                  ).then((_) {
                                    setState(() {
                                      futureIzin = _fetchIzin(); // Refresh data setelah kembali
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteIzin(izin.id); // Hapus izin
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Keterangan
                      Text(
                        'Keterangan: ${izin.keterangan}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 5),
                      Text(
                        'Alasan: ${izin.alasan}', // Kolom Alasan ditambahkan di sini
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman IzinForm untuk menambah izin
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IzinForm()),
          ).then((_) {
            // Refresh data setelah kembali
            setState(() {
              futureIzin = _fetchIzin();
            });
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Izin',
      ),
    );
  }
}
