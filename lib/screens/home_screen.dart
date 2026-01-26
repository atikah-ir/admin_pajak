import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/peserta.dart';
import 'form_peserta_screen.dart';
import 'login_screen.dart'; // Import login agar bisa logout

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Peserta> _allPeserta = [];
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
    if (_selectedFilter != 'Semua') {
      results = results.where((user) => user.status == _selectedFilter).toList();
    }
    setState(() => _displayedPeserta = results);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data dihapus')));
  }

  // --- WIDGETS ---
  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) => _applyFilter(label),
        selectedColor: Colors.indigo,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
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
        // TOMBOL LOGOUT
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Keluar dari aplikasi?'),
                  actions: [
                    TextButton(child: Text('Batal'), onPressed: () => Navigator.of(ctx).pop()),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Keluar'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari NIK/Nama...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
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
                          Color color = Colors.grey;
                          if (item.status == 'Aktif') color = Colors.green;
                          if (item.status == 'Proses') color = Colors.orange;
                          if (item.status == 'Tidak Aktif') color = Colors.red;

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.2),
                                child: Text(item.nama[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(item.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nik),
                                  Text(item.status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesertaScreen(peserta: item))).then((_) => _refreshData());
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