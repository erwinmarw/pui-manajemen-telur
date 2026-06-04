import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class KeuanganProvider with ChangeNotifier {
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('keuangan');
  bool _isInitialized = false;

  // Data transaksi List yang sinkron dengan Firebase
  List<Map<String, dynamic>> _transaksiList = [];
  List<Map<String, dynamic>> get transaksiList => _transaksiList;

  // Data Tren Keuangan Bulanan (Line Chart)
  // Index 0-5 = Jul - Des. [Pendapatan, Pengeluaran] in Millions
  final List<List<double>> _trenBulanan = [
    [50, 20], // Jul
    [55, 25], // Ags
    [65, 22], // Sep
    [70, 30], // Okt
    [80, 28], // Nov
    [84.5, 32.2] // Des
  ];
  List<List<double>> get trenBulanan => _trenBulanan;

  // Getters untuk Summary KPI
  int get totalPendapatan {
    int total = 0;
    for (var tx in _transaksiList) {
      if (tx['kategori'] == 'Pendapatan') {
        total += parseNominal(tx['nominal']?.toString() ?? '');
      }
    }
    return total;
  }

  int get totalPengeluaran {
    int total = 0;
    for (var tx in _transaksiList) {
      if (tx['kategori'] == 'Pengeluaran') {
        total += parseNominal(tx['nominal']?.toString() ?? '');
      }
    }
    return total;
  }

  int get totalPendapatanBulanIni {
    final now = DateTime.now();
    int total = 0;
    for (var tx in _transaksiList) {
      if (tx['kategori'] == 'Pendapatan') {
        final dateStr = tx['tanggal']?.toString() ?? '';
        final date = DateTime.tryParse(dateStr);
        if (date != null && date.month == now.month && date.year == now.year) {
          total += parseNominal(tx['nominal']?.toString() ?? '');
        }
      }
    }
    return total;
  }

  int get totalPengeluaranBulanIni {
    final now = DateTime.now();
    int total = 0;
    for (var tx in _transaksiList) {
      if (tx['kategori'] == 'Pengeluaran') {
        final dateStr = tx['tanggal']?.toString() ?? '';
        final date = DateTime.tryParse(dateStr);
        if (date != null && date.month == now.month && date.year == now.year) {
          total += parseNominal(tx['nominal']?.toString() ?? '');
        }
      }
    }
    return total;
  }

  String get pendapatanBulanIni => formatRupiah(totalPendapatanBulanIni);
  String get pengeluaranBulanIni => formatRupiah(totalPengeluaranBulanIni);
  String get keuntunganBersih => formatRupiah(totalPendapatanBulanIni - totalPengeluaranBulanIni);
  String get totalTransaksi => _transaksiList.length.toString();

  // Detail "Total Transaksi" Summary Breakdown
  int get pendapatanCount => _transaksiList.where((tx) => tx['kategori'] == 'Pendapatan').length;
  int get pengeluaranCount => _transaksiList.where((tx) => tx['kategori'] == 'Pengeluaran').length;
  String get transaksiBreakdown => '$pendapatanCount Pemasukan | $pengeluaranCount Pengeluaran';

  // Pie Chart ("Kategori Pengeluaran") grouped dynamically by sub_kategori
  List<Map<String, dynamic>> get kategoriPengeluaran {
    final Map<String, int> colors = {
      'Logistik & Transportasi': 0xFFEF4444,
      'Gaji Pegawai': 0xFFF59E0B,
      'Pengemasan & Retur': 0xFF3B82F6,
      'Operasional Gudang': 0xFF10B981,
    };

    final Map<String, double> totals = {
      'Logistik & Transportasi': 0.0,
      'Gaji Pegawai': 0.0,
      'Pengemasan & Retur': 0.0,
      'Operasional Gudang': 0.0,
    };

    double totalExpenses = 0.0;
    for (var tx in _transaksiList) {
      if (tx['kategori'] == 'Pengeluaran') {
        final String sub = tx['sub_kategori']?.toString() ?? 'Operasional Gudang';
        final int nominal = parseNominal(tx['nominal']?.toString() ?? '');
        if (totals.containsKey(sub)) {
          totals[sub] = totals[sub]! + nominal.toDouble();
          totalExpenses += nominal.toDouble();
        }
      }
    }

    if (totalExpenses == 0.0) {
      // Fallback default values
      return [
        {'nama': 'Logistik & Transportasi', 'persentase': 40.0, 'color': 0xFFEF4444},
        {'nama': 'Gaji Pegawai', 'persentase': 30.0, 'color': 0xFFF59E0B},
        {'nama': 'Pengemasan & Retur', 'persentase': 20.0, 'color': 0xFF3B82F6},
        {'nama': 'Operasional Gudang', 'persentase': 10.0, 'color': 0xFF10B981},
      ];
    }

    final List<Map<String, dynamic>> result = [];
    totals.forEach((name, value) {
      final double pct = (value / totalExpenses) * 100.0;
      result.add({
        'nama': name,
        'persentase': pct,
        'color': colors[name] ?? 0xFF10B981,
      });
    });

    return result;
  }

  // Constructor
  KeuanganProvider() {
    fetchTransaksi();
  }

  // Stream Listener dari Firebase
  void fetchTransaksi() {
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
            // Urutkan berdasarkan tanggal descending
            newList.sort((a, b) => (b['tanggal'] ?? '').compareTo(a['tanggal'] ?? ''));
            _transaksiList = newList;
          } catch (e) {
            print("Cast Error Keuangan: $e");
          }
        } else {
          seedDefaultData();
        }
        notifyListeners();
      }, onError: (Object e) {
        if (e.toString().contains('JavaScriptObject')) {
          print('Ignored Web JS Interop Error: $e');
          return;
        }
        print("Stream Error Keuangan: $e");
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      print("Fetch Error Keuangan: $e");
    }
  }

  // Seeding default data if Firebase node is empty
  Future<void> seedDefaultData() async {
    final List<Map<String, dynamic>> defaultSeeds = [
      {
        'tanggal': '2026-05-25',
        'kategori': 'Pendapatan',
        'sub_kategori': '',
        'deskripsi': 'Penjualan Telur Ayam Negeri (500 kg)',
        'nominal': '+Rp 14.000.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-24',
        'kategori': 'Pengeluaran',
        'sub_kategori': 'Logistik & Transportasi',
        'deskripsi': 'Sewa Truk Logistik Surabaya-Malang',
        'nominal': '-Rp 3.500.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-23',
        'kategori': 'Pengeluaran',
        'sub_kategori': 'Logistik & Transportasi',
        'deskripsi': 'Operasional Bensin & Tol Kurir',
        'nominal': '-Rp 450.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-22',
        'kategori': 'Pendapatan',
        'sub_kategori': '',
        'deskripsi': 'Penjualan Telur Bebek ke Agen Sidoarjo',
        'nominal': '+Rp 3.800.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-20',
        'kategori': 'Pengeluaran',
        'sub_kategori': 'Gaji Pegawai',
        'deskripsi': 'Gaji Staff Gudang Sidoarjo',
        'nominal': '-Rp 4.000.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-19',
        'kategori': 'Pengeluaran',
        'sub_kategori': 'Pengemasan & Retur',
        'deskripsi': 'Pembelian Cardboard Box & Tray Karton',
        'nominal': '-Rp 2.100.000',
        'status': 'Selesai'
      },
      {
        'tanggal': '2026-05-18',
        'kategori': 'Pengeluaran',
        'sub_kategori': 'Operasional Gudang',
        'deskripsi': 'Tagihan Listrik Gudang Utama',
        'nominal': '-Rp 1.200.000',
        'status': 'Selesai'
      },
    ];

    for (var item in defaultSeeds) {
      await _dbRef.push().set(item);
    }
  }

  // CRUD Operations
  Future<bool> addTransaksi(Map<String, dynamic> data) async {
    try {
      await _dbRef.push().set(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Add Transaksi Error: $e");
      return false;
    }
  }

  Future<bool> tambahTransaksi(Map<String, dynamic> data) => addTransaksi(data);

  Future<bool> updateTransaksi(String key, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(key).update(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Update Transaksi Error: $e");
      return false;
    }
  }

  Future<bool> deleteTransaksi(String key) async {
    try {
      await _dbRef.child(key).remove();
      notifyListeners();
      return true;
    } catch (e) {
      print("Delete Transaksi Error: $e");
      return false;
    }
  }

  // Export implementations
  Future<void> exportToPDF(BuildContext context) async {
    debugPrint('DEBUG DOWNLOAD: exportToPDF (Keuangan) click registered');
    try {
      String txt = 'LAPORAN KEUANGAN - PEMASUKAN DAN PENGELUARAN\n\n';
      for (var tx in _transaksiList) {
        txt += 'Tanggal: ${tx['tanggal'] ?? '-'}\n';
        txt += 'Kategori: ${tx['kategori'] ?? '-'}\n';
        txt += 'Sub Kategori: ${tx['sub_kategori'] ?? '-'}\n';
        txt += 'Nominal: ${tx['nominal'] ?? '0'}\n';
        txt += 'Deskripsi: ${tx['deskripsi'] ?? '-'}\n';
        txt += 'Status: ${tx['status'] ?? '-'}\n';
        txt += '---------------------------\n';
      }
      
      final bytes = utf8.encode(txt);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Keuangan.txt')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Keuangan.txt');
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
    debugPrint('DEBUG DOWNLOAD: exportToExcel (Keuangan) click registered');
    try {
      String csv = 'Tanggal,Kategori,Sub Kategori,Nominal,Deskripsi,Status\n';
      for (var tx in _transaksiList) {
        csv += '${tx['tanggal'] ?? '-'},${tx['kategori'] ?? '-'},${tx['sub_kategori'] ?? '-'},${tx['nominal'] ?? '0'},${tx['deskripsi'] ?? '-'},${tx['status'] ?? '-'}\n';
      }
      
      final bytes = utf8.encode(csv);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Keuangan.csv')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Keuangan.csv');
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

  // Helper parsers
  int parseNominal(String nominalStr) {
    String clean = nominalStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  String formatRupiah(int value) {
    String valueStr = value.toString();
    String formatted = valueStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}