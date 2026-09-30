import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Ganti dengan URL Deployment Google Apps Script Anda
const String scriptUrl = "https://script.google.com/macros/s/AKfycbzLqpiWepzdTAdn6CJSxzQk10ydWkAgtnZ_4DLK4cbRvGvciGs4h3Vx8HcPPE3JZpU/exec";

void main() {
  runApp(const AISANApp());
}

class AISANApp extends StatelessWidget {
  const AISANApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AISAN - Aplikasi Informasi Santri',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= 1. HALAMAN LOGIN =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({
          "action": "login",
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );
      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (data['status'] == 'success') {
        String role = data['role'];
        if (role == 'walikelas' || role == 'gurumapel') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardGuru(userData: data)),
          );
        } else if (role == 'walimurid') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardSiswa(userData: data)),
          );
        }
      } else {
        _showMsg(data['message'] ?? "Login Gagal");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Terjadi kesalahan koneksi: $e");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 64, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text("AISAN", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
                  const Text("Aplikasi Informasi Santri", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Text("SD Zainul Hasan Genggong", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Masuk', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= 2. DASHBOARD WALI KELAS & GURU MAPEL =================
class DashboardGuru extends StatelessWidget {
  final Map<String, dynamic> userData;
  const DashboardGuru({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    bool isWaliKelas = userData['role'] == 'walikelas';

    return Scaffold(
      appBar: AppBar(
        title: Text(isWaliKelas ? 'Dashboard Wali Kelas' : 'Dashboard Guru Mapel'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 35, backgroundColor: Colors.green, child: Icon(Icons.person, size: 40, color: Colors.white)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['nama'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Jabatan: ${userData['jabatan'] ?? '-'}"),
                        Text("Alamat: ${userData['alamat'] ?? '-'}"),
                        Text("TTL: ${userData['ttl'] ?? '-'}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Menu Utama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (isWaliKelas) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Kelola Absensi Harian & Rekap Bulanan'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AbsenPage()));
                },
              ),
            ] else ...[
              const Text("Fitur Input Nilai Mapel / Monitoring Siswa."),
            ]
          ],
        ),
      ),
    );
  }
}

// ================= 3. DASHBOARD SISWA / WALI MURID =================
class DashboardSiswa extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardSiswa({super.key, required this.userData});

  @override
  State<DashboardSiswa> createState() => _DashboardSiswaState();
}

class _DashboardSiswaState extends State<DashboardSiswa> {
  List nilaiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNilai();
  }

  void fetchNilai() async {
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({"action": "get_nilai", "nis": widget.userData['username']}),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          nilaiList = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Wali Murid'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama: ${widget.userData['nama']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Kelas: ${widget.userData['kelas'] ?? '-'}"),
                    Text("Wali Kelas: ${widget.userData['alamat'] ?? '-'}"), // Contoh mapping data
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Nilai Mata Pelajaran Keseluruhan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : nilaiList.isEmpty
                      ? const Center(child: Text("Belum ada data nilai."))
                      : ListView.builder(
                          itemCount: nilaiList.length,
                          itemBuilder: (context, index) {
                            var item = nilaiList[index];
                            return Card(
                              child: ListTile(
                                title: Text(item['mapel']),
                                trailing: Text("Nilai: ${item['nilai']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 4. FITUR WALI KELAS (ABSEN & PDF) =================
class AbsenPage extends StatefulWidget {
  const AbsenPage({super.key});

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final _nisController = TextEditingController();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  String _status = 'Hadir';

  void _simpanAbsen() async {
    String tanggal = DateTime.now().toString().split(' ')[0];
    try {
      await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({
          "action": "simpan_absen",
          "tanggal": tanggal,
          "nis": _nisController.text,
          "nama": _namaController.text,
          "kelas": _kelasController.text,
          "status": _status,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Absen Berhasil Disimpan")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("Rekap Bulanan Santri", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text("SD Zainul Hasan Genggong", style: pw.TextStyle(fontSize: 16)),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Periode Bulan: Oktober 2026", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Santri', 'Izin', 'Sakit', 'Alpha', 'Total'],
                data: [
                  ['1', 'Ahmad Zaini', '0', '1', '0', '1'],
                  ['2', 'Fatimah Zahra', '2', '0', '0', '2'],
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Absensi & Cetak Laporan'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Form Input Absen Harian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(controller: _nisController, decoration: const InputDecoration(labelText: 'NIS Siswa', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Siswa', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _kelasController, decoration: const InputDecoration(labelText: 'Kelas', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Hadir', 'Izin', 'Sakit', 'Alpha'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _status = val!),
              decoration: const InputDecoration(labelText: 'Status Kehadiran', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: _simpanAbsen,
              child: const Text('Simpan Absensi'),
            ),
            const Divider(height: 40),
            const Text("Cetak Laporan Rekap Bulanan (PDF)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              icon: const Icon(Icons.print),
              label: const Text('Cetak / Download PDF'),
              onPressed: _generatePdf,
            ),
          ],
        ),
      ),
    );
  }
}