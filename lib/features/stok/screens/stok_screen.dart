import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/stok_provider.dart';
import '../../auth/providers/user_provider.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({Key? key}) : super(key: key);

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';

  @override
  Widget build(BuildContext context) {
    final stokData = Provider.of<StokProvider>(context);
    final String currentUserRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Filter stokList dynamically
    final filteredStok = stokData.stokList.where((stok) {
      final jenis = stok['jenis']?.toString().toLowerCase() ?? '';
      final id = stok['id_barang']?.toString().toLowerCase() ?? '';
      final kategori = stok['kategori']?.toString() ?? '';
      
      final matchesSearch = jenis.contains(_searchQuery.toLowerCase()) ||
          id.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua Kategori' || kategori == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Error (jika ada)
          if (stokData.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                border: Border.all(color: AppColors.danger.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stokData.errorMessage!,
                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.danger),
                    onPressed: () => stokData.clearError(),
                  )
                ],
              ),
            ),

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
                    child: _buildSummaryCard('Total Stok', '${stokData.totalTersedia} kg', '+5.2%', true, Icons.inventory_2_outlined, AppColors.success),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard('Stok Menipis', '${stokData.stokMenipis} jenis', 'Perhatian', false, Icons.warning_amber_rounded, AppColors.danger),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard('Barang Masuk Hari Ini', '${stokData.barangMasukHariIni} kg', 'Masuk', true, Icons.arrow_downward_rounded, AppColors.info),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard('Barang Keluar Hari Ini', '${stokData.barangKeluarHariIni} kg', 'Keluar', false, Icons.arrow_upward_rounded, AppColors.primary),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Charts Section
          if (isMobile) ...[
            _buildSectionCard(
              'Pergerakan Stok Mingguan',
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1600,
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: 400,
                          getTitlesWidget: (val, meta) {
                            if (val % 400 == 0) {
                              return Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textLight));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                            if (value.toInt() >= 0 && value.toInt() < hari.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(hari[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
                    barGroups: List.generate(stokData.pergerakanMingguan.length, (idx) {
                      final entry = stokData.pergerakanMingguan[idx];
                      return BarChartGroupData(
                        x: idx,
                        barsSpace: 6,
                        barRods: [
                          BarChartRodData(toY: entry[0], color: AppColors.info, width: 14, borderRadius: BorderRadius.circular(4)),
                          BarChartRodData(toY: entry[1], color: AppColors.primary, width: 14, borderRadius: BorderRadius.circular(4)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              'Kategori Inventori',
              SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          sections: stokData.kategoriData.map((data) {
                            return PieChartSectionData(
                              color: Color(data['color']),
                              value: data['persentase'],
                              title: '${data['persentase'].toInt()}%',
                              radius: 20,
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: stokData.kategoriData.map((data) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: Color(data['color']), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['nama'],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Pergerakan Stok Mingguan (Bar Chart)
                Expanded(
                  flex: 2,
                  child: _buildSectionCard(
                    'Pergerakan Stok Mingguan',
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 1600,
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                interval: 400,
                                getTitlesWidget: (val, meta) {
                                  if (val % 400 == 0) {
                                    return Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textLight));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                  if (value.toInt() >= 0 && value.toInt() < hari.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(hari[value.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
                          barGroups: List.generate(stokData.pergerakanMingguan.length, (idx) {
                            final entry = stokData.pergerakanMingguan[idx];
                            return BarChartGroupData(
                              x: idx,
                              barsSpace: 6,
                              barRods: [
                                BarChartRodData(toY: entry[0], color: AppColors.info, width: 14, borderRadius: BorderRadius.circular(4)),
                                BarChartRodData(toY: entry[1], color: AppColors.primary, width: 14, borderRadius: BorderRadius.circular(4)),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Kategori Inventori (Pie Chart)
                Expanded(
                  flex: 1,
                  child: _buildSectionCard(
                    'Kategori Inventori',
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 35,
                                sections: stokData.kategoriData.map((data) {
                                  return PieChartSectionData(
                                    color: Color(data['color']),
                                    value: data['persentase'],
                                    title: '${data['persentase'].toInt()}%',
                                    radius: 20,
                                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stokData.kategoriData.map((data) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(color: Color(data['color']), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      data['nama'],
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // 3. Row Monitoring & Aktivitas
          if (isMobile) ...[
            _buildSectionCard(
              'Monitoring Stok',
              Column(
                children: stokData.monitoringStok.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildProgressBar(
                      item['nama'] as String,
                      (item['current'] ?? '${(item['persentase'] * 40).toInt()} kg') as String,
                      (item['min'] ?? 'Min: 1.000 kg') as String,
                      (item['persentase'] as num) / 100,
                      Color(item['color'] as int),
                      (item['status'] ?? (item['persentase'] < 30 ? 'Kritis' : (item['persentase'] < 60 ? 'Perhatian' : 'Aman'))) as String,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              'Aktivitas Stok Terbaru',
              Column(
                children: stokData.aktivitasStok.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isLast = idx == stokData.aktivitasStok.length - 1;

                  Color iconBg;
                  IconData icon;
                  if (item['type'] == 'masuk') {
                    iconBg = AppColors.success;
                    icon = Icons.add_circle_outline_rounded;
                  } else if (item['type'] == 'keluar') {
                    iconBg = AppColors.primary;
                    icon = Icons.remove_circle_outline_rounded;
                  } else {
                    iconBg = AppColors.info;
                    icon = Icons.sync_rounded;
                  }

                  return _buildActivityItem(
                    item['title'],
                    item['desc'],
                    item['waktu'],
                    icon,
                    iconBg,
                    isLast,
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monitoring Stok
                Expanded(
                  child: _buildSectionCard(
                    'Monitoring Stok',
                    Column(
                      children: stokData.monitoringStok.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _buildProgressBar(
                            item['nama'] as String,
                            (item['current'] ?? '${(item['persentase'] * 40).toInt()} kg') as String,
                            (item['min'] ?? 'Min: 1.000 kg') as String,
                            (item['persentase'] as num) / 100,
                            Color(item['color'] as int),
                            (item['status'] ?? (item['persentase'] < 30 ? 'Kritis' : (item['persentase'] < 60 ? 'Perhatian' : 'Aman'))) as String,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Aktivitas Stok Terbaru
                Expanded(
                  child: _buildSectionCard(
                    'Aktivitas Stok Terbaru',
                    Column(
                      children: stokData.aktivitasStok.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isLast = idx == stokData.aktivitasStok.length - 1;

                        Color iconBg;
                        IconData icon;
                        if (item['type'] == 'masuk') {
                          iconBg = AppColors.success;
                          icon = Icons.add_circle_outline_rounded;
                        } else if (item['type'] == 'keluar') {
                          iconBg = AppColors.primary;
                          icon = Icons.remove_circle_outline_rounded;
                        } else {
                          iconBg = AppColors.info;
                          icon = Icons.sync_rounded;
                        }

                        return _buildActivityItem(
                          item['title'],
                          item['desc'],
                          item['waktu'],
                          icon,
                          iconBg,
                          isLast,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // 4. Table Data Inventori
          _buildSectionCard(
            'Data Inventori',
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
                                      hintText: 'Cari barang...',
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
                          // Kategori Dropdown Filter
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
                                items: <String>['Semua Kategori', 'Ayam', 'Bebek', 'Puyuh']
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
                          if (Provider.of<UserProvider>(context, listen: false).currentUser.role == 'Admin')
                            ElevatedButton.icon(
                              onPressed: () => _showStokDialog(context, null),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Stok'),
                            ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.success),
                            label: const Text('Export', style: TextStyle(color: AppColors.success)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.success)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
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
                          const DataColumn(label: Text('ID Barang', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Jenis Telur', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Kategori', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Harga', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Berat/kg', style: AppTextStyles.tableHeader)),
                          const DataColumn(label: Text('Status', style: AppTextStyles.tableHeader)),
                          if (currentUserRole == 'Admin')
                            const DataColumn(label: Text('Aksi', style: AppTextStyles.tableHeader))
                          else
                            const DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: filteredStok.isEmpty
                            ? []
                            : filteredStok.map((data) {
                                final statusColor = data['status'] == 'Aman' ? AppColors.success : AppColors.danger;
                                final key = data['key'];
                                final id = data['id_barang'] ?? '-';
                                final jenis = data['jenis'] ?? '-';
                                final kategori = data['kategori'] ?? '-';
                                final harga = data['harga'] ?? '-';
                                final berat = data['berat'] ?? '-';
                                final status = data['status'] ?? 'Aman';

                                return DataRow(
                                  cells: [
                                    DataCell(Text(id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                    DataCell(Text(jenis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                    DataCell(Text(kategori, style: AppTextStyles.bodySmall)),
                                    DataCell(Text(harga, style: AppTextStyles.bodySmall)),
                                    DataCell(Text('$berat', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
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
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              splashRadius: 20,
                                              onPressed: () => _showStokDialog(context, data),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              splashRadius: 20,
                                              onPressed: () => _deleteStok(context, key),
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
                if (filteredStok.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text('Tidak ada data stok yang sesuai.', style: AppTextStyles.caption),
                  ),

                const SizedBox(height: 20),

                // Pagination Row
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Menampilkan 1-${filteredStok.length} dari ${filteredStok.length} data', style: AppTextStyles.caption),
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

  // --- WIDGET HELPER ---
  Widget _buildSummaryCard(String title, String value, String subtitle, bool isPositive, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileCard = screenWidth < 600;

    return Card(
      child: Padding(
        padding: isMobileCard ? const EdgeInsets.all(12.0) : AppSpacing.cardPadding,
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
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTextStyles.cardValue),
            ),
            const SizedBox(height: 8),
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


  Widget _buildProgressBar(String title, String current, String min, double progress, Color color, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(current, style: AppTextStyles.caption),
            Text(min, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }

  Widget _buildActivityItem(String title, String desc, String waktu, IconData icon, Color iconColor, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            if (!isLast) Container(height: 40, width: 2, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(waktu, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // --- CRUD DIALOG & ACTIONS ---

  void _deleteStok(BuildContext context, String? key) {
    if (key == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Hapus Stok'),
        content: const Text('Apakah Anda yakin ingin menghapus data stok ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              final provider = Provider.of<StokProvider>(context, listen: false);
              final success = await provider.deleteStok(key);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Data stok berhasil dihapus' : 'Gagal menghapus data stok'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStokDialog(BuildContext context, Map<String, dynamic>? data) {
    final bool isEdit = data != null;
    final formKey = GlobalKey<FormState>();
    final jenisList = ['Telur Ayam Negeri', 'Telur Ayam Kampung', 'Telur Bebek', 'Telur Puyuh'];
    
    String initialJenis = data?['jenis'] ?? 'Telur Ayam Negeri';
    if (!jenisList.contains(initialJenis)) {
      initialJenis = 'Telur Ayam Negeri';
    }

    final jenisController = TextEditingController(text: initialJenis);
    final hargaController = TextEditingController(text: data?['harga'] ?? '');
    final beratController = TextEditingController(text: data?['berat'] ?? '');
    final statusController = TextEditingController(text: data?['status'] ?? 'Aman');

    showDialog(
      context: context,
      builder: (context) {
        final fieldBg = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background;
        final fieldBorder = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(isEdit ? 'Edit Data Stok' : 'Tambah Data Stok'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: jenisController.text,
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
                    items: jenisList.map((val) => DropdownMenuItem(
                      value: val,
                      child: Text(
                        val,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) jenisController.text = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: hargaController,
                    decoration: InputDecoration(
                      labelText: 'Harga (Contoh: Rp 28.000)',
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Field ini wajib diisi';
                      final cleanedValue = value.replaceAll('Rp', '').replaceAll('.', '').replaceAll(' ', '').trim();
                      final numValue = num.tryParse(cleanedValue);
                      if (numValue == null) return 'Harus berupa angka';
                      if (numValue < 0) return 'Tidak boleh negatif';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: beratController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat (kg)',
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Field ini wajib diisi';
                      final cleanedValue = value.replaceAll('kg', '').replaceAll('.', '').replaceAll(' ', '').trim();
                      final numValue = num.tryParse(cleanedValue);
                      if (numValue == null) return 'Harus berupa angka';
                      if (numValue < 0) return 'Tidak boleh negatif';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: statusController.text.isNotEmpty ? statusController.text : 'Aman',
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
                    items: ['Aman', 'Rendah'].map((val) => DropdownMenuItem(
                      value: val,
                      child: Text(
                        val,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) statusController.text = val;
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
                  String inferredKategori = 'Ayam';
                  if (jenisController.text == 'Telur Bebek') {
                    inferredKategori = 'Bebek';
                  } else if (jenisController.text == 'Telur Puyuh') {
                    inferredKategori = 'Puyuh';
                  }

                  // Parse Harga (Strip everything except numbers)
                  String rawHarga = hargaController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  int hargaParsed = int.tryParse(rawHarga) ?? 0;
                  
                  // Parse Berat (Strip everything except numbers and dots for decimal)
                  String rawBerat = beratController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                  double beratParsed = double.tryParse(rawBerat) ?? 0.0;

                  final payload = {
                    'jenis': jenisController.text,
                    'kategori': inferredKategori,
                    'harga': 'Rp $hargaParsed',
                    'berat': beratParsed.toString(),
                    'status': statusController.text,
                  };

                  final provider = Provider.of<StokProvider>(context, listen: false);
                  
                  // Tutup dialog sebelum proses async
                  Navigator.pop(context);
                  
                  bool success = false;
                  if (isEdit) {
                    success = await provider.updateStok(data!['key'], payload);
                  } else {
                    success = await provider.addStok(payload);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success 
                            ? 'Data stok berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}' 
                            : 'Gagal ${isEdit ? 'memperbarui' : 'menambah'} data stok'
                        ),
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
  }
}