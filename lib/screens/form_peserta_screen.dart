import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:administrasi_peserta/models/peserta.dart';
import 'package:administrasi_peserta/database/firestore_service.dart';

class FormPesertaScreen extends StatefulWidget {
  final Peserta? peserta;
  const FormPesertaScreen({Key? key, this.peserta}) : super(key: key);

  @override
  _FormPesertaScreenState createState() => _FormPesertaScreenState();
}

class _FormPesertaScreenState extends State<FormPesertaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk input teks
  late TextEditingController _nikController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController;

  // Variabel untuk Pilihan Status
  String _status = 'Proses';
  final List<String> _statusOptions = ['Aktif', 'Tidak Aktif', 'Proses'];

  @override
  void initState() {
    super.initState();
    // Mengisi data jika dalam mode EDIT
    _nikController = TextEditingController(text: widget.peserta?.nik ?? '');
    _namaController = TextEditingController(text: widget.peserta?.nama ?? '');
    _alamatController = TextEditingController(text: widget.peserta?.alamat ?? '');
    _tglLahirController = TextEditingController(text: widget.peserta?.tanggalLahir ?? '');
    if (widget.peserta != null) {
      _status = widget.peserta!.status;
    }
  }

  // Fungsi Kalender (DatePicker)
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  // Fungsi Simpan ke Firebase
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final p = Peserta(
        id: widget.peserta?.id, // ID dari Firebase (jika edit)
        nik: _nikController.text,
        nama: _namaController.text,
        alamat: _alamatController.text,
        status: _status, // Status yang dipilih dari Dropdown
        tanggalLahir: _tglLahirController.text,
      );

      try {
        if (widget.peserta == null) {
          await FirestoreService().addPeserta(p); // Tambah Baru
        } else {
          await FirestoreService().updatePeserta(p); // Update Data
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peserta == null ? 'Tambah Peserta' : 'Edit Peserta'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input NIK
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK (16 Digit)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (v) => v!.length != 16 ? 'Wajib 16 digit' : null,
              ),
              SizedBox(height: 16),

              // Input Nama
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),

              // Input Tanggal Lahir (Klik icon kalender)
              TextFormField(
                controller: _tglLahirController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),

              // Input Alamat
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),

              // PILIHAN STATUS (DROPDOWN)
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status Kepesertaan', border: OutlineInputBorder()),
                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveData,
                  child: Text("SIMPAN DATA KE CLOUD", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}