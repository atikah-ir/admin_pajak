class Peserta {
  int? id;
  String nik;
  String nama;
  String alamat;
  String status;
  String tanggalLahir;

  Peserta({
    this.id,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.status,
    required this.tanggalLahir,
  });

  factory Peserta.fromMap(Map<String, dynamic> map) {
    return Peserta(
      id: map['id'],
      nik: map['nik'],
      nama: map['nama'],
      alamat: map['alamat'],
      status: map['status'],
      tanggalLahir: map['tanggal_lahir'] ?? '',
    );
  }

  // [PERBAIKAN DISINI]
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'status': status,
      'tanggal_lahir': tanggalLahir,
    };
    // Hanya masukkan ID jika tidak null (untuk update)
    // Jika null (create), biarkan SQLite yang bikin ID otomatis
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}