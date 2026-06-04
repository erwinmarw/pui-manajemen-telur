import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class AnalisisProvider with ChangeNotifier {
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('analisis');
  bool _isInitialized = false;

  List<Map<String, dynamic>> _laporanList = [];
  List<Map<String, dynamic>> get laporanKerusakan => _laporanList;

  // Constructor
  AnalisisProvider() {
    fetchAnalisis();
  }

  // --- Web-Safe Firebase Fetch ---
  void fetchAnalisis() {
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
            _laporanList = newList;
          } catch (e) {
            print("Cast Error Analisis: $e");
          }
        } else {
          _laporanList = [];
        }
        notifyListeners();
      }, onError: (Object e) {
        if (e.toString().contains('JavaScriptObject')) {
          print('Ignored Web JS Interop Error: $e');
          return;
        }
        print("Stream Error Analisis: $e");
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      print("Fetch Error Analisis: $e");
    }
  }

  // --- CRUD Operations ---
  Future<bool> addLaporan(Map<String, dynamic> data) async {
    try {
      await _dbRef.push().set(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Add Laporan Error: $e");
      return false;
    }
  }

  Future<bool> updateLaporan(String key, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(key).update(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Update Laporan Error: $e");
      return false;
    }
  }

  Future<bool> deleteLaporan(String key) async {
    try {
      await _dbRef.child(key).remove();
      notifyListeners();
      return true;
    } catch (e) {
      print("Delete Laporan Error: $e");
      return false;
    }
  }

  // --- Dynamic Getters (Analytics Engine) ---

  // 1. totalTelurPecah
  String get totalTelurPecah {
    double total = 0;
    for (var l in _laporanList) {
      total += (l['pecah'] ?? 0).toDouble();
    }
    return '${total.toStringAsFixed(0)} kg';
  }

  // 2. totalKerugian
  String get totalKerugian {
    double total = 0;
    for (var l in _laporanList) {
      total += (l['kerugian'] ?? 0).toDouble();
    }
    return formatRupiah(total.toInt());
  }

  // 3. persentaseKerusakanGlobal
  String get persentaseKerusakan {
    double totalPecah = 0;
    double totalDikirim = 0;
    for (var l in _laporanList) {
      totalPecah += (l['pecah'] ?? 0).toDouble();
      totalDikirim += (l['dikirim'] ?? 0).toDouble();
    }
    if (totalDikirim == 0) return '0.0%';
    double pct = (totalPecah / totalDikirim) * 100;
    return '${pct.toStringAsFixed(1)}%';
  }

  // 4. ruteRisikoTertinggi (Nama rute saja)
  String get ruteRisikoTertinggi {
    Map<String, List<double>> ruteStats = {}; 
    for (var l in _laporanList) {
      String rute = _singkatRute(l['tujuan'] ?? 'Unknown');
      double pecah = (l['pecah'] ?? 0).toDouble();
      double dikirim = (l['dikirim'] ?? 0).toDouble();
      if (!ruteStats.containsKey(rute)) {
        ruteStats[rute] = [0.0, 0.0];
      }
      ruteStats[rute]![0] += pecah;
      ruteStats[rute]![1] += dikirim;
    }

    String maxRute = 'Aman';
    double maxPct = -1;
    ruteStats.forEach((rute, stats) {
      double pct = stats[1] == 0 ? 0 : (stats[0] / stats[1]) * 100;
      if (pct > maxPct) {
        maxPct = pct;
        maxRute = rute;
      }
    });
    return maxRute;
  }

  // Peringatan Dinamis
  String get peringatanRuteTertinggi {
    Map<String, List<double>> ruteStats = {}; 
    for (var l in _laporanList) {
      String rute = l['tujuan'] ?? 'Unknown';
      double pecah = (l['pecah'] ?? 0).toDouble();
      double dikirim = (l['dikirim'] ?? 0).toDouble();
      if (!ruteStats.containsKey(rute)) {
        ruteStats[rute] = [0.0, 0.0];
      }
      ruteStats[rute]![0] += pecah;
      ruteStats[rute]![1] += dikirim;
    }

    String maxRute = '';
    double maxPct = 0;
    ruteStats.forEach((rute, stats) {
      double pct = stats[1] == 0 ? 0 : (stats[0] / stats[1]) * 100;
      if (pct > maxPct) {
        maxPct = pct;
        maxRute = rute;
      }
    });

    if (maxPct == 0) return 'Sistem mendeteksi tingkat kerusakan dalam batas aman untuk semua rute.';
    return 'Rute $maxRute mencatat tingkat kerusakan tertinggi (${maxPct.toStringAsFixed(1)}%). Segera lakukan inspeksi kendaraan dan perbaikan kemasan.';
  }

  // 5. pieChartData (Penyebab Kerusakan)
  List<Map<String, dynamic>> get penyebabKerusakan {
    Map<String, double> penyebabTotals = {};
    double totalPecah = 0;
    for (var l in _laporanList) {
      String p = l['penyebab'] ?? 'Lainnya';
      double pecah = (l['pecah'] ?? 0).toDouble();
      penyebabTotals[p] = (penyebabTotals[p] ?? 0) + pecah;
      totalPecah += pecah;
    }

    if (totalPecah == 0) {
      return [
        {'penyebab': 'Aman', 'value': 100.0, 'color': 0xFF10B981}
      ];
    }

    final colors = [0xFFEF4444, 0xFFF59E0B, 0xFF3B82F6, 0xFF8B5CF6, 0xFFF97316];
    List<Map<String, dynamic>> result = [];
    int i = 0;
    penyebabTotals.forEach((key, value) {
      result.add({
        'penyebab': key,
        'value': (value / totalPecah) * 100,
        'color': colors[i % colors.length]
      });
      i++;
    });
    result.sort((a,b) => (b['value'] as double).compareTo(a['value'] as double));
    return result;
  }

  // 6. kerusakanPerRute (Progress Bars)
  List<Map<String, dynamic>> get kerusakanPerRute {
    Map<String, List<double>> ruteStats = {}; 
    for (var l in _laporanList) {
      String rute = _singkatRute(l['tujuan'] ?? '');
      double pecah = (l['pecah'] ?? 0).toDouble();
      double dikirim = (l['dikirim'] ?? 0).toDouble();
      if (!ruteStats.containsKey(rute)) {
        ruteStats[rute] = [0.0, 0.0];
      }
      ruteStats[rute]![0] += pecah;
      ruteStats[rute]![1] += dikirim;
    }

    List<Map<String, dynamic>> result = [];
    ruteStats.forEach((rute, stats) {
      double pct = stats[1] == 0 ? 0 : (stats[0] / stats[1]) * 100;
      int color = pct > 4 ? 0xFFEF4444 : (pct > 2 ? 0xFFF59E0B : 0xFF10B981);
      result.add({
        'rute': rute,
        'kerusakan': double.parse(pct.toStringAsFixed(1)),
        'color': color,
      });
    });
    result.sort((a,b) => (b['kerusakan'] as double).compareTo(a['kerusakan'] as double));
    return result.take(5).toList(); // Ambil Top 5
  }

  // 7. perbandinganKendaraan
  List<Map<String, dynamic>> get perbandinganKendaraan {
    Map<String, List<double>> kendaraanStats = {}; 
    for (var l in _laporanList) {
      String kend = l['kendaraan'] ?? 'Lainnya';
      double pecah = (l['pecah'] ?? 0).toDouble();
      double dikirim = (l['dikirim'] ?? 0).toDouble();
      if (!kendaraanStats.containsKey(kend)) {
        kendaraanStats[kend] = [0.0, 0.0];
      }
      kendaraanStats[kend]![0] += pecah;
      kendaraanStats[kend]![1] += dikirim;
    }

    List<Map<String, dynamic>> result = [];
    kendaraanStats.forEach((kend, stats) {
      double pct = stats[1] == 0 ? 0 : (stats[0] / stats[1]) * 100;
      int color = pct > 4 ? 0xFFEF4444 : (pct > 2 ? 0xFFF59E0B : 0xFF3B82F6);
      result.add({
        'tipe': kend,
        'kerusakan': double.parse(pct.toStringAsFixed(1)),
        'color': color,
      });
    });
    result.sort((a,b) => (b['kerusakan'] as double).compareTo(a['kerusakan'] as double));
    return result.take(3).toList();
  }

  // 8. trendBulanan (Dynamic Bar Chart data based on timeframe)
  Map<String, dynamic> getTrendDataAndLabels(String timeframe) {
    int monthsCount = 6;
    if (timeframe == '3 Bulan') {
      monthsCount = 3;
    } else if (timeframe == '1 Tahun') {
      monthsCount = 12;
    }

    List<double> trend = List.filled(monthsCount, 0.0);
    List<String> labels = List.filled(monthsCount, '');

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

    if (_laporanList.isEmpty) {
      DateTime now = DateTime.now();
      for (int i = monthsCount - 1; i >= 0; i--) {
        int targetMonthIndex = (now.month - 1) - i;
        if (targetMonthIndex < 0) targetMonthIndex += 12;
        labels[monthsCount - 1 - i] = monthNames[targetMonthIndex];
      }
      return {'data': trend, 'labels': labels};
    }

    Map<int, double> monthPecah = {};
    for (var l in _laporanList) {
      try {
        DateTime dt = DateTime.parse(l['tanggal']);
        int m = dt.month - 1; // 0-11
        monthPecah[m] = (monthPecah[m] ?? 0) + (l['pecah'] ?? 0).toDouble();
      } catch (e) {
        // Ignore parse errors
      }
    }

    DateTime now = DateTime.now();
    for (int i = monthsCount - 1; i >= 0; i--) {
      int targetMonthIndex = (now.month - 1) - i;
      if (targetMonthIndex < 0) targetMonthIndex += 12;
      trend[monthsCount - 1 - i] = monthPecah[targetMonthIndex] ?? 0;
      labels[monthsCount - 1 - i] = monthNames[targetMonthIndex];
    }

    return {'data': trend, 'labels': labels};
  }

  List<double> get trendBulanan {
    return getTrendDataAndLabels('6 Bulan')['data'];
  }

  // --- Helpers ---
  String _singkatRute(String ruteLengkap) {
    final parts = ruteLengkap.split('-');
    if (parts.length != 2) return ruteLengkap;
    return '${_singkatKota(parts[0].trim())} - ${_singkatKota(parts[1].trim())}';
  }

  String _singkatKota(String kota) {
    if (kota.toLowerCase() == 'surabaya') return 'Sby';
    if (kota.toLowerCase() == 'malang') return 'Mlg';
    if (kota.toLowerCase() == 'sidoarjo') return 'Sda';
    if (kota.toLowerCase() == 'gresik') return 'Grk';
    if (kota.toLowerCase() == 'mojokerto') return 'Mjk';
    if (kota.toLowerCase() == 'tuban') return 'Tbn';
    return kota.substring(0, kota.length > 3 ? 3 : kota.length);
  }

  String formatRupiah(int value) {
    String valueStr = value.toString();
    String formatted = valueStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  // --- Export using universal_html on Web, path_provider on Mobile ---
  Future<void> exportToExcel(BuildContext context) async {
    try {
      String csv = 'Tanggal,Tujuan,Kendaraan,Dikirim (kg),Pecah (kg),Penyebab,Kerugian,Status\n';
      for (var l in _laporanList) {
        csv += '${l['tanggal']},${l['tujuan']},${l['kendaraan'] ?? '-'},${l['dikirim']},${l['pecah']},${l['penyebab']},${l['kerugian']},${l['status']}\n';
      }
      
      final bytes = utf8.encode(csv);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Kerusakan_Telur.csv')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Kerusakan_Telur.csv');
        await file.writeAsBytes(bytes);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb
              ? 'Laporan Excel (CSV) berhasil diunduh'
              : 'Laporan Excel (CSV) disimpan di perangkat'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }

  Future<void> exportToPDF(BuildContext context) async {
    try {
      String txt = 'LAPORAN KERUSAKAN TELUR\n\n';
      for (var l in _laporanList) {
        txt += 'Tanggal: ${l['tanggal']}\n';
        txt += 'Rute: ${l['tujuan']}\n';
        txt += 'Kendaraan: ${l['kendaraan'] ?? '-'}\n';
        txt += 'Dikirim: ${l['dikirim']} kg\n';
        txt += 'Pecah: ${l['pecah']} kg\n';
        txt += 'Penyebab: ${l['penyebab']}\n';
        txt += 'Kerugian: Rp ${l['kerugian']}\n';
        txt += 'Status: ${l['status']}\n';
        txt += '---------------------------\n';
      }
      
      final bytes = utf8.encode(txt);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Kerusakan_Telur.txt')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Kerusakan_Telur.txt');
        await file.writeAsBytes(bytes);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb
              ? 'Laporan PDF (TXT) berhasil diunduh'
              : 'Laporan PDF (TXT) disimpan di perangkat'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
  }
}