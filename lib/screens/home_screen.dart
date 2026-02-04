import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:administrasi_peserta/excel_service.dart';
import 'package:administrasi_peserta/models/peserta.dart';
import 'package:administrasi_peserta/database/firestore_service.dart';
import 'package:administrasi_peserta/screens/form_peserta_screen.dart';
import 'package:administrasi_peserta/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = ''; 
  DateTime? _lastPressedAt;

  // Fungsi Hapus Real-time
  Future<void> _deletePeserta(String id) async {
    await FirestoreService().deletePeserta(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data berhasil dihapus dari internet'))
    );
  }

  // Desain Kartu Statistik
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Desain Filter Chip
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: Colors.indigo,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tekan sekali lagi untuk keluar')));
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Dashboard Online'),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
            )
          ],
        ),
        body: StreamBuilder<List<Peserta>>(
          stream: FirestoreService().getPesertaStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final allData = snapshot.data ?? [];
            
            // Hitung Statistik Otomatis dari Internet
            int total = allData.length;
            int aktif = allData.where((e) => e.status == 'Aktif').length;
            int proses = allData.where((e) => e.status == 'Proses').length;

            // Logika Search & Filter
            List<Peserta> filteredData = allData.where((p) {
              bool matchFilter = _selectedFilter == 'Semua' || p.status == _selectedFilter;
              bool matchSearch = p.nama.toLowerCase().contains(_searchQuery.toLowerCase()) || p.nik.contains(_searchQuery);
              return matchFilter && matchSearch;
            }).toList();

            return Column(
              children: [
                // Tombol Export Excel
                Container(
                  width: double.infinity,
                  color: Colors.indigo,
                  child: TextButton.icon(
                    onPressed: () => ExcelService.exportPesertaToExcel(allData),
                    icon: Icon(Icons.file_download, color: Colors.white),
                    label: Text("DOWNLOAD LAPORAN EXCEL", style: TextStyle(color: Colors.white)),
                  ),
                ),

                // Area Statistik
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      _buildStatCard('Total', total, Colors.blue, Icons.folder),
                      _buildStatCard('Aktif', aktif, Colors.green, Icons.check_circle),
                      _buildStatCard('Proses', proses, Colors.orange, Icons.hourglass_top),
                    ],
                  ),
                ),

                // Area Search & Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari NIK atau Nama...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Semua', 'Aktif', 'Proses', 'Tidak Aktif'].map(_buildFilterChip).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Daftar Peserta
                Expanded(
                  child: filteredData.isEmpty
                      ? Center(child: Text("Data tidak ditemukan"))
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 80),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            Color color = Colors.grey;
                            if (item.status == 'Aktif') color = Colors.green;
                            if (item.status == 'Proses') color = Colors.orange;
                            if (item.status == 'Tidak Aktif') color = Colors.red;

                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.1),
                                  child: Text(item.nama[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(item.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${item.nik}\nStatus: ${item.status}"),
                                isThreeLine: true,
                                trailing: PopupMenuButton(
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesertaScreen(peserta: item)));
                                    } else {
                                      _deletePeserta(item.id!);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesertaScreen())),
        ),
      ),
    );
  }
}