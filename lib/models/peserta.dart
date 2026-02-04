class Peserta {
  // id diubah jadi String agar bisa menampung ID unik dari Firebase
  String? id; 
  final String nik;
  final String nama;
  final String alamat;
  final String status;
  final String tanggalLahir;

  Peserta({
    this.id,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.status,
    required this.tanggalLahir,
  });

  // Untuk Mengubah Objek Peserta menjadi Map (sebelum dikirim ke Internet)
  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'status': status,
      'tanggal_lahir': tanggalLahir, // Gunakan underscore agar rapi di Firestore
    };
  }

  // Untuk Mengubah Data dari Internet (Map) menjadi Objek Peserta
  factory Peserta.fromMap(Map<String, dynamic> map, String docId) {
    return Peserta(
      id: docId, // Kita ambil ID dokumen dari Firestore
      nik: map['nik'] ?? '',
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      status: map['status'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
    );
  }
}