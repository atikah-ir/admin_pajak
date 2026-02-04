import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/peserta.dart';

class FirestoreService {
  // Referensi ke koleksi (tabel) bernama 'peserta' di Firebase
  final CollectionReference _pesertaCollection = 
      FirebaseFirestore.instance.collection('peserta');

  // 1. TAMBAH DATA
  Future<void> addPeserta(Peserta peserta) async {
    try {
      await _pesertaCollection.add(peserta.toMap());
    } catch (e) {
      print("Error tambah data: $e");
    }
  }

  // 2. AMBIL DATA REAL-TIME (Stream)
  // Fungsi ini akan terus memantau database. Jika ada perubahan, UI otomatis berubah.
  Stream<List<Peserta>> getPesertaStream() {
    return _pesertaCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Peserta.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. UPDATE DATA
  Future<void> updatePeserta(Peserta peserta) async {
    try {
      await _pesertaCollection.doc(peserta.id).update(peserta.toMap());
    } catch (e) {
      print("Error update data: $e");
    }
  }

  // 4. HAPUS DATA
  Future<void> deletePeserta(String docId) async {
    try {
      await _pesertaCollection.doc(docId).delete();
    } catch (e) {
      print("Error hapus data: $e");
    }
  }
}