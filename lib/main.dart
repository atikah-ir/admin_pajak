import 'package:flutter/material.dart';
// [UBAHAN WEB] Import library khusus Web & Foundation
import 'package:flutter/foundation.dart'; 
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'screens/home_screen.dart';

void main() {
  // [UBAHAN WEB] Inisialisasi Database Factory sebelum aplikasi jalan
  // Kode ini akan dieksekusi HANYA jika dijalankan di Browser
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Administrasi Peserta',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: false,
      ),
      home: HomeScreen(),
    );
  }
}