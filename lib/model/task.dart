class Task {
  final int idTugas; // Ganti id menjadi idTugas
  final String judulProyek;
  final String kegiatan;
  final String tglMulai;
  final String tglSelesai;
  final String batasPenyelesaian;
  final String status;

  Task({
    required this.idTugas, // Ganti id menjadi idTugas
    required this.judulProyek,
    required this.kegiatan,
    required this.tglMulai,
    required this.tglSelesai,
    required this.batasPenyelesaian,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      idTugas: json['id_tugas'] ?? 0, // Ganti id menjadi id_tugas
      judulProyek: json['judul_proyek'] ?? '',
      kegiatan: json['kegiatan'] ?? '',
      tglMulai: json['tgl_mulai'] ?? '',
      tglSelesai: json['tgl_selesai'] ?? '',
      batasPenyelesaian: json['batas_penyelesaian'] ?? '',
      status: json['status'] ?? 'belum dimulai',
    );
  }
}
