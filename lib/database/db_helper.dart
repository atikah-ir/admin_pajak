import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; 
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/peserta.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Ganti nama DB agar fresh dan tabel baru terbuat
    _database = await _initDB('administrasi_v2.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      return await openDatabase(
        filePath,
        version: 1,
        onCreate: _createDB,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE peserta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nik TEXT NOT NULL,
      nama TEXT NOT NULL,
      alamat TEXT NOT NULL,
      status TEXT NOT NULL,
      tanggal_lahir TEXT NOT NULL -- [BARU] Kolom Tanggal Lahir
    )
    ''');
  }

  Future<int> create(Peserta peserta) async {
    final db = await instance.database;
    return await db.insert('peserta', peserta.toMap());
  }

  Future<List<Peserta>> readAllPeserta() async {
    final db = await instance.database;
    final result = await db.query('peserta', orderBy: 'nama ASC');
    return result.map((json) => Peserta.fromMap(json)).toList();
  }

  Future<List<Peserta>> searchPeserta(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'peserta',
      where: 'nik LIKE ? OR nama LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Peserta.fromMap(json)).toList();
  }

  Future<int> update(Peserta peserta) async {
    final db = await instance.database;
    return db.update(
      'peserta',
      peserta.toMap(),
      where: 'id = ?',
      whereArgs: [peserta.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'peserta',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}