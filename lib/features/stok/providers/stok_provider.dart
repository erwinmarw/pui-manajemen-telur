import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StokProvider with ChangeNotifier {
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('stok');
  bool _isInitialized = false;

  // Error state for graceful UI handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Data Ringkasan Inventori (Statik sementara)
  final int _totalTersedia = 4000;
  final int _stokMenipis = 2;
  final int _barangMasukHariIni = 700;
  final int _barangKeluarHariIni = 900;

  List<Map<String, dynamic>> _stokList = [];

  // Data Pergerakan Stok Mingguan (Bar Chart)
  final List<List<double>> _pergerakanMingguan = [
    [800, 600],   // Sen
    [1200, 900],  // Sel
    [1000, 1100], // Rab
    [1400, 800],  // Kam
    [900, 1300],  // Jum
    [600, 500],   // Sab
    [300, 200],   // Min
  ];

  // Data Kategori Inventori (Pie Chart)
  final List<Map<String, dynamic>> _kategoriData = [
    {'nama': 'Telur Ayam Negeri', 'persentase': 50.0, 'color': 0xFFF59E0B},
    {'nama': 'Telur Ayam Kampung', 'persentase': 15.0, 'color': 0xFFD97706},
    {'nama': 'Telur Bebek', 'persentase': 20.0, 'color': 0xFF10B981},
    {'nama': 'Telur Puyuh', 'persentase': 15.0, 'color': 0xFF8B5CF6},
  ];

  // Data Monitoring Stok (Progress Bars)
  final List<Map<String, dynamic>> _monitoringStok = [
    {'nama': 'Telur Ayam Negeri', 'persentase': 85, 'color': 0xFF10B981},
    {'nama': 'Telur Ayam Kampung', 'persentase': 25, 'color': 0xFFEF4444},
    {'nama': 'Telur Bebek', 'persentase': 45, 'color': 0xFFF59E0B},
    {
      'nama': 'Telur Puyuh',
      'persentase': 80,
      'color': 0xFF8B5CF6,
      'current': '2.000 kg',
      'min': 'Min: 500 kg',
      'status': 'Aman',
    },
  ];

  // Data Aktivitas Stok Terbaru
  final List<Map<String, dynamic>> _aktivitasStok = [
    {
      'title': 'Barang Masuk - Telur Ayam Negeri',
      'desc': '500 kg ditambahkan ke inventori',
      'waktu': '2 jam lalu',
      'type': 'masuk',
    },
    {
      'title': 'Barang Keluar - Telur Bebek',
      'desc': '200 kg terjual',
      'waktu': '4 jam lalu',
      'type': 'keluar',
    },
    {
      'title': 'Update Stok - Telur Ayam Kampung',
      'desc': 'Stok diperbarui manual',
      'waktu': '6 jam lalu',
      'type': 'update',
    },
    {
      'title': 'Barang Masuk - Telur Puyuh',
      'desc': '300 kg ditambahkan',
      'waktu': '10 jam lalu',
      'type': 'masuk',
    },
  ];

  // Getters
  int get totalTersedia => _totalTersedia;
  int get stokMenipis => _stokMenipis;
  int get barangMasukHariIni => _barangMasukHariIni;
  int get barangKeluarHariIni => _barangKeluarHariIni;
  List<Map<String, dynamic>> get stokList => _stokList;
  List<List<double>> get pergerakanMingguan => _pergerakanMingguan;
  List<Map<String, dynamic>> get kategoriData => _kategoriData;
  List<Map<String, dynamic>> get monitoringStok => _monitoringStok;
  List<Map<String, dynamic>> get aktivitasStok => _aktivitasStok;

  double get totalStokKg {
    double total = 0.0;
    for (var item in _stokList) {
      final double? b = double.tryParse(item['berat']?.toString() ?? '');
      if (b != null) {
        total += b;
      }
    }
    return total;
  }

  String get totalStokFormatted {
    double total = totalStokKg;
    if (total == 0.0 && _stokList.isEmpty) {
      // Fallback to initial display or 0
      return '0';
    }
    if (total == total.toInt()) {
      return total.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return total.toStringAsFixed(1);
  }

  int get stokMenipisCount {
    int count = 0;
    for (var item in _stokList) {
      final String status = item['status']?.toString() ?? 'Aman';
      if (status == 'Kritis' || status == 'Perhatian') {
        count++;
      }
    }
    return count;
  }

  List<Map<String, dynamic>> get aggregatedEggStocks {
    // Default config for the 4 categories
    final Map<String, Map<String, dynamic>> config = {
      'Telur Ayam Negeri': {
        'min': 1000.0,
        'max': 4000.0,
        'color': 0xFF10B981,
      },
      'Telur Ayam Kampung': {
        'min': 1000.0,
        'max': 2000.0,
        'color': 0xFFEF4444,
      },
      'Telur Bebek': {
        'min': 800.0,
        'max': 3000.0,
        'color': 0xFFF59E0B,
      },
      'Telur Puyuh': {
        'min': 600.0,
        'max': 2000.0,
        'color': 0xFF8B5CF6,
      },
    };

    // Calculate sum of weights for each jenis
    final Map<String, double> weights = {
      'Telur Ayam Negeri': 0.0,
      'Telur Ayam Kampung': 0.0,
      'Telur Bebek': 0.0,
      'Telur Puyuh': 0.0,
    };

    for (var item in _stokList) {
      final String? jenis = item['jenis']?.toString();
      final double? berat = double.tryParse(item['berat']?.toString() ?? '');
      if (jenis != null && weights.containsKey(jenis) && berat != null) {
        weights[jenis] = (weights[jenis] ?? 0.0) + berat;
      }
    }

    // Build the list of progress maps
    final List<Map<String, dynamic>> result = [];
    config.forEach((jenis, cfg) {
      final double actual = weights[jenis] ?? 0.0;
      final double minVal = cfg['min'] as double;
      final double maxVal = cfg['max'] as double;
      final int colorVal = cfg['color'] as int;

      // Calculate progress (0.0 to 1.0)
      double progress = actual / maxVal;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      // Determine status
      String status = 'Aman';
      int finalColor = colorVal;
      if (actual < minVal) {
        status = 'Rendah';
        finalColor = 0xFFEF4444; // Red
      } else if (actual < minVal * 1.5) {
        status = 'Cukup';
        finalColor = 0xFFF59E0B; // Yellow
      } else {
        status = 'Aman';
        finalColor = 0xFF10B981; // Green
      }

      // Format weights
      String actualStr = actual == actual.toInt() 
          ? '${actual.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} kg'
          : '${actual.toStringAsFixed(1)} kg';

      String minStr = minVal == minVal.toInt()
          ? 'Min: ${minVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} kg'
          : 'Min: ${minVal.toStringAsFixed(1)} kg';

      result.add({
        'jenis': jenis,
        'stok': actualStr,
        'minStok': minStr,
        'progress': progress,
        'status': status,
        'color': finalColor,
      });
    });

    return result;
  }

  StokProvider() {
    fetchStok();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void fetchStok() {
    if (_isInitialized) return;
    try {
      _dbRef.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null) {
          try {
            final Map<dynamic, dynamic> rawData = data as Map<dynamic, dynamic>;
            List<Map<String, dynamic>> newList = [];
            rawData.forEach((key, value) {
              final Map<String, dynamic> item = Map<String, dynamic>.from(value as Map);
              item['key'] = key.toString();
              newList.add(item);
            });
            // Urutkan berdasarkan ID (opsional)
            newList.sort((a, b) => (a['id_barang'] ?? '').compareTo(b['id_barang'] ?? ''));
            _stokList = newList;
            _errorMessage = null;
          } catch (castError) {
             _errorMessage = "Gagal memproses data: ${castError.toString()}";
          }
        } else {
          _stokList = [];
          _errorMessage = null;
        }
        notifyListeners();
      }, onError: (Object e) {
        if (e.toString().contains('JavaScriptObject')) {
          print('Ignored Web JS Interop Error: $e');
          return;
        }
        // Handle stream errors (e.g., permission denied)
        _errorMessage = "Gagal memuat data: ${e.toString()}";
        notifyListeners();
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      // Catch synchronous errors without crashing web
      _errorMessage = "Terjadi kesalahan: ${e.toString()}";
      print("Fetch Error: $e");
      notifyListeners();
    }
  }

  Future<bool> addStok(Map<String, dynamic> data) async {
    print('DEBUG ADD STOK: Starting...');
    try {
      // Generate id_barang based on timestamp
      final String generatedId = '#INV${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      data['id_barang'] = generatedId;
      data['tanggal'] = DateTime.now().toIso8601String().substring(0, 10);
      
      print('DEBUG ADD STOK: Data to send -> $data');
      await _dbRef.push().set(data);
      print('DEBUG ADD STOK: Success');
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG ADD STOK ERROR: $e');
      _errorMessage = "Gagal menambah data: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStok(String key, Map<String, dynamic> data) async {
    print('DEBUG UPDATE STOK: key=$key, data=$data');
    try {
      await _dbRef.child(key).update(data);
      print('DEBUG UPDATE STOK: Success');
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG UPDATE STOK ERROR: $e');
      _errorMessage = "Gagal memperbarui data: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStok(String key) async {
    print('DEBUG DELETE STOK: key=$key');
    try {
      await _dbRef.child(key).remove();
      print('DEBUG DELETE STOK: Success');
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG DELETE STOK ERROR: $e');
      _errorMessage = "Gagal menghapus data: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  // Export implementations
  Future<void> exportToPDF(BuildContext context) async {
    debugPrint('DEBUG DOWNLOAD: exportToPDF (Stok) click registered');
    try {
      String txt = 'LAPORAN INVENTORI / STOK BARANG\n\n';
      for (var s in _stokList) {
        txt += 'ID Barang: ${s['id_barang'] ?? '-'}\n';
        txt += 'Nama: ${s['nama'] ?? '-'}\n';
        txt += 'Kategori/Jenis: ${s['jenis'] ?? '-'}\n';
        txt += 'Berat: ${s['berat'] ?? '0'} kg\n';
        txt += 'Rak/Lokasi: ${s['rak'] ?? '-'}\n';
        txt += 'Status: ${s['status'] ?? '-'}\n';
        txt += 'Tanggal Masuk: ${s['tanggal'] ?? '-'}\n';
        txt += '---------------------------\n';
      }
      
      final bytes = utf8.encode(txt);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Inventori.txt')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Inventori.txt');
        await file.writeAsBytes(bytes);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan PDF (TXT) berhasil diunduh'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  Future<void> exportToExcel(BuildContext context) async {
    debugPrint('DEBUG DOWNLOAD: exportToExcel (Stok) click registered');
    try {
      String csv = 'ID Barang,Nama,Jenis,Berat (kg),Rak,Status,Tanggal\n';
      for (var s in _stokList) {
        csv += '${s['id_barang'] ?? '-'},${s['nama'] ?? '-'},${s['jenis'] ?? '-'},${s['berat'] ?? '0'},${s['rak'] ?? '-'},${s['status'] ?? '-'},${s['tanggal'] ?? '-'}\n';
      }
      
      final bytes = utf8.encode(csv);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Inventori.csv')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Inventori.csv');
        await file.writeAsBytes(bytes);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan Excel (CSV) berhasil diunduh'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  void loadStok() {
    // Dipanggil untuk init data manual jika perlu
  }
}