import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KasbonPage(),
    );
  }
}

class KasbonPage extends StatefulWidget {
  @override
  _KasbonPageState createState() => _KasbonPageState();
}

class _KasbonPageState extends State<KasbonPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    PengajuanKasbon(),  // Halaman Pengajuan
    BayarKasbon(),
    LaporanKasbon(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halaman Kasbon"),
      ),
      body: _tabs[_currentIndex],  // Menampilkan tab sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // Mengubah index tab yang aktif
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Pengajuan',  // Nama tab pengajuan
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Bayar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}

class PengajuanKasbon extends StatefulWidget {
  @override
  _PengajuanKasbonState createState() => _PengajuanKasbonState();
}

class _PengajuanKasbonState extends State<PengajuanKasbon> {
  final _tanggalController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();

  String? _kasbonId;
  String? _tanggalPengajuan;
  double? _jumlahKasbon;
  String? _keteranganKasbon;

  // Fungsi untuk mengajukan kasbon
  void _submitKasbon() async {
    try {
      // Simulasi pengajuan kasbon
      setState(() {
        _kasbonId = "12345";  // ID Kasbon
        _tanggalPengajuan = _tanggalController.text;
        _jumlahKasbon = double.tryParse(_jumlahController.text);
        _keteranganKasbon = _keteranganController.text;
      });

      // Menampilkan snack bar konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kasbon berhasil diajukan')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengajukan kasbon: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajukan Kasbon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            controller: _tanggalController,
            decoration: InputDecoration(labelText: 'Tanggal Pengajuan'),
            keyboardType: TextInputType.datetime,
          ),
          TextField(
            controller: _jumlahController,
            decoration: InputDecoration(labelText: 'Jumlah Kasbon'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _keteranganController,
            decoration: InputDecoration(labelText: 'Keterangan'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitKasbon,
            child: Text('Ajukan Kasbon'),
          ),
          SizedBox(height: 20),
          // Menampilkan informasi pengajuan kasbon yang berhasil
          if (_kasbonId != null) ...[
            Text('Kasbon berhasil diajukan:'),
            Text('ID Kasbon: $_kasbonId'),
            Text('Tanggal Pengajuan: $_tanggalPengajuan'),
            Text('Jumlah Kasbon: $_jumlahKasbon'),
            Text('Keterangan: $_keteranganKasbon'),
          ],
        ],
      ),
    );
  }
}

class BayarKasbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pembayaran Kasbon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(labelText: 'Jumlah Pembayaran'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Metode Pembayaran'),
            items: ['Transfer', 'Tunai'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logika untuk melakukan pembayaran kasbon
            },
            child: Text('Bayar Kasbon'),
          ),
        ],
      ),
    );
  }
}

class LaporanKasbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Laporan Kasbon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('Riwayat Pembayaran dan Pengajuan Kasbon', style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          // Bisa menggunakan ListView untuk menampilkan riwayat kasbon
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Jumlah item riwayat
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Kasbon ${index + 1}'),
                  subtitle: Text('Status: Lunas - Tanggal Pembayaran: 01-12-2024'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Aksi untuk melihat detail
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
