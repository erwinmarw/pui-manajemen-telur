import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DistribusiProvider with ChangeNotifier {
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('distribusi');
  bool _isInitialized = false;

  // Data pengiriman yang sinkron dengan Firebase
  List<Map<String, dynamic>> _daftarPengiriman = [];
  List<Map<String, dynamic>> get daftarPengiriman => _daftarPengiriman;

  // =============================================
  // DYNAMIC KPI GETTERS (computed from live data)
  // =============================================
  String get pengirimanHariIni => _daftarPengiriman.length.toString();

  int get _dalamPerjalananCount =>
      _daftarPengiriman.where((s) => s['status'] == 'Dalam Perjalanan' || s['status'] == 'Perjalanan').length;
  String get dalamPerjalanan => _dalamPerjalananCount.toString();

  int get _pengirimanSelesaiCount =>
      _daftarPengiriman.where((s) => s['status'] == 'Selesai').length;
  String get pengirimanSelesai => _pengirimanSelesaiCount.toString();

  int get totalPending =>
      _daftarPengiriman.where((s) => s['status'] == 'Pending').length;
  String get pengirimanPending => totalPending.toString();

  int get totalDibatalkan =>
      _daftarPengiriman.where((s) => s['status'] == 'Dibatalkan').length;
  String get pengirimanDibatalkan => totalDibatalkan.toString();

  String get totalDikirim {
    double total = 0;
    for (var s in _daftarPengiriman) {
      final jumlahStr = (s['jumlah'] ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), '');
      total += double.tryParse(jumlahStr) ?? 0;
    }
    if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}K';
    }
    return '${total.toStringAsFixed(0)}';
  }

  // =============================================
  // DYNAMIC TIMELINE (derived from live data)
  // =============================================
  List<Map<String, dynamic>> get timelineList {
    List<Map<String, dynamic>> timeline = [];
    for (var s in _daftarPengiriman) {
      final String status = s['status']?.toString() ?? 'Pending';
      String title;
      String desc;

      if (status == 'Selesai') {
        title = 'Pengiriman Tiba & Selesai';
        desc = '${s['tujuan']} (${s['jumlah']} telur diterima)';
      } else if (status == 'Dalam Perjalanan' || status == 'Perjalanan') {
        title = 'Kurir Dalam Perjalanan';
        desc = '${s['tujuan']} (${s['jumlah']} telur, supir ${s['supir']})';
      } else {
        title = 'Pengiriman Dijadwalkan';
        desc = 'Order ${s['id']} untuk ${s['tujuan']} masuk antrean';
      }

      timeline.add({
        'title': title,
        'desc': desc,
        'time': s['estimasi'] ?? '-',
        'status': status,
      });
    }
    return timeline;
  }

  // =============================================
  // CONSTRUCTOR & FIREBASE STREAM
  // =============================================
  DistribusiProvider() {
    fetchDistribusi();
  }

  void fetchDistribusi() {
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
            // Urutkan: Pending pertama, lalu Perjalanan, lalu Selesai
            const statusOrder = {'Pending': 0, 'Perjalanan': 1, 'Selesai': 2};
            newList.sort((a, b) {
              final orderA = statusOrder[a['status']] ?? 3;
              final orderB = statusOrder[b['status']] ?? 3;
              return orderA.compareTo(orderB);
            });
            _daftarPengiriman = newList;
          } catch (e) {
            print("Cast Error Distribusi: $e");
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
        print("Stream Error Distribusi: $e");
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      print("Fetch Error Distribusi: $e");
    }
  }

  // =============================================
  // SEED DEFAULT DATA
  // =============================================
  Future<void> seedDefaultData() async {
    final List<Map<String, dynamic>> defaultSeeds = [
      {
        'id': '#DIS-001',
        'tujuan': 'Toko Sinar Jaya',
        'alamat': 'Jl. Kenanga No. 12, Malang',
        'kendaraan': 'L300 (N 8271 AB)',
        'jenis_telur': 'Telur Ayam Negeri',
        'jumlah': '850 kg',
        'supir': 'Slamet Riyadi',
        'status': 'Selesai',
        'estimasi': '-',
      },
      {
        'id': '#DIS-002',
        'tujuan': 'Pasar Kramat Jati',
        'alamat': 'Kios B-14, Kramat Jati, Jakarta',
        'kendaraan': 'Truk Engkel (B 9182 T)',
        'jenis_telur': 'Telur Ayam Kampung',
        'jumlah': '1200 kg',
        'supir': 'Budi Santoso',
        'status': 'Perjalanan',
        'estimasi': '30 menit',
      },
      {
        'id': '#DIS-003',
        'tujuan': 'Warung Bu Ani',
        'alamat': 'Gg. Mangga II, Surabaya',
        'kendaraan': 'Carry PickUp (L 1290 XY)',
        'jenis_telur': 'Telur Bebek',
        'jumlah': '300 kg',
        'supir': 'Joko Susilo',
        'status': 'Selesai',
        'estimasi': '-',
      },
      {
        'id': '#DIS-004',
        'tujuan': 'Agen Telur Berkah',
        'alamat': 'Ruko Sentosa No. 5, Sidoarjo',
        'kendaraan': 'L300 (N 8271 AB)',
        'jenis_telur': 'Telur Puyuh',
        'jumlah': '750 kg',
        'supir': 'Slamet Riyadi',
        'status': 'Pending',
        'estimasi': 'Besok',
      },
    ];

    for (var item in defaultSeeds) {
      await _dbRef.push().set(item);
    }
  }

  // =============================================
  // CRUD OPERATIONS
  // =============================================
  Future<bool> addPengiriman(Map<String, dynamic> data) async {
    try {
      // Auto-generate ID
      final int nextNumber = _daftarPengiriman.length + 1;
      data['id'] = '#DIS-${nextNumber.toString().padLeft(3, '0')}';
      // Default status
      data['status'] = 'Pending';
      data['key'] = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Insert at the top locally for immediate feedback
      _daftarPengiriman.insert(0, data);
      notifyListeners();

      // Save to Firebase asynchronously
      final newRef = _dbRef.push();
      data['key'] = newRef.key;
      await newRef.set(data);
      return true;
    } catch (e) {
      print("Add Pengiriman Error: $e");
      return false;
    }
  }

  Future<bool> updatePengiriman(String key, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(key).update(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Update Pengiriman Error: $e");
      return false;
    }
  }

  Future<bool> deletePengiriman(String key) async {
    try {
      await _dbRef.child(key).remove();
      notifyListeners();
      return true;
    } catch (e) {
      print("Delete Pengiriman Error: $e");
      return false;
    }
  }

  // Export implementations
  Future<void> exportToPDF(BuildContext context) async {
    debugPrint('DEBUG DOWNLOAD: exportToPDF (Distribusi) click registered');
    try {
      String txt = 'LAPORAN DISTRIBUSI PENGIRIMAN\n\n';
      for (var s in _daftarPengiriman) {
        txt += 'ID Pengiriman: ${s['id'] ?? '-'}\n';
        txt += 'Tanggal: ${s['tanggal'] ?? '-'}\n';
        txt += 'Tujuan: ${s['tujuan'] ?? '-'}\n';
        txt += 'Alamat: ${s['alamat'] ?? '-'}\n';
        txt += 'Jenis Telur: ${s['jenis_telur'] ?? '-'}\n';
        txt += 'Jumlah: ${s['jumlah'] ?? '0'}\n';
        txt += 'Supir: ${s['supir'] ?? '-'}\n';
        txt += 'Kendaraan: ${s['kendaraan'] ?? '-'}\n';
        txt += 'Status: ${s['status'] ?? '-'}\n';
        txt += '---------------------------\n';
      }
      
      final bytes = utf8.encode(txt);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Distribusi.txt')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Distribusi.txt');
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
    debugPrint('DEBUG DOWNLOAD: exportToExcel (Distribusi) click registered');
    try {
      String csv = 'ID,Tanggal,Tujuan,Alamat,Jenis Telur,Jumlah,Supir,Kendaraan,Status\n';
      for (var s in _daftarPengiriman) {
        csv += '${s['id'] ?? '-'},${s['tanggal'] ?? '-'},${s['tujuan'] ?? '-'},${s['alamat'] ?? '-'},${s['jenis_telur'] ?? '-'},${s['jumlah'] ?? '0'},${s['supir'] ?? '-'},${s['kendaraan'] ?? '-'},${s['status'] ?? '-'}\n';
      }
      
      final bytes = utf8.encode(csv);
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_Distribusi.csv')
          ..click();
        Future.delayed(const Duration(seconds: 5), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/Laporan_Distribusi.csv');
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
}