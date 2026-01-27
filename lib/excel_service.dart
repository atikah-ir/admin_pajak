import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/peserta.dart'; 

class ExcelService {
  static Future<void> exportPesertaToExcel(List<Peserta> daftarPeserta) async {
    var excel = Excel.createExcel();
    
    // Nama Sheet
    Sheet sheetObject = excel['Data Peserta'];
    excel.delete('Sheet1'); 

    // 1. Header (Gunakan TextCellValue)
    sheetObject.appendRow([
      TextCellValue("No"),
      TextCellValue("NIK"),
      TextCellValue("Nama"),
      TextCellValue("Alamat"),
      TextCellValue("Status"),
      TextCellValue("Tanggal Lahir"),
    ]);

    // 2. Isi Data dari List Peserta
    for (var i = 0; i < daftarPeserta.length; i++) {
      var p = daftarPeserta[i];
      sheetObject.appendRow([
        IntCellValue(i + 1),               // Gunakan IntCellValue untuk angka
        TextCellValue(p.nik),              // Gunakan TextCellValue untuk teks
        TextCellValue(p.nama),
        TextCellValue(p.alamat),
        TextCellValue(p.status),
        TextCellValue(p.tanggalLahir), 
      ]);
    }

    // 3. Simpan ke file sementara
    var fileBytes = excel.save();
    final directory = await getTemporaryDirectory();
    String fileName = "Data_Peserta_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    final file = File('${directory.path}/$fileName');

    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);

      // 4. Munculkan menu Share
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Laporan Data Peserta'
      );
    }
  }
}