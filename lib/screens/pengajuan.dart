import 'package:flutter/material.dart';
import 'package:hrm/api/pengajuan_service.dart';

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
      var result = await KasbonService().ajukanKasbon(
        _tanggalController.text,
        double.parse(_jumlahController.text),
        _keteranganController.text,
      );

      setState(() {
        _kasbonId = result['id'].toString();
        _tanggalPengajuan = result['tanggal_pengajuan'];
        _jumlahKasbon = result['jumlah_kasbon'];
        _keteranganKasbon = result['keterangan'];
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
