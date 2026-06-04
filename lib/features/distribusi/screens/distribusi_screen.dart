import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/distribusi_provider.dart';
import '../../manajemen_user/providers/manajemen_user_provider.dart';
import '../data/distribution_data.dart';
import '../../../dummy_data.dart';
import '../../auth/providers/user_provider.dart';

class DistribusiScreen extends StatefulWidget {
  const DistribusiScreen({Key? key}) : super(key: key);

  @override
  State<DistribusiScreen> createState() => _DistribusiScreenState();
}

class _DistribusiScreenState extends State<DistribusiScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Semua Status';

  // =============================================
  // DIALOG: Tambah / Ubah Pengiriman
  // =============================================
  void _showPengirimanDialog(BuildContext context, [Map<String, dynamic>? item]) {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();

    final tujuanController = TextEditingController(text: isEdit ? item['tujuan'] : '');
    final alamatController = TextEditingController(text: isEdit ? item['alamat'] : '');
    final jumlahController = TextEditingController(
      text: isEdit ? (item['jumlah']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '') : '',
    );
    final estimasiController = TextEditingController(text: isEdit ? item['estimasi'] : '');

    final userProvider = Provider.of<ManajemenUserProvider>(context, listen: false);
    final supirOptions = userProvider.userList
        .where((user) => user['role'] == 'Kurir' && user['nama'] != null)
        .map((user) => user['nama']!.toString())
        .toList();
    if (supirOptions.isEmpty) {
      supirOptions.add('Belum ada kurir');
    }

    String selectedKendaraan = (isEdit && item['kendaraan'] != null)
        ? item['kendaraan']
        : 'L300 (N 8271 AB)';
    String selectedSupir = (isEdit && item['supir'] != null)
        ? item['supir']
        : supirOptions.first;
    String selectedStatus = (isEdit && item['status'] != null)
        ? item['status']
        : 'Pending';

    final kendaraanOptions = [
      'L300 (N 8271 AB)',
      'Truk Engkel (B 9182 T)',
      'Carry PickUp (L 1290 XY)',
    ];
    final statusOptions = ['Pending', 'Dalam Perjalanan', 'Selesai', 'Dibatalkan'];

    final jenisTelurOptions = [
      'Telur Ayam Negeri',
      'Telur Ayam Kampung',
      'Telur Bebek',
      'Telur Puyuh',
    ];
    String selectedJenisTelur = (isEdit && item['jenis_telur'] != null)
        ? item['jenis_telur']
        : 'Telur Ayam Negeri';

    // Ensure selected values are valid options (handle data from Firebase that may not match)
    if (!kendaraanOptions.contains(selectedKendaraan)) {
      selectedKendaraan = kendaraanOptions.first;
    }
    if (!supirOptions.contains(selectedSupir)) {
      selectedSupir = supirOptions.first;
    }
    if (!statusOptions.contains(selectedStatus)) {
      selectedStatus = statusOptions.first;
    }
    if (!jenisTelurOptions.contains(selectedJenisTelur)) {
      selectedJenisTelur = jenisTelurOptions.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        final fieldBg = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background;
        final fieldBorder = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(isEdit ? 'Ubah Pengiriman' : 'Tambah Pengiriman', style: AppTextStyles.h3),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 420,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tujuan
                        TextFormField(
                          controller: tujuanController,
                          decoration: InputDecoration(
                            labelText: 'Tujuan',
                            hintText: 'Contoh: Toko Sinar Jaya',
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
                          validator: (val) => val == null || val.isEmpty ? 'Tujuan wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Alamat
                        TextFormField(
                          controller: alamatController,
                          decoration: InputDecoration(
                            labelText: 'Alamat Lengkap',
                            hintText: 'Contoh: Jl. Kenanga No. 12, Malang',
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
                          validator: (val) => val == null || val.isEmpty ? 'Alamat wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Kendaraan (Dropdown)
                        DropdownButtonFormField<String>(
                          value: selectedKendaraan,
                          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Kendaraan',
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
                          items: kendaraanOptions.map((k) {
                            return DropdownMenuItem(
                              value: k,
                              child: Text(
                                k,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedKendaraan = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Jenis Telur (Dropdown)
                        DropdownButtonFormField<String>(
                          value: selectedJenisTelur,
                          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Jenis Telur',
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
                          items: jenisTelurOptions.map((j) {
                            return DropdownMenuItem(
                              value: j,
                              child: Text(
                                j,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedJenisTelur = val;
                              });
                            }
                          },
                          validator: (val) => val == null || val.isEmpty ? 'Jenis telur wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Jumlah (numeric)
                        TextFormField(
                          controller: jumlahController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah (kg)',
                            hintText: 'Contoh: 850',
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
                            if (value == null || value.trim().isEmpty) return 'Jumlah wajib diisi';
                            final cleanedValue = value.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();
                            final numValue = num.tryParse(cleanedValue);
                            if (numValue == null) return 'Harus berupa angka';
                            if (numValue < 0) return 'Tidak boleh negatif';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Supir (Dropdown)
                        DropdownButtonFormField<String>(
                          value: selectedSupir,
                          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Supir',
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
                          items: supirOptions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedSupir = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Estimasi
                        TextFormField(
                          controller: estimasiController,
                          decoration: InputDecoration(
                            labelText: 'Estimasi',
                            hintText: 'Contoh: 30 menit / Besok',
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
                        ),
                        const SizedBox(height: 12),

                        // Status Pengiriman
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
                            items: statusOptions.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = Provider.of<DistribusiProvider>(context, listen: false);

                      final payload = {
                        'tujuan': tujuanController.text,
                        'alamat': alamatController.text,
                        'kendaraan': selectedKendaraan,
                        'jenis_telur': selectedJenisTelur,
                        'jumlah': '${jumlahController.text} kg',
                        'supir': selectedSupir,
                        'estimasi': estimasiController.text.isNotEmpty ? estimasiController.text : '-',
                        'status': isEdit ? selectedStatus : 'Pending',
                        'tanggal': isEdit ? (item['tanggal'] ?? '') : DateTime.now().toString().split(' ')[0],
                      };

                      bool success;
                      if (isEdit) {
                        payload['id'] = item['id'] ?? '';
                        success = await provider.updatePengiriman(item['key'], payload);
                      } else {
                        success = await provider.addPengiriman(payload);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? (isEdit ? 'Pengiriman berhasil diperbarui' : 'Pengiriman berhasil ditambahkan')
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =============================================
  // DIALOG: Konfirmasi Hapus Pengiriman
  // =============================================
  void _showDeleteDialog(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Hapus Pengiriman', style: AppTextStyles.h3),
          content: const Text('Apakah Anda yakin ingin menghapus pengiriman ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final provider = Provider.of<DistribusiProvider>(context, listen: false);
                final success = await provider.deletePengiriman(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Pengiriman berhasil dihapus' : 'Gagal menghapus pengiriman'),
                      backgroundColor: success ? AppColors.success : AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // =============================================
  // BUILD
  // =============================================
  @override
  Widget build(BuildContext context) {
    final distribusiData = Provider.of<DistribusiProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Filter shipments dynamically using the provider's data list
    final filteredShipments = distribusiData.daftarPengiriman.where((shipment) {
      final matchesSearch = (shipment['tujuan'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (shipment['id'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (shipment['supir'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'Semua Status' ||
          (_selectedStatus == 'Selesai' && shipment['status'] == 'Selesai') ||
          (_selectedStatus == 'Dalam Perjalanan' && (shipment['status'] == 'Dalam Perjalanan' || shipment['status'] == 'Perjalanan')) ||
          (_selectedStatus == 'Pending' && shipment['status'] == 'Pending') ||
          (_selectedStatus == 'Dibatalkan' && shipment['status'] == 'Dibatalkan');
      return matchesSearch && matchesStatus;
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
              final isTabletLayout = width >= 600 && width < 900;
              final cardWidth = isMobileLayout
                  ? (width - 16) / 2
                  : isTabletLayout
                      ? (width - 32) / 3
                      : (width - 80) / 6;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Pengiriman Hari Ini',
                      distribusiData.pengirimanHariIni,
                      'Total pengiriman',
                      Icons.local_shipping,
                      AppColors.info,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Dalam Perjalanan',
                      distribusiData.dalamPerjalanan,
                      'Aktif sekarang',
                      Icons.route,
                      AppColors.info,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Pengiriman Selesai',
                      distribusiData.pengirimanSelesai,
                      'Sukses terkirim',
                      Icons.check_circle_outline,
                      AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Pending',
                      distribusiData.pengirimanPending,
                      'Menunggu proses',
                      Icons.hourglass_empty,
                      AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Dibatalkan',
                      distribusiData.pengirimanDibatalkan,
                      'Batal dikirim',
                      Icons.cancel_outlined,
                      AppColors.danger,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildDistCard(
                      'Total Telur Dikirim',
                      distribusiData.totalDikirim,
                      'kg terakumulasi',
                      Icons.egg_alt_outlined,
                      AppColors.accent,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Main Content (Table & Timeline responsive layout)
          if (isMobile) ...[
            _buildDaftarPengirimanCard(context, distribusiData, filteredShipments, isMobile),
            const SizedBox(height: 24),
            _buildTimelineCard(context, distribusiData),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sisi Kiri: Daftar Pengiriman (Table)
                Expanded(
                  flex: 2,
                  child: _buildDaftarPengirimanCard(context, distribusiData, filteredShipments, isMobile),
                ),
                const SizedBox(width: 24),
                // Sisi Kanan: Timeline
                Expanded(
                  flex: 1,
                  child: _buildTimelineCard(context, distribusiData),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =============================================
  // WIDGET HELPERS
  // =============================================
  Widget _buildDaftarPengirimanCard(BuildContext context, DistribusiProvider distribusiData, List<Map<String, dynamic>> filteredShipments, bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Text('Daftar Pengiriman', style: AppTextStyles.h4),
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
                            const Icon(Icons.search_rounded, color: AppColors.textLight, size: 18),
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
                                  hintText: 'Cari tujuan, supir...',
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
                        width: isMobile ? double.infinity : 150,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                  });
                              }
                            },
                            items: <String>['Semua Status', 'Selesai', 'Dalam Perjalanan', 'Pending', 'Dibatalkan']
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
                  if (Provider.of<UserProvider>(context, listen: false).currentUser.role == 'Admin')
                    ElevatedButton.icon(
                      onPressed: () => _showPengirimanDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 1.2,
                child: DataTable(
                  columnSpacing: 16,
                  showCheckboxColumn: false,
                  dataRowHeight: 70,
                  headingRowHeight: 50,
                  dividerThickness: 1,
                  columns: [
                    const DataColumn(label: Text('ID')),
                    const DataColumn(label: Text('Tujuan / Alamat')),
                    const DataColumn(label: Text('Jenis Telur')),
                    const DataColumn(label: Text('Kendaraan')),
                    const DataColumn(label: Text('Jumlah')),
                    const DataColumn(label: Text('Supir')),
                    const DataColumn(label: Text('Status')),
                    if (Provider.of<UserProvider>(context, listen: false).currentUser.role == 'Admin')
                      const DataColumn(label: Text('Aksi')),
                  ],
                  rows: filteredShipments.map((data) {
                    final String status = data['status']?.toString() ?? 'Pending';
                    Color badgeColor;
                    switch (status) {
                      case 'Dalam Perjalanan':
                      case 'Perjalanan':
                        badgeColor = AppColors.info;
                        break;
                      case 'Selesai':
                        badgeColor = AppColors.success;
                        break;
                      case 'Dibatalkan':
                        badgeColor = AppColors.danger;
                        break;
                      case 'Pending':
                      default:
                        badgeColor = AppColors.warning;
                        break;
                    }
                    return DataRow(cells: [
                      DataCell(Text(data['id']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      DataCell(Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(data['tujuan']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(height: 2),
                            Text(data['alamat']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                          ],
                        ),
                      )),
                      DataCell(Text(data['jenis_telur']?.toString() ?? '-', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1)),
                      DataCell(Text(data['kendaraan']?.toString() ?? '', overflow: TextOverflow.ellipsis, maxLines: 1)),
                      DataCell(Text(data['jumlah']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      DataCell(Text(data['supir']?.toString() ?? '', overflow: TextOverflow.ellipsis, maxLines: 1)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status == 'Perjalanan' ? 'Dalam Perjalanan' : status,
                            style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (Provider.of<UserProvider>(context, listen: false).currentUser.role == 'Admin')
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                              onPressed: () => _showPengirimanDialog(context, data),
                              tooltip: 'Edit',
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                              onPressed: () => _showDeleteDialog(context, data['key']?.toString() ?? ''),
                              tooltip: 'Hapus',
                            ),
                          ],
                        )),
                    ]);
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pagination row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Menampilkan 1-${filteredShipments.length} dari ${filteredShipments.length} data', style: AppTextStyles.caption),
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
    );
  }

  Widget _buildTimelineCard(BuildContext context, DistribusiProvider distribusiData) {
    final recentDeliveries = distribusiData.daftarPengiriman.take(5).toList();

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline Pengiriman', style: AppTextStyles.h4),
            const SizedBox(height: 24),

            if (recentDeliveries.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: const Text('Belum ada aktivitas pengiriman.', style: AppTextStyles.caption),
              )
            else
              ...recentDeliveries.asMap().entries.map((entry) {
                final idx = entry.key;
                final data = entry.value;
                final isLast = idx == recentDeliveries.length - 1;
                return _buildDynamicTimelineItem(data, isLast);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicTimelineItem(Map<String, dynamic> data, bool isLast) {
    final String status = data['status']?.toString() ?? 'Pending';
    final String key = data['key']?.toString() ?? '';
    final String idSuffix = key.length > 5 ? key.substring(key.length - 5).toUpperCase() : 'NEW';

    Color iconColor;
    IconData timelineIcon;

    if (status == 'Selesai') {
      iconColor = AppColors.success;
      timelineIcon = Icons.check_circle;
    } else if (status == 'Dalam Perjalanan' || status == 'Perjalanan') {
      iconColor = AppColors.info;
      timelineIcon = Icons.local_shipping;
    } else if (status == 'Dibatalkan') {
      iconColor = AppColors.danger;
      timelineIcon = Icons.cancel;
    } else {
      // Pending
      iconColor = AppColors.warning;
      timelineIcon = Icons.schedule;
    }

    final title = '$status - ID $idSuffix';
    final desc = '${data['tujuan'] ?? '-'} (${data['jumlah'] ?? '0'} kg ${data['jenis_telur'] ?? 'Telur'})\nSupir: ${data['supir'] ?? '-'}';
    final time = data['estimasi']?.toString() ?? '-';

    return _buildTimelineItem(title, desc, time, timelineIcon, iconColor, isLast);
  }

  Widget _buildDistCard(String title, String value, String subtitle, IconData icon, Color color) {
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
                    child: Text(value, style: AppTextStyles.cardValueLarge),
                  ),
                ),
                const SizedBox(width: 8),
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
              child: Text(subtitle, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Map<String, dynamic> data) {
    final String key = data['key']?.toString() ?? '';
    final String id = data['id']?.toString() ?? '';
    final String tujuan = data['tujuan']?.toString() ?? '';
    final String alamat = data['alamat']?.toString() ?? '';
    final String kendaraan = data['kendaraan']?.toString() ?? '';
    final String jumlah = data['jumlah']?.toString() ?? '';
    final String supir = data['supir']?.toString() ?? '';
    final String estimasi = data['estimasi']?.toString() ?? '-';
    final String status = data['status']?.toString() ?? 'Pending';

    Color statusColor;
    if (status == 'Selesai') {
      statusColor = AppColors.success;
    } else if (status == 'Perjalanan') {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tujuan, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(alamat, style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 150, child: Text(kendaraan, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 16),
          SizedBox(width: 90, child: Text(jumlah, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(width: 16),
          SizedBox(width: 120, child: Text(supir, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 16),
          SizedBox(width: 100, child: Text(estimasi, style: AppTextStyles.bodySmall)),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    status == 'Perjalanan' ? 'Proses' : status,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Aksi kolom (Edit & Delete)
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                  onPressed: () => _showPengirimanDialog(context, data),
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 12),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                  onPressed: () => _showDeleteDialog(context, key),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String desc, String time, IconData icon, Color color, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast) Container(height: 50, width: 2, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.3)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }
}