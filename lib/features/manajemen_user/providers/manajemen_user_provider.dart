import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManajemenUserProvider with ChangeNotifier {
  // Web-Safe Firebase Reference (getter pattern — never cached)
  DatabaseReference get _dbRef => FirebaseDatabase.instance.ref('users');
  bool _isInitialized = false;

  // Data user list yang sinkron dengan Firebase
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> get userList => _userList;

  // =============================================
  // DYNAMIC KPI GETTERS (computed from live data)
  // =============================================

  // Task-specific requested getters
  int get totalUsers => _userList.length;
  int get totalAdmins => _userList.where((u) => u['role'] == 'Owner' || u['role'] == 'Admin').length;
  int get totalStaff => _userList.where((u) => u['role'] == 'Staff Gudang').length;
  int get totalDriverAktif => _userList.where((u) => u['role'] == 'Kurir' && u['status'] == 'Aktif').length;

  /// Total user terdaftar
  String get totalUser => _userList.length.toString();

  /// Total admin: Owner + Admin
  String get adminAktif {
    return _userList
        .where((u) => u['role'] == 'Owner' || u['role'] == 'Admin')
        .length
        .toString();
  }

  /// Total Staff Gudang
  String get pegawaiGudang {
    return _userList
        .where((u) => u['role'] == 'Staff Gudang')
        .length
        .toString();
  }

  /// Total Kurir yang statusnya Aktif
  String get kurirDistribusi {
    return _userList
        .where((u) => u['role'] == 'Kurir' && u['status'] == 'Aktif')
        .length
        .toString();
  }

  // Growth sub-text (dynamic)
  String get totalUserGrowth => '${_userList.length} terdaftar';
  String get adminAktifGrowth => 'Aktif';
  String get pegawaiGudangGrowth {
    final total = _userList.where((u) => u['role'] == 'Staff Gudang').length;
    final aktif = _userList.where((u) => u['role'] == 'Staff Gudang' && u['status'] == 'Aktif').length;
    if (total == 0) return '0%';
    return '${((aktif / total) * 100).toStringAsFixed(0)}%';
  }
  String get kurirDistribusiGrowth {
    final total = _userList.where((u) => u['role'] == 'Kurir').length;
    final aktif = _userList.where((u) => u['role'] == 'Kurir' && u['status'] == 'Aktif').length;
    if (total == 0) return '0%';
    return '${((aktif / total) * 100).toStringAsFixed(0)}%';
  }

  // =============================================
  // CONSTRUCTOR & FIREBASE STREAM
  // =============================================
  ManajemenUserProvider() {
    fetchUsers();
  }

  void fetchUsers() {
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
            // Urutkan berdasarkan nama ascending
            newList.sort((a, b) => (a['nama'] ?? '').toString().compareTo((b['nama'] ?? '').toString()));
            _userList = newList;
          } catch (e) {
            print("Cast Error ManajemenUser: $e");
          }
        } else {
          // Seed default data jika node kosong
          seedDefaultData();
        }
        notifyListeners();
      }, onError: (Object e) {
        if (e.toString().contains('JavaScriptObject')) {
          print('Ignored Web JS Interop Error: $e');
          return;
        }
        print("Stream Error ManajemenUser: $e");
      });
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('JavaScriptObject')) {
        print('Ignored Web JS Interop Error: $e');
        return;
      }
      print("Fetch Error ManajemenUser: $e");
    }
  }

  // =============================================
  // SEED DEFAULT DATA
  // =============================================
  Future<void> seedDefaultData() async {
    final List<Map<String, dynamic>> defaultSeeds = [
      {
        'nama': 'H. Muklas',
        'id_user': 'USR001',
        'email': 'muklas@tokotelur.com',
        'role': 'Owner',
        'status': 'Aktif',
        'last_login': '2 menit lalu',
      },
      {
        'nama': 'Ahmad Ridwan',
        'id_user': 'USR002',
        'email': 'ahmad@tokotelur.com',
        'role': 'Admin',
        'status': 'Aktif',
        'last_login': '1 jam lalu',
      },
      {
        'nama': 'Budi Santoso',
        'id_user': 'USR003',
        'email': 'budi@tokotelur.com',
        'role': 'Staff Gudang',
        'status': 'Aktif',
        'last_login': '3 jam lalu',
      },
      {
        'nama': 'Slamet Riyadi',
        'id_user': 'USR004',
        'email': 'slamet@tokotelur.com',
        'role': 'Kurir',
        'status': 'Aktif',
        'last_login': 'Kemarin',
      },
      {
        'nama': 'Joko Susilo',
        'id_user': 'USR005',
        'email': 'joko@tokotelur.com',
        'role': 'Kurir',
        'status': 'Nonaktif',
        'last_login': '3 hari lalu',
      },
    ];

    for (var item in defaultSeeds) {
      await _dbRef.push().set(item);
    }
  }

  // =============================================
  // CRUD OPERATIONS
  // =============================================
  Future<bool> addUser(Map<String, dynamic> data) async {
    try {
      await _dbRef.push().set(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Add User Error: $e");
      return false;
    }
  }

  Future<bool> updateUser(String key, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(key).update(data);
      notifyListeners();
      return true;
    } catch (e) {
      print("Update User Error: $e");
      return false;
    }
  }

  Future<bool> deleteUser(String key) async {
    try {
      await _dbRef.child(key).remove();
      notifyListeners();
      return true;
    } catch (e) {
      print("Delete User Error: $e");
      return false;
    }
  }


  // =============================================
  // HELPER: Generate next user ID
  // =============================================
  String generateUserId() {
    final int nextNumber = _userList.length + 1;
    return 'USR${nextNumber.toString().padLeft(3, '0')}';
  }
}
