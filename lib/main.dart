import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/login_screen.dart'; // Panggil halaman login

void main() {
  // Setup Database untuk Web
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
      home: LoginScreen(), // Masuk ke Login dulu
    );
  }
}