import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/laporan_provider.dart';
import '../../stok/providers/stok_provider.dart';
import '../../keuangan/providers/keuangan_provider.dart';
import '../../distribusi/providers/distribusi_provider.dart';
import '../../analisis/providers/analisis_provider.dart';
import '../../auth/providers/user_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';

  @override
  Widget build(BuildContext context) {
    final laporanData = Provider.of<LaporanProvider>(context);
    final String currentUserRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;

    // Filter riwayatList dynamically
    final filteredReports = laporanData.riwayatList.where((laporan) {
      final nama = (laporan['nama'] ?? '').toString().toLowerCase();
      final kategori = (laporan['kategori'] ?? '').toString().toLowerCase();
      final matchesSearch = nama.contains(_searchQuery.toLowerCase()) ||
          kategori.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua Kategori' ||
          laporan['kategori'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Cards (2x2 grid on mobile, Row on desktop)
          isMobile
              ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildSummaryCard('Total Laporan', laporanData.totalLaporan, laporanData.totalLaporanGrowth, Icons.insert_drive_file_rounded, AppColors.info),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildSummaryCard('Laporan Bulan Ini', laporanData.laporanBulanIni, laporanData.laporanBulanIniGrowth, Icons.calendar_today_rounded, AppColors.warning),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildSummaryCard('Export Berhasil', laporanData.exportBerhasil, laporanData.exportBerhasilGrowth, Icons.download_done_rounded, AppColors.success),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildSummaryCard('Aktivitas Cetak', laporanData.aktivitasCetak, laporanData.aktivitasCetakGrowth, Icons.print_rounded, AppColors.accent),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSummaryCard('Total Laporan', laporanData.totalLaporan, laporanData.totalLaporanGrowth, Icons.insert_drive_file_rounded, AppColors.info)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard('Laporan Bulan Ini', laporanData.laporanBulanIni, laporanData.laporanBulanIniGrowth, Icons.calendar_today_rounded, AppColors.warning)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard('Export Berhasil', laporanData.exportBerhasil, laporanData.exportBerhasilGrowth, Icons.download_done_rounded, AppColors.success)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard('Aktivitas Cetak', laporanData.aktivitasCetak, laporanData.aktivitasCetakGrowth, Icons.print_rounded, AppColors.accent)),
                  ],
                ),
          const SizedBox(height: 24),

          // 2. Kategori Laporan (2x2 grid on mobile)
          const Text('Kategori Laporan', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          isMobile
              ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: laporanData.kategoriLaporan.map((kategori) {
                    return SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildCategoryCard(
                        kategori['title'],
                        kategori['desc'],
                        laporanData.countByKategori(kategori['kategori']),
                        Color(kategori['color']),
                        kategori['kategori'],
                      ),
                    );
                  }).toList(),
                )
              : Row(
                  children: laporanData.kategoriLaporan.map((kategori) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildCategoryCard(
                          kategori['title'],
                          kategori['desc'],
                          laporanData.countByKategori(kategori['kategori']),
                          Color(kategori['color']),
                          kategori['kategori'],
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 24),

          // 3. Table Daftar Laporan
          Card(
            child: Padding(
              padding: isMobile ? const EdgeInsets.all(12) : AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search & Filter Bar (Wrap for mobile)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Daftar Laporan', style: AppTextStyles.h4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          // Search Box
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
                                      hintText: 'Cari laporan...',
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
                          // Category Filter Dropdown
                          Container(
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
                                items: <String>[
                                  'Semua Kategori',
                                  'Inventori',
                                  'Keuangan',
                                  'Distribusi',
                                  'Telur Pecah'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Table (horizontally scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      dataRowHeight: 60,
                      headingRowHeight: 50,
                      dividerThickness: 1,
                      showCheckboxColumn: false,
                      columns: [
                        const DataColumn(label: Text('Nama Laporan', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Kategori', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Tanggal', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Format', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Status', style: AppTextStyles.tableHeader)),
                        if (currentUserRole == 'Admin')
                          const DataColumn(label: Text('Aksi', style: AppTextStyles.tableHeader))
                        else
                          const DataColumn(label: SizedBox.shrink()),
                      ],
                      rows: filteredReports.isEmpty
                          ? []
                          : filteredReports.map((laporan) {
                              final String nama = laporan['nama'] ?? '-';
                              final String kategori = laporan['kategori'] ?? '-';
                              final String tanggal = laporan['tanggal'] ?? '-';
                              final String jam = laporan['jam'] ?? '';
                              final String format = laporan['format'] ?? '-';
                              final String status = laporan['status'] ?? '-';
                              final String key = laporan['key'] ?? '';

                              final Color statusColor = status == 'Selesai' ? AppColors.success : AppColors.warning;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          nama,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (jam.isNotEmpty)
                                          Text(jam, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(kategori).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        kategori,
                                        style: TextStyle(fontSize: 11, color: _getCategoryColor(kategori), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(tanggal, style: AppTextStyles.bodySmall)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          format == 'PDF' ? Icons.picture_as_pdf : Icons.table_view,
                                          color: format == 'PDF' ? AppColors.danger : AppColors.success,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(format, style: AppTextStyles.bodySmall),
                                      ],
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
                                          _buildActionIcon(
                                            Icons.download_outlined,
                                            AppColors.success,
                                            'Download ulang',
                                            () => _reExport(kategori, format),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildActionIcon(
                                            Icons.delete_outline,
                                            AppColors.danger,
                                            'Hapus log',
                                            () => _confirmDelete(key, nama),
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
                  if (filteredReports.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textLight.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada riwayat laporan.',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Klik salah satu kategori di atas untuk generate laporan.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Pagination (Wrap for mobile safety)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Text(
                        'Menampilkan 1-${filteredReports.length} dari ${filteredReports.length} data',
                        style: AppTextStyles.caption,
                      ),
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
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // UI BUILDERS
  // ===========================================================================

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTextStyles.caption),
            ),
            const SizedBox(height: 10),
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
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                )
              ],
            ),
            const SizedBox(height: 8),
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

  Widget _buildCategoryCard(String title, String desc, String count, Color color, String kategori) {
    return InkWell(
      onTap: () => _showExportDialog(title, kategori),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCategoryIcon(kategori), color: color, size: 20),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyles.h4),
              ),
              const SizedBox(height: 4),
              Text(desc, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        count,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showExportDialog(title, kategori),
                    child: Text(
                      'Lihat →',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> laporan) {
    final String nama = laporan['nama'] ?? '-';
    final String kategori = laporan['kategori'] ?? '-';
    final String tanggal = laporan['tanggal'] ?? '-';
    final String jam = laporan['jam'] ?? '';
    final String format = laporan['format'] ?? '-';
    final String status = laporan['status'] ?? '-';
    final String key = laporan['key'] ?? '';

    final Color statusColor = status == 'Selesai' ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          // Nama Laporan
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (jam.isNotEmpty)
                  Text(jam, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Kategori (badge)
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(kategori).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kategori,
                    style: TextStyle(fontSize: 11, color: _getCategoryColor(kategori), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Tanggal
          SizedBox(
            width: 130,
            child: Text(tanggal, style: AppTextStyles.bodySmall),
          ),
          const SizedBox(width: 16),

          // Format (icon + text)
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(
                  format == 'PDF' ? Icons.picture_as_pdf : Icons.table_view,
                  color: format == 'PDF' ? AppColors.danger : AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(format, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Status (badge)
          SizedBox(
            width: 90,
            child: Row(
              children: [
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
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Aksi Buttons
          SizedBox(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Download (re-trigger export)
                _buildActionIcon(
                  Icons.download_outlined,
                  AppColors.success,
                  'Download ulang',
                  () => _reExport(kategori, format),
                ),
                const SizedBox(width: 6),
                // Delete from Firebase
                _buildActionIcon(
                  Icons.delete_outline,
                  AppColors.danger,
                  'Hapus log',
                  () => _confirmDelete(key, nama),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ===========================================================================
  // EXPORT DIALOG (Bottom Sheet)
  // ===========================================================================

  void _showExportDialog(String title, String kategori) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text('Export $title', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'Pilih format file yang ingin diexport:',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 24),

              // Export PDF Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeExport(title, kategori, 'PDF');
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Export Excel Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeExport(title, kategori, 'Excel');
                  },
                  icon: const Icon(Icons.table_view, size: 20),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // EXPORT EXECUTION (Wiring to respective providers)
  // ===========================================================================

  Future<void> _executeExport(String title, String kategori, String format) async {
    // Step 1: Trigger the actual export from the correct provider
    switch (kategori) {
      case 'Inventori':
        if (format == 'PDF') {
          await context.read<StokProvider>().exportToPDF(context);
        } else {
          await context.read<StokProvider>().exportToExcel(context);
        }
        break;
      case 'Keuangan':
        if (format == 'PDF') {
          await context.read<KeuanganProvider>().exportToPDF(context);
        } else {
          await context.read<KeuanganProvider>().exportToExcel(context);
        }
        break;
      case 'Distribusi':
        if (format == 'PDF') {
          await context.read<DistribusiProvider>().exportToPDF(context);
        } else {
          await context.read<DistribusiProvider>().exportToExcel(context);
        }
        break;
      case 'Telur Pecah':
        if (format == 'PDF') {
          await context.read<AnalisisProvider>().exportToPDF(context);
        } else {
          await context.read<AnalisisProvider>().exportToExcel(context);
        }
        break;
    }

    // Step 2: Log the export activity to Firebase
    if (!mounted) return;
    final namaLaporan = '$title - ${format.toUpperCase()}';
    await context.read<LaporanProvider>().logExportActivity(namaLaporan, kategori, format);
  }

  // Re-export from table action button
  Future<void> _reExport(String kategori, String format) async {
    debugPrint('DEBUG DOWNLOAD: _reExport button clicked for Kategori: $kategori, Format: $format');
    if (kategori.isEmpty || format.isEmpty) {
      debugPrint('DEBUG DOWNLOAD ERROR: Kategori or Format parameter is null/empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parameter laporan tidak valid'), backgroundColor: AppColors.danger),
      );
      return;
    }
    
    final titleMap = {
      'Inventori': 'Laporan Inventori',
      'Keuangan': 'Laporan Keuangan',
      'Distribusi': 'Laporan Distribusi',
      'Telur Pecah': 'Laporan Telur Pecah',
    };
    final title = titleMap[kategori] ?? 'Laporan';
    await _executeExport(title, kategori, format);
  }

  // Delete log confirmation
  void _confirmDelete(String key, String nama) {
    if (key.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Log Laporan', style: AppTextStyles.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus log "$nama"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<LaporanProvider>().deleteLog(key);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Log berhasil dihapus' : 'Gagal menghapus log'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Inventori':
        return Icons.inventory_2_outlined;
      case 'Keuangan':
        return Icons.account_balance_wallet_outlined;
      case 'Distribusi':
        return Icons.local_shipping_outlined;
      case 'Telur Pecah':
        return Icons.egg_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori) {
      case 'Inventori':
        return AppColors.info;
      case 'Keuangan':
        return AppColors.warning;
      case 'Distribusi':
        return AppColors.success;
      case 'Telur Pecah':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}