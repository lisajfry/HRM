class DinasLuarKota {
  final int id;
  final int idKaryawan; // Tambahkan ini jika belum ada
  final DateTime tglBerangkat;
  final DateTime tglKembali;
  final String kotaTujuan;
  final String keperluan;
  final double biayaTransport;
  final double biayaPenginapan;
  final double uangHarian;
  final double totalBiaya;

  DinasLuarKota({
    required this.id,
    required this.idKaryawan, // Tambahkan ini di konstruktor
    required this.tglBerangkat,
    required this.tglKembali,
    required this.kotaTujuan,
    required this.keperluan,
    required this.biayaTransport,
    required this.biayaPenginapan,
    required this.uangHarian,
    required this.totalBiaya,
  });

  factory DinasLuarKota.fromJson(Map<String, dynamic> json) {
    return DinasLuarKota(
      id: json['id'],
      idKaryawan: json['id_karyawan'], // Pastikan ini sesuai dengan field di JSON
      tglBerangkat: DateTime.parse(json['tgl_berangkat']),
      tglKembali: DateTime.parse(json['tgl_kembali']),
      kotaTujuan: json['kota_tujuan'],
      keperluan: json['keperluan'],
      biayaTransport: double.parse(json['biaya_transport'].toString()),
      biayaPenginapan: double.parse(json['biaya_penginapan'].toString()),
      uangHarian: double.parse(json['uang_harian'].toString()),
      totalBiaya: double.parse(json['total_biaya'].toString()),
    );
  }
}
