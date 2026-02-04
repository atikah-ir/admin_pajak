import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/login_screen.dart'; 
// [BARU] Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// [BARU] Ubah main menjadi Future dan async
Future<void> main() async {
  // [BARU] Wajib dipanggil untuk inisialisasi plugin
  WidgetsFlutterBinding.ensureInitialized();

  // [BARU] Menghubungkan aplikasi ke Firebase (Internet)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Database untuk Web (Tetap dipertahankan)
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
      home: LoginScreen(), 
    );
  }
}