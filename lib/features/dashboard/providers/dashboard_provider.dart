import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  // 1. Top Summary Cards Data
  final String _penjualanHariIni = 'Rp 8.450.000';
  final String _stokTersedia = '4.000';
  final String _pengirimanAktif = '18';
  final String _telurPecah = '284';

  final String _penjualanGrowth = '+12.5%';
  final String _stokStatus = 'Rendah';
  final String _pengirimanStatus = 'Aktif';
  final String _telurPecahRatio = '2.3%';

  // 2. Revenue Chart Data by Timeframe (Weekly, Monthly, Yearly)
  final String _activeTimeframe = 'Bulan'; // 'Minggu', 'Bulan', 'Tahun'

  final List<double> _weeklyRevenue = [1.2, 1.8, 1.5, 2.2, 2.0, 2.8, 1.9]; // In Millions
  final List<String> _weeklyLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  final List<double> _monthlyRevenue = [3.0, 4.0, 3.5, 5.0, 4.0, 6.0, 5.5, 7.0, 6.5, 8.0, 7.5, 8.45]; // In Millions
  final List<String> _monthlyLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

  final List<double> _yearlyRevenue = [45.0, 62.0, 84.5]; // In Millions
  final List<String> _yearlyLabels = ['2024', '2025', '2026'];

  // 3. Sales Distribution Pie Chart Data
  final List<Map<String, dynamic>> _salesDistribution = [
    {'kategori': 'Telur Ayam Negeri', 'value': 40.0, 'color': 0xFFF59E0B},
    {'kategori': 'Telur Ayam Kampung', 'value': 30.0, 'color': 0xFFD97706},
    {'kategori': 'Telur Bebek', 'value': 30.0, 'color': 0xFF3B82F6},
  ];

  // 4. Recent Shipments
  final List<Map<String, dynamic>> _recentShipments = [
    {
      'tujuan': 'Toko Berkah Jaya',
      'detail': '50 kg - Dikirim',
      'status': 'Selesai',
      'icon': Icons.check_circle,
      'color': 0xFF10B981,
    },
    {
      'tujuan': 'Warung Maju Makmur',
      'detail': '70 kg - Dalam Perjalanan',
      'status': 'Proses',
      'icon': Icons.local_shipping,
      'color': 0xFF3B82F6,
    },
    {
      'tujuan': 'Pasar Sentral',
      'detail': '55 kg - Menunggu',
      'status': 'Pending',
      'icon': Icons.access_time_filled,
      'color': 0xFFF59E0B,
    },
  ];

  // 5. Stock Progress
  final List<Map<String, dynamic>> _eggStocks = [
    {
      'jenis': 'Telur Ayam Negeri',
      'stok': '3.000 kg',
      'minStok': 'Min: 1.000 kg',
      'progress': 0.8,
      'status': 'Aman',
      'color': 0xFF10B981,
    },
    {
      'jenis': 'Telur Ayam Kampung',
      'stok': '800 kg',
      'minStok': 'Min: 1.000 kg',
      'progress': 0.25,
      'status': 'Rendah',
      'color': 0xFFEF4444,
    },
    {
      'jenis': 'Telur Bebek',
      'stok': '1.200 kg',
      'minStok': 'Min: 800 kg',
      'progress': 0.45,
      'status': 'Cukup',
      'color': 0xFFF59E0B,
    },
    {
      'jenis': 'Telur Puyuh',
      'stok': '500 kg',
      'minStok': 'Min: 600 kg',
      'progress': 0.35,
      'status': 'Rendah',
      'color': 0xFFEF4444,
    },
  ];

  // 6. Damaged Eggs (Analisis Telur Pecah) Pie Chart Data
  final List<Map<String, dynamic>> _eggDamageCauses = [
    {'penyebab': 'Rute Jalan Rusak', 'value': 45.0, 'color': 0xFFEF4444},
    {'penyebab': 'Handling Kurang Baik', 'value': 30.0, 'color': 0xFFF59E0B},
    {'penyebab': 'Pengemasan Longgar', 'value': 25.0, 'color': 0xFF3B82F6},
  ];

  // 7. Notifications List
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Stok Rendah!',
      'desc': 'Telur Ayam Kampung berada di bawah batas minimum.',
      'time': '5 menit lalu',
      'type': 'danger',
      'icon': Icons.warning_amber_rounded,
      'color': 0xFFEF4444,
    },
    {
      'title': 'Pengiriman Selesai',
      'desc': 'Toko Berkah Jaya telah menerima 50 kg telur.',
      'time': '30 menit lalu',
      'type': 'success',
      'icon': Icons.check_circle_outline_rounded,
      'color': 0xFF10B981,
    },
    {
      'title': 'Pembayaran Masuk',
      'desc': 'Menerima pembayaran Rp 2.500.000 dari Toko Berkah.',
      'time': '1 jam lalu',
      'type': 'info',
      'icon': Icons.account_balance_wallet_outlined,
      'color': 0xFF3B82F6,
    },
    {
      'title': 'Kerusakan Terdeteksi',
      'desc': 'Laporan telur pecah tinggi di rute Surabaya-Malang.',
      'time': '2 jam lalu',
      'type': 'warning',
      'icon': Icons.broken_image_outlined,
      'color': 0xFFF59E0B,
    },
  ];

  // Selected Timeframe for revenue chart
  String _selectedTimeframe = 'Bulan';
  String get selectedTimeframe => _selectedTimeframe;

  void setTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }

  // Getters
  String get penjualanHariIni => _penjualanHariIni;
  String get stokTersedia => _stokTersedia;
  String get pengirimanAktif => _pengirimanAktif;
  String get telurPecah => _telurPecah;

  String get penjualanGrowth => _penjualanGrowth;
  String get stokStatus => _stokStatus;
  String get pengirimanStatus => _pengirimanStatus;
  String get telurPecahRatio => _telurPecahRatio;

  List<double> get activeRevenueData {
    if (_selectedTimeframe == 'Minggu') return _weeklyRevenue;
    if (_selectedTimeframe == 'Tahun') return _yearlyRevenue;
    return _monthlyRevenue;
  }

  List<String> get activeRevenueLabels {
    if (_selectedTimeframe == 'Minggu') return _weeklyLabels;
    if (_selectedTimeframe == 'Tahun') return _yearlyLabels;
    return _monthlyLabels;
  }

  List<Map<String, dynamic>> get salesDistribution => _salesDistribution;
  List<Map<String, dynamic>> get recentShipments => _recentShipments;
  List<Map<String, dynamic>> get eggStocks => _eggStocks;
  List<Map<String, dynamic>> get eggDamageCauses => _eggDamageCauses;
  List<Map<String, dynamic>> get notifications => _notifications;
}
