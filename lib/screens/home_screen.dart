import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/peserta.dart';
import 'form_peserta_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Master data
  List<Peserta> _allPeserta = [];
  // Data yang ditampilkan (setelah filter)
  List<Peserta> _displayedPeserta = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.readAllPeserta();
    setState(() {
      _allPeserta = data;
      _displayedPeserta = data; 
      _isLoading = false;
    });
    // Terapkan ulang filter jika ada
    _applyFilter(_selectedFilter);
  }

  void _runSearch(String keyword) {
    List<Peserta> results = [];
    if (keyword.isEmpty) {
      results = _allPeserta;
    } else {
      results = _allPeserta
          .where((user) =>
              user.nama.toLowerCase().contains(keyword.toLowerCase()) ||
              user.nik.contains(keyword))
          .toList();
    }
    
    // Tetap jaga filter status
    if (_selectedFilter != 'Semua') {
      results = results.where((user) => user.status == _selectedFilter).toList();
    }

    setState(() {
      _displayedPeserta = results;
    });
  }

  void _applyFilter(String status) {
    List<Peserta> results = [];
    if (status == 'Semua') {
      results = _allPeserta;
    } else {
      results = _allPeserta.where((user) => user.status == status).toList();
    }
    setState(() {
      _selectedFilter = status;
      _displayedPeserta = results;
    });
  }

  Future<void> _deletePeserta(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil dihapus')));
  }

  // Widget Kotak Statistik
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4),
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, 
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Filter
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          _applyFilter(label);
        },
        selectedColor: Colors.indigo,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _allPeserta.length;
    int aktif = _allPeserta.where((e) => e.status == 'Aktif').length;
    int proses = _allPeserta.where((e) => e.status == 'Proses').length;

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // 1. STATISTIK
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

          // 2. SEARCH & FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari NIK atau Nama...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _runSearch,
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      _buildFilterChip('Aktif'),
                      _buildFilterChip('Proses'),
                      _buildFilterChip('Tidak Aktif'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // 3. LIST DATA
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _displayedPeserta.isEmpty
                    ? Center(child: Text("Data tidak ditemukan"))
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: _displayedPeserta.length,
                        itemBuilder: (context, index) {
                          final item = _displayedPeserta[index];
                          Color colorStatus = Colors.grey;
                          if (item.status == 'Aktif') colorStatus = Colors.green;
                          if (item.status == 'Proses') colorStatus = Colors.orange;
                          if (item.status == 'Tidak Aktif') colorStatus = Colors.red;

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorStatus.withOpacity(0.2),
                                child: Text(item.nama[0].toUpperCase(),
                                    style: TextStyle(color: colorStatus, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(item.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nik),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorStatus.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: colorStatus.withOpacity(0.5))
                                    ),
                                    child: Text(item.status, 
                                      style: TextStyle(fontSize: 10, color: colorStatus, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              // Titik tiga (Edit/Hapus)
                              trailing: PopupMenuButton(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesertaScreen(peserta: item)))
                                        .then((v) { if(v==true) _refreshData(); });
                                  } else {
                                    _deletePeserta(item.id!);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesertaScreen()));
          if (res == true) _refreshData();
        },
      ),
    );
  }
}