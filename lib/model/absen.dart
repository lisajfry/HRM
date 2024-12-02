class Absensi {
  final int id;
  final int idKaryawan;
  final String tanggal;
  final String jamMasuk;
  final String? fotoMasuk;
  final String status;

  Absensi({
    required this.id,
    required this.idKaryawan,
    required this.tanggal,
    required this.jamMasuk,
    this.fotoMasuk,
    required this.status,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      idKaryawan: json['id_karyawan'],
      tanggal: json['tanggal'],
      jamMasuk: json['jam_masuk'],
      fotoMasuk: json['foto_masuk'],
      status: json['status'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id_karyawan': idKaryawan,
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'foto_masuk': fotoMasuk,
      'status': status,
    };
  }


  // Convert the Absensi object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id_karyawan': idKaryawan,
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'foto_masuk': fotoMasuk,
      'status': status,
    };
  }
}
