class Peserta {
  int? id;
  String nik;
  String nama;
  String alamat;
  String status;

  Peserta({
    this.id,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.status,
  });

  factory Peserta.fromMap(Map<String, dynamic> map) {
    return Peserta(
      id: map['id'],
      nik: map['nik'],
      nama: map['nama'],
      alamat: map['alamat'],
      status: map['status'],
    );
  }

  // [PERBAIKAN DISINI]
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'status': status,
    };
    // Hanya masukkan ID jika tidak null (untuk update)
    // Jika null (create), biarkan SQLite yang bikin ID otomatis
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}