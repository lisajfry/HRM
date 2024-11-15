class Izin {
  final int id;
  final int idKaryawan;
  final String tgl_mulai;
  final String tgl_selesai;
  final String alasan;
  final String keterangan;
  final String status;
  final int durasi;

  Izin({
    required this.id,
    required this.idKaryawan,
    required this.tgl_mulai,
    required this.tgl_selesai,
    required this.alasan,
    required this.keterangan,
    required this.status,
    required this.durasi,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      id: json['id'] ?? 0, // Menambahkan default value
      idKaryawan: json['id_karyawan'] ?? 0, // Menambahkan default value
      tgl_mulai: json['tgl_mulai'] ?? '',
      tgl_selesai: json['tgl_selesai'] ?? '',
      alasan:json['alasan']?? '',
      keterangan: json['keterangan'] ?? '',
      status: json['status'] ?? '',
      durasi: json['durasi'] ?? 0, // Menambahkan default value
    );
  }
}
