import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/peserta.dart';
import '../database/db_helper.dart';

class FormPesertaScreen extends StatefulWidget {
  final Peserta? peserta;

  const FormPesertaScreen({Key? key, this.peserta}) : super(key: key);

  @override
  _FormPesertaScreenState createState() => _FormPesertaScreenState();
}

class _FormPesertaScreenState extends State<FormPesertaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nikController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController; // [BARU] Controller Tanggal

  String _status = 'Proses';
  final List<String> _statusOptions = ['Aktif', 'Tidak Aktif', 'Proses'];

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController(text: widget.peserta?.nik ?? '');
    _namaController = TextEditingController(text: widget.peserta?.nama ?? '');
    _alamatController = TextEditingController(text: widget.peserta?.alamat ?? '');
    // [BARU] Isi tanggal jika edit
    _tglLahirController = TextEditingController(text: widget.peserta?.tanggalLahir ?? '');
    
    if (widget.peserta != null) {
      _status = widget.peserta!.status;
    }
  }

  // [BARU] Fungsi Memunculkan Kalender
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Tanggal awal yang muncul
      firstDate: DateTime(1900),   // Tahun paling lama
      lastDate: DateTime.now(),    // Tidak boleh pilih tanggal masa depan
    );

    if (picked != null) {
      setState(() {
        // Format tanggal sederhana: DD-MM-YYYY
        _tglLahirController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final pesertaBaru = Peserta(
        id: widget.peserta?.id,
        nik: _nikController.text,
        nama: _namaController.text,
        alamat: _alamatController.text,
        status: _status,
        tanggalLahir: _tglLahirController.text, // [BARU] Simpan tanggal
      );

      try {
        if (widget.peserta == null) {
          await DatabaseHelper.instance.create(pesertaBaru);
        } else {
          await DatabaseHelper.instance.update(pesertaBaru);
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.peserta == null ? 'Tambah' : 'Edit')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK (16 Digit)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.length != 16 ? 'Wajib 16 digit' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),

              // [BARU] Input Tanggal Lahir dengan Kalender
              TextFormField(
                controller: _tglLahirController,
                readOnly: true, // Agar keyboard tidak muncul saat diklik
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today), // Ikon Kalender
                  hintText: 'Pilih Tanggal',
                ),
                onTap: () => _selectDate(context), // Munculkan kalender saat diklik
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _status,
                items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              ),
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  child: Padding(padding: EdgeInsets.all(16), child: Text("SIMPAN")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}