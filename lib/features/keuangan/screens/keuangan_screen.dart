import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/keuangan_provider.dart';
import '../../auth/providers/user_provider.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({Key? key}) : super(key: key);

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';

  // Dialog Tambah / Ubah Transaksi
  void _showTransactionDialog(BuildContext context, [Map<String, dynamic>? item]) {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();
    
    final tanggalController = TextEditingController(
        text: isEdit ? item['tanggal'] : DateTime.now().toIso8601String().substring(0, 10));
    final deskripsiController = TextEditingController(text: isEdit ? item['deskripsi'] : '');
    
    // Parse nominal for display (strip Rp, +, - and dots)
    String initialNominalStr = '';
    if (isEdit) {
      initialNominalStr = item['nominal'].replaceAll(RegExp(r'[^0-9]'), '');
    }
    final nominalController = TextEditingController(text: initialNominalStr);
    
    String selectedKategori = isEdit ? item['kategori'] : 'Pendapatan';
    String selectedSubKategori = (isEdit && item['sub_kategori'] != null && item['sub_kategori'] != '') 
        ? item['sub_kategori'] 
        : 'Logistik & Transportasi';
    String selectedStatus = isEdit ? item['status'] : 'Selesai';

    final subCategories = [
      'Logistik & Transportasi',
      'Gaji Pegawai',
      'Pengemasan & Retur',
      'Operasional Gudang',
    ];

    showDialog(
      context: context,
      builder: (context) {
        final fieldBg = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background;
        final fieldBorder = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(isEdit ? 'Ubah Transaksi' : 'Tambah Transaksi', style: AppTextStyles.h3),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tanggal Form Field
                      TextFormField(
                        controller: tanggalController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal',
                          hintText: 'Format: YYYY-MM-DD',
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Tanggal wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      // Kategori (Pendapatan / Pengeluaran) Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedKategori,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tipe Transaksi',
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                        ),
                        items: ['Pendapatan', 'Pengeluaran'].map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedKategori = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Sub-kategori Dropdown (only visible for Pengeluaran)
                      if (selectedKategori == 'Pengeluaran') ...[
                        DropdownButtonFormField<String>(
                          value: selectedSubKategori,
                          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Kategori Pengeluaran',
                            filled: true,
                            fillColor: fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: fieldBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: fieldBorder),
                            ),
                          ),
                          items: subCategories.map((sub) {
                            return DropdownMenuItem(
                              value: sub,
                              child: Text(
                                sub,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedSubKategori = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Deskripsi Form Field
                      TextFormField(
                        controller: deskripsiController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Contoh: Sewa Truk box / Pembelian Kardus',
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Nominal Form Field
                      TextFormField(
                        controller: nominalController,
                        decoration: InputDecoration(
                          labelText: 'Nominal (Rp)',
                          hintText: 'Contoh: 1500000',
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nominal wajib diisi';
                          final cleanedValue = value.replaceAll('.', '').trim();
                          final numValue = num.tryParse(cleanedValue);
                          if (numValue == null) return 'Harus berupa angka';
                          if (numValue < 0) return 'Tidak boleh negatif';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status (Selesai / Pending) Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                        ),
                        items: ['Selesai', 'Pending'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedStatus = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = Provider.of<KeuanganProvider>(context, listen: false);
                      
                      // Format nominal correctly
                      final int rawNominal = int.parse(nominalController.text.replaceAll('.', ''));
                      final String prefix = selectedKategori == 'Pendapatan' ? '+' : '-';
                      
                      // Formatted nominal string: e.g. "+Rp 14.000.000"
                      final String formattedNominal = '$prefix${provider.formatRupiah(rawNominal)}';

                      final payload = {
                        'tanggal': tanggalController.text,
                        'kategori': selectedKategori,
                        'sub_kategori': selectedKategori == 'Pengeluaran' ? selectedSubKategori : '',
                        'deskripsi': deskripsiController.text,
                        'nominal': formattedNominal,
                        'status': selectedStatus,
                      };

                      bool success;
                      if (isEdit) {
                        success = await provider.updateTransaksi(item['key'], payload);
                      } else {
                        success = await provider.addTransaksi(payload);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                                ? (isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil ditambahkan') 
                                : 'Terjadi kesalahan saat menyimpan data'),
                            backgroundColor: success ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data yang diinputkan tidak sesuai. Periksa kembali form Anda.'),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus Transaksi
  void _showDeleteDialog(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Hapus Transaksi', style: AppTextStyles.h3),
          content: const Text('Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final provider = Provider.of<KeuanganProvider>(context, listen: false);
                final success = await provider.deleteTransaksi(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Transaksi berhasil dihapus' : 'Gagal menghapus transaksi'),
                      backgroundColor: success ? AppColors.success : AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Membaca data dari Provider secara dinamis
    final keuanganData = Provider.of<KeuanganProvider>(context);
    final String currentUserRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Filter transaksiList dynamically
    final filteredTransactions = keuanganData.transaksiList.where((tx) {
      final matchesSearch = (tx['deskripsi'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (tx['kategori'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua Kategori' || tx['kategori'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Cards (Responsive Wrap Grid)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobileLayout = width < 600;
              final cardWidth = isMobileLayout
                  ? (width - 16) / 2
                  : (width - 48) / 4;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildFinanceCard('Pendapatan Bulan Ini', keuanganData.pendapatanBulanIni, '+12.5%', true, Icons.trending_up_rounded, AppColors.success),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildFinanceCard('Pengeluaran Bulan Ini', keuanganData.pengeluaranBulanIni, '-5.2%', false, Icons.trending_down_rounded, AppColors.danger),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildFinanceCard('Keuntungan Bersih', keuanganData.keuntunganBersih, '+18.7%', true, Icons.pie_chart_outline_rounded, AppColors.info),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildTotalTransaksiCard(keuanganData),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Charts Section
          if (isMobile) ...[
            _buildSectionCard(
              'Tren Pendapatan vs Pengeluaran',
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (val, meta) {
                            if (val % 20 == 0) {
                              return Text('${val.toInt()} JT', style: const TextStyle(fontSize: 10, color: AppColors.textLight));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const bulan = ['Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
                            if (value.toInt() >= 0 && value.toInt() < bulan.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(bulan[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Pendapatan Line (Green)
                      LineChartBarData(
                        spots: List.generate(keuanganData.trenBulanan.length, (idx) {
                          return FlSpot(idx.toDouble(), keuanganData.trenBulanan[idx][0]);
                        }),
                        isCurved: true,
                        color: AppColors.success,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: true, color: AppColors.success.withOpacity(0.05)),
                      ),
                      // Pengeluaran Line (Red)
                      LineChartBarData(
                        spots: List.generate(keuanganData.trenBulanan.length, (idx) {
                          return FlSpot(idx.toDouble(), keuanganData.trenBulanan[idx][1]);
                        }),
                        isCurved: true,
                        color: AppColors.danger,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: true, color: AppColors.danger.withOpacity(0.05)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              'Kategori Pengeluaran',
              SizedBox(
                height: 250,
                child: Column(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: keuanganData.kategoriPengeluaran.map((data) {
                            return PieChartSectionData(
                              color: Color(data['color']),
                              value: data['persentase'],
                              title: '${data['persentase'].toInt()}%',
                              radius: 25,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: keuanganData.kategoriPengeluaran.map((data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: Color(data['color']), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['nama'],
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Tren Pendapatan vs Pengeluaran (Line Chart)
                Expanded(
                  flex: 2,
                  child: _buildSectionCard(
                    'Tren Pendapatan vs Pengeluaran',
                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                getTitlesWidget: (val, meta) {
                                  if (val % 20 == 0) {
                                    return Text('${val.toInt()} JT', style: const TextStyle(fontSize: 10, color: AppColors.textLight));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const bulan = ['Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
                                  if (value.toInt() >= 0 && value.toInt() < bulan.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(bulan[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Pendapatan Line (Green)
                            LineChartBarData(
                              spots: List.generate(keuanganData.trenBulanan.length, (idx) {
                                return FlSpot(idx.toDouble(), keuanganData.trenBulanan[idx][0]);
                              }),
                              isCurved: true,
                              color: AppColors.success,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(show: true, color: AppColors.success.withOpacity(0.05)),
                            ),
                            // Pengeluaran Line (Red)
                            LineChartBarData(
                              spots: List.generate(keuanganData.trenBulanan.length, (idx) {
                                return FlSpot(idx.toDouble(), keuanganData.trenBulanan[idx][1]);
                              }),
                              isCurved: true,
                              color: AppColors.danger,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(show: true, color: AppColors.danger.withOpacity(0.05)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Kategori Pengeluaran (Pie Chart)
                Expanded(
                  flex: 1,
                  child: _buildSectionCard(
                    'Kategori Pengeluaran',
                    SizedBox(
                      height: 250,
                      child: Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                                sections: keuanganData.kategoriPengeluaran.map((data) {
                                  return PieChartSectionData(
                                    color: Color(data['color']),
                                    value: data['persentase'],
                                    title: '${data['persentase'].toInt()}%',
                                    radius: 25,
                                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: keuanganData.kategoriPengeluaran.map((data) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: Color(data['color']), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        data['nama'],
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // 3. Table Riwayat Transaksi
          _buildSectionCard(
            'Riwayat Transaksi',
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Search Bar
                          Container(
                            width: isMobile ? double.infinity : 200,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 18, color: AppColors.textLight),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: const InputDecoration(
                                      hintText: 'Cari transaksi...',
                                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Dropdown filter
                          Container(
                            width: isMobile ? double.infinity : null,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                    });
                                  }
                                },
                                items: <String>['Semua Kategori', 'Pendapatan', 'Pengeluaran']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildExportBtn('PDF', Icons.picture_as_pdf_rounded, AppColors.danger, () {
                            keuanganData.exportToPDF(context);
                          }),
                          _buildExportBtn('Excel', Icons.table_view_rounded, AppColors.success, () {
                            keuanganData.exportToExcel(context);
                          }),
                          _buildExportBtn('Print', Icons.print_rounded, Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Membuka dialog Print...')),
                            );
                          }),
                          if (Provider.of<UserProvider>(context, listen: false).currentUser.role == 'Admin')
                            ElevatedButton.icon(
                              onPressed: () => _showTransactionDialog(context),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Transaksi'),
                            )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Horizontal Scrollable Table Wrapper
                Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: screenWidth - 48,
                      ),
                      child: DataTable(
                        columnSpacing: 40,
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                        dataRowHeight: 60,
                        headingRowHeight: 50,
                        dividerThickness: 1,
                        showCheckboxColumn: false,
                        columns: [
                          const DataColumn(label: Text('Tanggal', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Kategori', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Deskripsi', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Nominal', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Status', style: AppTextStyles.tableHeader)),
                          if (currentUserRole == 'Admin')
                            const DataColumn(label: Text('Aksi', style: AppTextStyles.tableHeader))
                          else
                            const DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: filteredTransactions.isEmpty
                            ? []
                            : filteredTransactions.map((data) {
                                final String key = data['key']?.toString() ?? '';
                                final String tanggal = data['tanggal']?.toString() ?? '';
                                final String kategori = data['kategori']?.toString() ?? '';
                                final String deskripsi = data['deskripsi']?.toString() ?? '';
                                final String nominal = data['nominal']?.toString() ?? '';
                                final String status = data['status']?.toString() ?? 'Selesai';
                                final Color statusColor = status == 'Selesai' ? AppColors.success : AppColors.warning;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(tanggal, style: AppTextStyles.bodySmall)),
                                    DataCell(
                                      Text(
                                        kategori,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: kategori == 'Pendapatan' ? AppColors.success : AppColors.danger,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        deskripsi,
                                        style: AppTextStyles.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        nominal,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: nominal.startsWith('+') ? AppColors.success : AppColors.danger,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    if (currentUserRole == 'Admin')
                                      DataCell(
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                                              onPressed: () => _showTransactionDialog(context, data),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                              onPressed: () => _showDeleteDialog(context, key),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const DataCell(SizedBox.shrink()),
                                  ],
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ),
                if (filteredTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text('Tidak ada riwayat transaksi yang cocok.', style: AppTextStyles.caption),
                  ),

                const SizedBox(height: 20),

                // Pagination Row
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Menampilkan 1-${filteredTransactions.length} dari ${filteredTransactions.length} data', style: AppTextStyles.caption),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: null,
                          child: const Text('Prev'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(36, 36),
                          ),
                          child: const Text('1'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: null,
                          child: const Text('Next'),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER KEUANGAN ---
  Widget _buildFinanceCard(String title, String value, String subtitle, bool isPositive, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileCard = screenWidth < 600;

    return Card(
      child: Padding(
        padding: isMobileCard ? const EdgeInsets.all(12.0) : AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTextStyles.caption),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPositive ? AppColors.success : AppColors.danger),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTransaksiCard(KeuanganProvider data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileCard = screenWidth < 600;

    return Card(
      child: Padding(
        padding: isMobileCard ? const EdgeInsets.all(12.0) : AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('Total Transaksi', style: AppTextStyles.caption),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(data.totalTransaksi, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                )
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${data.pendapatanCount} Pemasukan',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${data.pengeluaranCount} Pengeluaran',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h4),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildExportBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color.withOpacity(0.5))),
    );
  }


}

class WidthBox extends StatelessWidget {
  final double width;
  final Widget child;
  const WidthBox(this.width, {Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}