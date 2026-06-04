import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/analisis_provider.dart';
import '../../auth/providers/user_provider.dart';

class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({Key? key}) : super(key: key);

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua Status';
  String _selectedTimeframe = '6 Bulan';

  // --- METHODS UNTUK CRUD ---
  void _showLaporanDialog(BuildContext context, [Map<String, dynamic>? item]) {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();

    final tanggalController = TextEditingController(
        text: isEdit ? item['tanggal'] : DateTime.now().toIso8601String().substring(0, 10));
    final dikirimController = TextEditingController(text: isEdit ? item['dikirim'].toString() : '');
    final pecahController = TextEditingController(text: isEdit ? item['pecah'].toString() : '');
    final ruteController = TextEditingController(
        text: isEdit ? item['tujuan'] : 'Surabaya - Malang');

    String selectedKendaraan = isEdit ? (item['kendaraan'] ?? 'Truk Engkel') : 'Truk Engkel';
    String selectedPenyebab = isEdit ? item['penyebab'] : 'Jalan rusak';

    final ruteList = ['Surabaya - Malang', 'Sidoarjo - Gresik', 'Surabaya - Mojokerto', 'Gresik - Tuban'];
    final kendaraanList = ['Truk Engkel', 'L300 PickUp', 'Carry PickUp', 'Lainnya'];
    final penyebabList = ['Jalan rusak', 'Packing buruk', 'Handling kasar', 'Guncangan truk', 'Lainnya'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(isEdit ? 'Ubah Laporan' : 'Tambah Laporan', style: AppTextStyles.h3),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: tanggalController,
                        decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                        validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Autocomplete<String>(
                        initialValue: ruteController.value,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return ruteList;
                          }
                          return ruteList.where((option) =>
                            option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          );
                        },
                        onSelected: (String selection) {
                          ruteController.text = selection;
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          // Sync the autocomplete's internal controller with our ruteController
                          textEditingController.addListener(() {
                            ruteController.text = textEditingController.text;
                          });
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Rute / Tujuan',
                              hintText: 'Ketik atau pilih rute...',
                              suffixIcon: Icon(Icons.route_rounded, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                            onFieldSubmitted: (String value) {
                              onFieldSubmitted();
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1F2937)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      leading: const Icon(Icons.alt_route_rounded, size: 18),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedKendaraan,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: const InputDecoration(labelText: 'Kendaraan'),
                        items: kendaraanList.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedKendaraan = val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dikirimController,
                        decoration: const InputDecoration(labelText: 'Jumlah Dikirim (kg)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                          final cleanedValue = value.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();
                          final numValue = num.tryParse(cleanedValue);
                          if (numValue == null) return 'Harus berupa angka';
                          if (numValue < 0) return 'Tidak boleh negatif';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pecahController,
                        decoration: const InputDecoration(labelText: 'Jumlah Pecah (kg)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                          final cleanedValue = value.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();
                          final numValue = num.tryParse(cleanedValue);
                          if (numValue == null) return 'Harus berupa angka';
                          if (numValue < 0) return 'Tidak boleh negatif';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedPenyebab,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: const InputDecoration(labelText: 'Penyebab'),
                        items: penyebabList.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedPenyebab = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final cleanedDikirim = dikirimController.text.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();
                      final cleanedPecah = pecahController.text.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();

                      final dikirim = int.tryParse(cleanedDikirim) ?? 0;
                      final pecah = int.tryParse(cleanedPecah) ?? 0;

                      // Smart Calculations
                      final kerugian = pecah * 24000;
                      final pct = dikirim == 0 ? 0.0 : (pecah / dikirim) * 100;
                      String status = 'Rendah';
                      if (pct > 4.0) {
                        status = 'Tinggi';
                      } else if (pct >= 2.0) {
                        status = 'Sedang';
                      }

                      final payload = {
                        'tanggal': tanggalController.text,
                        'tujuan': ruteController.text.trim(),
                        'kendaraan': selectedKendaraan,
                        'dikirim': dikirim,
                        'pecah': pecah,
                        'penyebab': selectedPenyebab,
                        'kerugian': kerugian,
                        'status': status,
                      };

                      final provider = Provider.of<AnalisisProvider>(context, listen: false);
                      bool success;
                      if (isEdit) {
                        success = await provider.updateLaporan(item['key'], payload);
                      } else {
                        success = await provider.addLaporan(payload);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Laporan disimpan' : 'Gagal menyimpan'),
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

  void _showDeleteDialog(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Hapus Laporan', style: AppTextStyles.h3),
          content: const Text('Yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final provider = Provider.of<AnalisisProvider>(context, listen: false);
                final success = await provider.deleteLaporan(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Dihapus' : 'Gagal menghapus'),
                      backgroundColor: success ? AppColors.success : AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final analisisData = Provider.of<AnalisisProvider>(context);
    final String currentUserRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;

    // Filter list based on search and status dropdown
    final filteredLaporan = analisisData.laporanKerusakan.where((laporan) {
      final matchesSearch = (laporan['tujuan'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (laporan['penyebab'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter == 'Semua Status' || laporan['status'] == _selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final isMobileLayout = width < 900;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Cards (Top Section)
          isMobileLayout
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: (width - 48 - 16) / 2,
                      child: _buildAnalisisCard('Total Telur Pecah', analisisData.totalTelurPecah, '+12% vs bulan lalu', Icons.broken_image_rounded, AppColors.danger),
                    ),
                    SizedBox(
                      width: (width - 48 - 16) / 2,
                      child: _buildAnalisisCard('Persentase Kerusakan', analisisData.persentaseKerusakan, '- 0.3% dari target', Icons.percent_rounded, AppColors.warning),
                    ),
                    SizedBox(
                      width: (width - 48 - 16) / 2,
                      child: _buildAnalisisCard('Total Kerugian', analisisData.totalKerugian, '+ 8% vs bulan lalu', Icons.money_off_rounded, AppColors.primaryDark),
                    ),
                    SizedBox(
                      width: (width - 48 - 16) / 2,
                      child: _buildAnalisisCard('Rute Risiko Tertinggi', analisisData.ruteRisikoTertinggi, '4.8% tingkat kerusakan', Icons.route_rounded, AppColors.accent),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildAnalisisCard('Total Telur Pecah', analisisData.totalTelurPecah, '+12% vs bulan lalu', Icons.broken_image_rounded, AppColors.danger)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnalisisCard('Persentase Kerusakan', analisisData.persentaseKerusakan, '- 0.3% dari target', Icons.percent_rounded, AppColors.warning)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnalisisCard('Total Kerugian', analisisData.totalKerugian, '+ 8% vs bulan lalu', Icons.money_off_rounded, AppColors.primaryDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnalisisCard('Rute Risiko Tertinggi', analisisData.ruteRisikoTertinggi, '4.8% tingkat kerusakan', Icons.route_rounded, AppColors.accent)),
                  ],
                ),
          const SizedBox(height: 24),

          // 2. Alerts & Recommendations
          isMobileLayout
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.05),
                        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Peringatan Kerusakan Tinggi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            analisisData.peringatanRuteTertinggi,
                            style: const TextStyle(fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  title: Row(
                                    children: const [
                                      Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
                                      SizedBox(width: 8),
                                      Text('Detail Kerusakan', style: AppTextStyles.h3),
                                    ],
                                  ),
                                  content: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('Rute', 'Sidoarjo - Gresik'),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('Tingkat Kerusakan: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            const Text('10.0%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.danger.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text('Kritis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Faktor Dominan:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _buildFactorChip('Jalan berlubang', '45%', Colors.red),
                                            _buildFactorChip('Packing tipis', '35%', Colors.orange),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Icon(Icons.local_shipping_rounded, size: 16, color: Colors.amber),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Catatan Armada: L300 PickUp sering mengalami guncangan tinggi di rute ini.',
                                                  style: TextStyle(fontSize: 12, height: 1.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            mouseCursor: SystemMouseCursors.click,
                            child: const Text('Lihat Detail →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.05),
                        border: Border.all(color: AppColors.info.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb_outline_rounded, color: AppColors.info),
                              SizedBox(width: 8),
                              Text('Rekomendasi Sistem', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tingkatkan kualitas packaging dan kurangi beban maksimal 15% untuk menurunkan risiko kerusakan pada rute panjang.',
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  bool check1 = false;
                                  bool check2 = false;
                                  bool check3 = false;
                                  return StatefulBuilder(
                                    builder: (context, setDialogState) {
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context).colorScheme.surface,
                                        title: Row(
                                          children: const [
                                            Icon(Icons.build_circle_rounded, color: AppColors.info, size: 22),
                                            SizedBox(width: 8),
                                            Expanded(child: Text('Terapkan Tindakan Korektif', style: AppTextStyles.h3)),
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Pilih rekomendasi sistem yang akan diterapkan ke SOP operasional:',
                                              style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 12),
                                            CheckboxListTile(
                                              value: check1,
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              controlAffinity: ListTileControlAffinity.leading,
                                              title: const Text('Kirim peringatan kecepatan ke supir L300.', style: TextStyle(fontSize: 13)),
                                              onChanged: (val) => setDialogState(() => check1 = val ?? false),
                                            ),
                                            CheckboxListTile(
                                              value: check2,
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              controlAffinity: ListTileControlAffinity.leading,
                                              title: const Text('Wajibkan double-tray untuk rute Sidoarjo-Gresik.', style: TextStyle(fontSize: 13)),
                                              onChanged: (val) => setDialogState(() => check2 = val ?? false),
                                            ),
                                            CheckboxListTile(
                                              value: check3,
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              controlAffinity: ListTileControlAffinity.leading,
                                              title: const Text('Kurangi batas maksimal muatan 15%.', style: TextStyle(fontSize: 13)),
                                              onChanged: (val) => setDialogState(() => check3 = val ?? false),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(this.context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Rekomendasi berhasil diterapkan ke SOP.'),
                                                  backgroundColor: AppColors.success,
                                                ),
                                              );
                                            },
                                            child: const Text('Terapkan Sekarang'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            mouseCursor: SystemMouseCursors.click,
                            child: const Text('Terapkan Rekomendasi →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.info)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.05),
                          border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Peringatan Kerusakan Tinggi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              analisisData.peringatanRuteTertinggi,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                    title: Row(
                                      children: const [
                                        Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
                                        SizedBox(width: 8),
                                        Text('Detail Kerusakan', style: AppTextStyles.h3),
                                      ],
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow('Rute', 'Sidoarjo - Gresik'),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Text('Tingkat Kerusakan: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                              const Text('10.0%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.danger.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text('Kritis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('Faktor Dominan:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildFactorChip('Jalan berlubang', '45%', Colors.red),
                                              _buildFactorChip('Packing tipis', '35%', Colors.orange),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: const [
                                                Icon(Icons.local_shipping_rounded, size: 16, color: Colors.amber),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Catatan Armada: L300 PickUp sering mengalami guncangan tinggi di rute ini.',
                                                    style: TextStyle(fontSize: 12, height: 1.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Tutup'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              mouseCursor: SystemMouseCursors.click,
                              child: const Text('Lihat Detail →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.05),
                          border: Border.all(color: AppColors.info.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.lightbulb_outline_rounded, color: AppColors.info),
                                SizedBox(width: 8),
                                Text('Rekomendasi Sistem', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tingkatkan kualitas packaging dan kurangi beban maksimal 15% untuk menurunkan risiko kerusakan pada rute panjang.',
                              style: TextStyle(fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    bool check1 = false;
                                    bool check2 = false;
                                    bool check3 = false;
                                    return StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          backgroundColor: Theme.of(context).colorScheme.surface,
                                          title: Row(
                                            children: const [
                                              Icon(Icons.build_circle_rounded, color: AppColors.info, size: 22),
                                              SizedBox(width: 8),
                                              Expanded(child: Text('Terapkan Tindakan Korektif', style: AppTextStyles.h3)),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Pilih rekomendasi sistem yang akan diterapkan ke SOP operasional:',
                                                style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
                                              ),
                                              const SizedBox(height: 12),
                                              CheckboxListTile(
                                                value: check1,
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                title: const Text('Kirim peringatan kecepatan ke supir L300.', style: TextStyle(fontSize: 13)),
                                                onChanged: (val) => setDialogState(() => check1 = val ?? false),
                                              ),
                                              CheckboxListTile(
                                                value: check2,
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                title: const Text('Wajibkan double-tray untuk rute Sidoarjo-Gresik.', style: TextStyle(fontSize: 13)),
                                                onChanged: (val) => setDialogState(() => check2 = val ?? false),
                                              ),
                                              CheckboxListTile(
                                                value: check3,
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                title: const Text('Kurangi batas maksimal muatan 15%.', style: TextStyle(fontSize: 13)),
                                                onChanged: (val) => setDialogState(() => check3 = val ?? false),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(this.context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Rekomendasi berhasil diterapkan ke SOP.'),
                                                    backgroundColor: AppColors.success,
                                                  ),
                                                );
                                              },
                                              child: const Text('Terapkan Sekarang'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              mouseCursor: SystemMouseCursors.click,
                              child: const Text('Terapkan Rekomendasi →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.info)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // 3. Row Charts (Fl_Chart Implementation)
          isMobileLayout
              ? Column(
                  children: [
                    _buildSectionCard(
                      'Tren Telur Pecah',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grafik tren tingkat kerusakan per bulan', style: AppTextStyles.caption),
                              DropdownButton<String>(
                                value: _selectedTimeframe,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedTimeframe = val;
                                    });
                                  }
                                },
                                items: <String>['3 Bulan', '6 Bulan', '1 Tahun'].map<DropdownMenuItem<String>>((String value) {
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
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: Builder(
                              builder: (context) {
                                final trendInfo = analisisData.getTrendDataAndLabels(_selectedTimeframe);
                                final List<double> trendData = List<double>.from(trendInfo['data']);
                                final List<String> trendLabels = List<String>.from(trendInfo['labels']);
                                final double maxVal = trendData.isEmpty ? 10.0 : trendData.reduce(max);
                                final double calculatedMaxY = maxVal == 0 ? 10.0 : maxVal * 1.2;

                                return BarChart(
                                  BarChartData(
                                    minY: 0,
                                    maxY: calculatedMaxY,
                                    alignment: BarChartAlignment.spaceAround,
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= 0 && value.toInt() < trendLabels.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(trendLabels[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                        dashArray: [4, 4],
                                      ),
                                    ),
                                    barGroups: List.generate(trendData.length, (idx) {
                                      final val = trendData[idx];
                                      return BarChartGroupData(
                                        x: idx,
                                        barRods: [
                                          BarChartRodData(
                                            toY: val, 
                                            gradient: LinearGradient(
                                              colors: [Colors.orange.shade400, Colors.red.shade600],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            width: 22, 
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                                  ),
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Penyebab Kerusakan',
                      SizedBox(
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 50,
                                sections: analisisData.penyebabKerusakan.map((data) {
                                  Color sectionColor;
                                  final penyebabLower = (data['penyebab'] ?? '').toString().toLowerCase();
                                  if (penyebabLower.contains('handling') || penyebabLower.contains('kasar')) {
                                    sectionColor = Colors.red.shade400;
                                  } else if (penyebabLower.contains('packing') || penyebabLower.contains('buruk')) {
                                    sectionColor = Colors.orange.shade400;
                                  } else {
                                    sectionColor = Colors.amber.shade400;
                                  }

                                  return PieChartSectionData(
                                    color: sectionColor,
                                    value: data['value'],
                                    title: '${data['penyebab'].toString().replaceAll(' ', '\n')}\n${data['value'].toInt()}%',
                                    radius: 35,
                                    titlePositionPercentageOffset: 0.6,
                                    titleStyle: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(color: Colors.black45, blurRadius: 4),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'TOTAL PECAH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  analisisData.totalTelurPecah,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${analisisData.penyebabKerusakan.isNotEmpty ? analisisData.penyebabKerusakan.first['penyebab'] : 'Aman'}'.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Tren Telur Pecah (Bar Chart)
                    Expanded(
                      flex: 2,
                      child: _buildSectionCard(
                        'Tren Telur Pecah',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grafik tren tingkat kerusakan per bulan', style: AppTextStyles.caption),
                                DropdownButton<String>(
                                  value: _selectedTimeframe,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedTimeframe = val;
                                      });
                                    }
                                  },
                                  items: <String>['3 Bulan', '6 Bulan', '1 Tahun'].map<DropdownMenuItem<String>>((String value) {
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
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: Builder(
                                builder: (context) {
                                  final trendInfo = analisisData.getTrendDataAndLabels(_selectedTimeframe);
                                  final List<double> trendData = List<double>.from(trendInfo['data']);
                                  final List<String> trendLabels = List<String>.from(trendInfo['labels']);
                                  final double maxVal = trendData.isEmpty ? 10.0 : trendData.reduce(max);
                                  final double calculatedMaxY = maxVal == 0 ? 10.0 : maxVal * 1.2;

                                  return BarChart(
                                    BarChartData(
                                      minY: 0,
                                      maxY: calculatedMaxY,
                                      alignment: BarChartAlignment.spaceAround,
                                      titlesData: FlTitlesData(
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (value.toInt() >= 0 && value.toInt() < trendLabels.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(trendLabels[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                          dashArray: [4, 4],
                                        ),
                                      ),
                                      barGroups: List.generate(trendData.length, (idx) {
                                        final val = trendData[idx];
                                        return BarChartGroupData(
                                          x: idx,
                                          barRods: [
                                            BarChartRodData(
                                              toY: val, 
                                              gradient: LinearGradient(
                                                colors: [Colors.orange.shade400, Colors.red.shade600],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                              width: 22, 
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(6),
                                                topRight: Radius.circular(6),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  );
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Penyebab Kerusakan (Donut Chart)
                    Expanded(
                      flex: 1,
                      child: _buildSectionCard(
                        'Penyebab Kerusakan',
                        SizedBox(
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: analisisData.penyebabKerusakan.map((data) {
                                    Color sectionColor;
                                    final penyebabLower = (data['penyebab'] ?? '').toString().toLowerCase();
                                    if (penyebabLower.contains('handling') || penyebabLower.contains('kasar')) {
                                      sectionColor = Colors.red.shade400;
                                    } else if (penyebabLower.contains('packing') || penyebabLower.contains('buruk')) {
                                      sectionColor = Colors.orange.shade400;
                                    } else {
                                      sectionColor = Colors.amber.shade400;
                                    }
                                    return PieChartSectionData(
                                      color: sectionColor,
                                      value: data['value'],
                                      title: '${data['penyebab'].toString().replaceAll(' ', '\n')}\n${data['value'].toInt()}%',
                                      radius: 35,
                                      titlePositionPercentageOffset: 0.6,
                                      titleStyle: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black45, blurRadius: 4),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('TOTAL PECAH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.8)),
                                  const SizedBox(height: 2),
                                  Text(
                                    analisisData.totalTelurPecah,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'FAKTOR UTAMA:\n${analisisData.penyebabKerusakan.isNotEmpty ? analisisData.penyebabKerusakan.first['penyebab'] : 'Aman'}',
                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.danger),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // 4. Row: Kerusakan Per Rute & Perbandingan Kendaraan
          isMobileLayout
              ? Column(
                  children: [
                    _buildSectionCard(
                      'Tingkat Kerusakan Per Rute',
                      Column(
                        children: analisisData.kerusakanPerRute.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(item['rute'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double pct = (item['kerusakan'] / 5.0).clamp(0.0, 1.0);
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: constraints.maxWidth * pct,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.orange.shade400, Colors.red.shade600],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 45,
                                  child: Text('${item['kerusakan']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(item['color'])), textAlign: TextAlign.right),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Rata-rata Kerusakan Per Kendaraan',
                      Column(
                        children: analisisData.perbandinganKendaraan.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(item['tipe'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final double pct = (item['kerusakan'] / 4.0).clamp(0.0, 1.0);
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: constraints.maxWidth * pct,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.orange.shade400, Colors.red.shade600],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 45,
                                  child: Text('${item['kerusakan']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(item['color'])), textAlign: TextAlign.right),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Kerusakan Per Rute (Horizontal Indicators)
                    Expanded(
                      child: _buildSectionCard(
                        'Tingkat Kerusakan Per Rute',
                        Column(
                          children: analisisData.kerusakanPerRute.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(item['rute'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double pct = (item['kerusakan'] / 5.0).clamp(0.0, 1.0);
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: constraints.maxWidth * pct,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Colors.orange.shade400, Colors.red.shade600],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 45,
                                    child: Text('${item['kerusakan']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(item['color'])), textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Perbandingan Kendaraan (Bar Chart / List)
                    Expanded(
                      child: _buildSectionCard(
                        'Rata-rata Kerusakan Per Kendaraan',
                        Column(
                          children: analisisData.perbandinganKendaraan.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(item['tipe'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double pct = (item['kerusakan'] / 4.0).clamp(0.0, 1.0);
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: constraints.maxWidth * pct,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Colors.orange.shade400, Colors.red.shade600],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 45,
                                    child: Text('${item['kerusakan']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(item['color'])), textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // 5. Detail Laporan Kerusakan (Table Dinamis - horizontal scroll safe on mobile)
          _buildSectionCard(
            'Laporan Detail Kerusakan',
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          // Search Box
                          Container(
                            width: 200,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
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
                                      hintText: 'Cari tujuan, penyebab...',
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
                          const SizedBox(width: 12),
                          // Dropdown status filter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatusFilter,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedStatusFilter = newValue;
                                    });
                                  }
                                },
                                items: <String>['Semua Status', 'Tinggi', 'Sedang', 'Rendah']
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
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => analisisData.exportToPDF(context),
                            icon: const Icon(Icons.picture_as_pdf, size: 16, color: AppColors.danger),
                            label: const Text('PDF', style: TextStyle(color: AppColors.danger)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => analisisData.exportToExcel(context),
                            icon: const Icon(Icons.table_view, size: 16, color: AppColors.success),
                            label: const Text('Excel', style: TextStyle(color: AppColors.success)),
                          ),
                          const SizedBox(width: 12),
                          if (currentUserRole == 'Admin')
                            ElevatedButton.icon(
                              onPressed: () => _showLaporanDialog(context),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Laporan'),
                            )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Horizontal Scrollable Data Table
                if (filteredLaporan.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text('Tidak ada rincian kerusakan.', style: AppTextStyles.caption),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      dataRowHeight: 60,
                      headingRowHeight: 50,
                      dividerThickness: 1,
                      showCheckboxColumn: false,
                      columns: [
                        const DataColumn(label: Text('ID Laporan', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Tanggal', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Tujuan', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Dikirim', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Pecah', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Penyebab', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Kerugian', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Status', style: AppTextStyles.tableHeader)),
                        if (currentUserRole == 'Admin')
                          const DataColumn(label: Text('Aksi', style: AppTextStyles.tableHeader))
                        else
                          const DataColumn(label: SizedBox.shrink()),
                      ],
                      rows: filteredLaporan.map((data) {
                        final key = data['key']?.toString() ?? '';
                        final id = key.isNotEmpty ? key.substring(1, 6).toUpperCase() : 'NEW';
                        final tanggal = data['tanggal']?.toString() ?? '';
                        final tujuan = data['tujuan']?.toString() ?? '';
                        final dikirim = '${data['dikirim'] ?? 0} kg';
                        final pecah = '${data['pecah'] ?? 0} kg';
                        final penyebab = data['penyebab']?.toString() ?? '';
                        final kerugian = Provider.of<AnalisisProvider>(context, listen: false).formatRupiah((data['kerugian'] ?? 0).toInt());
                        final status = data['status']?.toString() ?? '';
                        final statusColor = status == 'Tinggi' 
                            ? AppColors.danger 
                            : (status == 'Sedang' ? AppColors.warning : AppColors.success);

                        return DataRow(
                          cells: [
                            DataCell(Text('#$id', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                            DataCell(Text(tanggal, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis, maxLines: 1)),
                            DataCell(Text(tujuan, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2)),
                            DataCell(Text(dikirim, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
                            DataCell(Text(pecah, style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            DataCell(Text(penyebab, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis, maxLines: 2)),
                            DataCell(Text(kerugian, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            if (currentUserRole == 'Admin')
                              DataCell(Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                                    onPressed: () => _showLaporanDialog(context, data),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                    onPressed: () => _showDeleteDialog(context, key),
                                  ),
                                ],
                              ))
                            else
                              const DataCell(SizedBox.shrink()),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),

                // Pagination Row (Wrap for mobile safety)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Text('Menampilkan 1-${filteredLaporan.length} dari ${filteredLaporan.length} data', style: AppTextStyles.caption),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: null,
                          child: const Text('Prev'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(36, 36),
                          ),
                          child: const Text('1'),
                        ),
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

  // --- DIALOG HELPER WIDGETS ---
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Flexible(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFactorChip(String label, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            '$label ($percentage)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ANALISIS ---
  Widget _buildAnalisisCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: AppTextStyles.caption),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                )
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTextStyles.cardValue),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(subtitle, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ),
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


}