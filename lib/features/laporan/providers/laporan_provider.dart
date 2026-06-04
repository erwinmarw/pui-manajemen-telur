import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LaporanProvider with ChangeNotifier {
  // Web-Safe Firebase Reference (getter pattern — never cached)
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('riwayat_laporan');
  bool _isInitialized = false;

  // Data riwayat laporan yang sinkron dengan Firebase
  List<Map<String, dynamic>> _riwayatList = [];
  List<Map<String, dynamic>> get riwayatList => _riwayatList;

  // Kategori Laporan (static metadata for the 4 category cards)
  final List<Map<String, dynamic>> _kategoriLaporan = [
    {
      'title': 'Laporan Inventori',
      'desc': 'Stok, pergerakan barang, dan riwayat',
      'kategori': 'Inventori',
      'color': 0xFF3B82F6,
    },
    {
      'title': 'Laporan Keuangan',
      'desc': 'Pendapatan, pengeluaran, laba rugi',
      'kategori': 'Keuangan',
      'color': 0xFFF59E0B,
    },
    {
      'title': 'Laporan Distribusi',
      'desc': 'Pengiriman, rute, dan performa',
      'kategori': 'Distribusi',
      'color': 0xFF10B981,
    },
    {
      'title': 'Laporan Telur Pecah',
      'desc': 'Analisis kerusakan dan kerugian',
      'kategori': 'Telur Pecah',
      'color': 0xFFEF4444,
    },
  ];

  // =============================================
  // DYNAMIC KPI GETTERS (computed from live data)
  // =============================================

  /// Total laporan pernah digenerate
  String get totalLaporan => _riwayatList.length.toString();

  /// Laporan yang digenerate di bulan ini
  String get laporanBulanIni {
    final now = DateTime.now();
    int count = 0;
    for (var r in _riwayatList) {
      try {
        final dt = DateTime.parse(r['tanggal_raw'] ?? '');
        if (dt.year == now.year && dt.month == now.month) {
          count++;
        }
      } catch (_) {}
    }
    return count.toString();
  }

  /// Export berhasil (status == 'Selesai')
  String get exportBerhasil {
    return _riwayatList.where((r) => r['status'] == 'Selesai').length.toString();
  }

  /// Aktivitas cetak minggu ini
  String get aktivitasCetak {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (var r in _riwayatList) {
      try {
        final dt = DateTime.parse(r['tanggal_raw'] ?? '');
        if (dt.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
          count++;
        }
      } catch (_) {}
    }
    return count.toString();
  }

  // Growth sub-text (dynamic)
  String get totalLaporanGrowth => '${_riwayatList.length} laporan total';
  String get laporanBulanIniGrowth => 'Bulan ${_currentMonthName()}';
  String get exportBerhasilGrowth {
    if (_riwayatList.isEmpty) return '0% sukses rate';
    final rate = (_riwayatList.where((r) => r['status'] == 'Selesai').length / _riwayatList.length * 100).toStringAsFixed(0);
    return '$rate% sukses rate';
  }
  String get aktivitasCetakGrowth => 'Minggu ini';

  // Jumlah per kategori
  String countByKategori(String kategori) {
    return _riwayatList.where((r) => r['kategori'] == kategori).length.toString();
  }

  // Getters
  List<Map<String, dynamic>> get kategoriLaporan => _kategoriLaporan;

  // =============================================
  // CONSTRUCTOR & FIREBASE STREAM
  // =============================================
  LaporanProvider() {
    fetchRiwayat();
  }

  void fetchRiwayat() {
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
            // Urutkan berdasarkan tanggal_raw descending
            newList.sort((a, b) => (b['tanggal_raw'] ?? '').compareTo(a['tanggal_raw'] ?? ''));
            _riwayatList = newList;
          } catch (e) {
            print("Cast Error Laporan: $e");
          }
        } else {
          _riwayatList = [];
        }
        notifyListeners();
      }, onError: (Object e) {
        if (e.toString().contains('JavaScriptObject')) {
          print('Ignored Web JS Interop Error: $e');
          return;
        }
        print("Stream Error Laporan: $e");
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      print("Fetch Error Laporan: $e");
    }
  }

  // =============================================
  // LOG EXPORT ACTIVITY (push to Firebase)
  // =============================================
  Future<void> logExportActivity(String namaLaporan, String kategori, String format) async {
    try {
      final now = DateTime.now();
      final tanggalFormatted = '${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}';
      final jamFormatted = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      await _dbRef.push().set({
        'nama': namaLaporan,
        'kategori': kategori,
        'tanggal': tanggalFormatted,
        'tanggal_raw': now.toIso8601String().substring(0, 10),
        'jam': jamFormatted,
        'format': format,
        'status': 'Selesai',
      });
      notifyListeners();
    } catch (e) {
      print("Log Export Error: $e");
    }
  }

  // =============================================
  // DELETE LOG FROM FIREBASE
  // =============================================
  Future<bool> deleteLog(String key) async {
    try {
      await _dbRef.child(key).remove();
      notifyListeners();
      return true;
    } catch (e) {
      print("Delete Log Error: $e");
      return false;
    }
  }

  // =============================================
  // HELPERS
  // =============================================
  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _currentMonthName() {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[DateTime.now().month - 1];
  }
}
