import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../keuangan/providers/keuangan_provider.dart';
import '../../stok/providers/stok_provider.dart';
import '../../distribusi/providers/distribusi_provider.dart';
import '../../analisis/providers/analisis_provider.dart';
import '../../../core/routes/navigation_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../distribusi/data/distribution_data.dart';
import '../../../dummy_data.dart';
import '../../auth/providers/user_provider.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardData = Provider.of<DashboardProvider>(context);
    final keuanganData = Provider.of<KeuanganProvider>(context);
    final stokData = Provider.of<StokProvider>(context);
    final distribusiData = Provider.of<DistribusiProvider>(context);
    final analisisData = Provider.of<AnalisisProvider>(context);

    // Responsive layout helper
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content area
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Summary Cards
                    _buildSummaryRow(context, dashboardData, keuanganData, stokData, distribusiData, analisisData),
                    const SizedBox(height: 24),

                    // 2. Charts Row
                    _buildChartsRow(context, dashboardData),
                    const SizedBox(height: 24),

                    // 3. Lists Row (Pengiriman & Stok)
                    _buildListsRow(context, dashboardData, stokData, distribusiData),
                    const SizedBox(height: 24),

                    // 4. Analisis Telur Pecah Section
                    _buildAnalisisTelurPecahSection(context, dashboardData, analisisData),
                  ],
                ),
              ),

              // Sidebar Notification area (Only shown on Desktop, stacked on others)
              if (isDesktop) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildNotificationSidebar(context, dashboardData),
                ),
              ],
            ],
          ),

          // Stacked Notification area for Mobile/Tablet
          if (!isDesktop) ...[
            const SizedBox(height: 24),
            _buildNotificationSidebar(context, dashboardData),
          ],
          
          // Responsive Store Identity Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 48,
            runSpacing: 24,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Section 1 (About)
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Toko Telur H. Muklas',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mitra terpercaya penyedia telur berkualitas tinggi untuk kebutuhan grosir dan eceran. Berdedikasi melayani pelanggan sejak tahun 1990.',
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              // Section 2 (Contact)
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi & Kontak',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'G8H6+F57, Jl. Sojar, Bulak, Kec. Jatibarang, Kabupaten Indramayu, Jawa Barat 45273',
                            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '+0822-1437-7883',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          const Center(
            child: Text(
              '© 2026 Toko Telur H. Muklas',
              style: TextStyle(
                color: Color(0xFF9E9E9E), // Colors.grey.shade500
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER LAYOUT BUILDERS ---

  Widget _buildSummaryRow(
    BuildContext context,
    DashboardProvider data,
    KeuanganProvider keuangan,
    StokProvider stok,
    DistribusiProvider distribusi,
    AnalisisProvider analisis,
  ) {
    final stokMenipisCount = stok.stokMenipisCount;
    final width = MediaQuery.of(context).size.width;
    
    // Rule 1: We calculate spacing so cards form a neat 2x2 grid on Mobile (taking up width/2 - 24)
    final isDesktop = Responsive.isDesktop(context);
    final cardWidth = isDesktop
        ? (width * 0.75 - 48 - 48) / 4
        : (width - 48 - 16) / 2;

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.start,
      children: [
        SizedBox(
          width: cardWidth,
          child: InkWell(
            onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(2), // Go to Keuangan
            borderRadius: BorderRadius.circular(12),
            child: _buildSummaryCard(
              'Penjualan Bulan Ini',
              keuangan.pendapatanBulanIni,
              data.penjualanGrowth,
              '${keuangan.totalTransaksi} transaksi',
              Icons.show_chart_rounded,
              AppColors.info,
              context,
            ),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: InkWell(
            onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1), // Go to Stok
            borderRadius: BorderRadius.circular(12),
            child: _buildSummaryCard(
              'Stok Tersedia',
              '${stok.totalTersedia} kg',
              stokMenipisCount > 0 ? 'Menipis' : 'Batas Aman',
              stokMenipisCount > 0 ? '$stokMenipisCount kategori rendah' : 'Semua kategori aman',
              Icons.inventory_2_rounded,
              stokMenipisCount > 0 ? AppColors.danger : AppColors.success,
              context,
            ),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: InkWell(
            onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(3), // Go to Distribusi
            borderRadius: BorderRadius.circular(12),
            child: _buildSummaryCard(
              'Pengiriman Aktif',
              distribusi.pengirimanHariIni,
              distribusi.dalamPerjalanan != '0' ? 'Aktif' : 'Selesai',
              '${distribusi.dalamPerjalanan} dalam perjalanan',
              Icons.local_shipping_rounded,
              AppColors.primary,
              context,
            ),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: InkWell(
            onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(4), // Go to Analisis
            borderRadius: BorderRadius.circular(12),
            child: _buildSummaryCard(
              'Telur Pecah',
              analisis.totalTelurPecah,
              analisis.persentaseKerusakan,
              'Minggu ini',
              Icons.broken_image_rounded,
              AppColors.danger,
              context,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow(BuildContext context, DashboardProvider data) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey[400] : AppColors.textLight;

    final distribusiProvider = Provider.of<DistribusiProvider>(context);
    final listPengiriman = distribusiProvider.daftarPengiriman;

    final Map<String, double> weightsByJenis = {
      'Telur Ayam Negeri': 0.0,
      'Telur Ayam Kampung': 0.0,
      'Telur Bebek': 0.0,
      'Telur Puyuh': 0.0,
    };

    double totalSemua = 0.0;

    for (var item in listPengiriman) {
      final String jenis = item['jenis_telur']?.toString() ?? 'Telur Ayam Negeri';
      final String jumlahStr = item['jumlah']?.toString() ?? '0 kg';
      final cleanedJumlah = jumlahStr.replaceAll(RegExp(r'[^0-9.]'), '');
      final double weight = double.tryParse(cleanedJumlah) ?? 0.0;
      
      if (weightsByJenis.containsKey(jenis)) {
        weightsByJenis[jenis] = weightsByJenis[jenis]! + weight;
      } else {
        weightsByJenis[jenis] = weight;
      }
      totalSemua += weight;
    }

    if (totalSemua == 0.0) {
      weightsByJenis['Telur Ayam Negeri'] = 40.0;
      weightsByJenis['Telur Ayam Kampung'] = 30.0;
      weightsByJenis['Telur Bebek'] = 30.0;
      totalSemua = 100.0;
    }

    final List<Map<String, dynamic>> dynamicSections = [];
    final List<String> jenisOrder = [
      'Telur Ayam Negeri',
      'Telur Ayam Kampung',
      'Telur Bebek',
      'Telur Puyuh',
    ];
    final Map<String, int> colorMap = {
      'Telur Ayam Negeri': 0xFFF59E0B,
      'Telur Ayam Kampung': 0xFFD97706,
      'Telur Bebek': 0xFF3B82F6,
      'Telur Puyuh': 0xFF8B5CF6,
    };

    for (var jenis in jenisOrder) {
      final double weight = weightsByJenis[jenis] ?? 0.0;
      if (weight > 0) {
        final double percentage = (weight / totalSemua) * 100;
        dynamicSections.add({
          'kategori': jenis,
          'value': percentage,
          'color': colorMap[jenis] ?? 0xFFF59E0B,
          'weight': weight,
        });
      }
    }

    // Rule 2: Wrap wide widgets (Charts) in horizontal scroll view with defined width
    final Widget revenueChart = _buildSectionCard(
      context,
      'Grafik Pendapatan',
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rincian total nilai penjualan telur', style: AppTextStyles.caption.copyWith(color: subTextColor)),
                  Row(
                    children: ['Minggu', 'Bulan', 'Tahun'].map((tf) {
                      final bool isSelected = data.selectedTimeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: ChoiceChip(
                          label: Text(tf, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : textColor)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,
                          onSelected: (_) => data.setTimeframe(tf),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final double maxVal = data.activeRevenueData.isEmpty ? 10.0 : data.activeRevenueData.reduce(max);
                  final double calculatedMaxY = maxVal == 0 ? 10.0 : maxVal * 1.2;

                  return SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: calculatedMaxY,
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (val, meta) {
                                return Text('${val.toInt()} JT', style: TextStyle(fontSize: 10, color: subTextColor));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = data.activeRevenueLabels;
                                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(labels[value.toInt()], style: TextStyle(fontSize: 10, color: subTextColor)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(data.activeRevenueData.length, (idx) {
                              return FlSpot(idx.toDouble(), data.activeRevenueData[idx]);
                            }),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.05)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      onSeeAll: () {
        Provider.of<NavigationProvider>(context, listen: false).setIndex(2); // Go to Keuangan
      },
    );

    final Widget salesPie = _buildSectionCard(
      context,
      'Distribusi Penjualan',
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 320,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: dynamicSections.map((item) {
                      return PieChartSectionData(
                        color: Color(item['color']),
                        value: item['value'],
                        title: '${item['value'].toStringAsFixed(0)}%',
                        radius: 20,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: dynamicSections.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(item['color']), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${item['kategori']} (${item['weight'].toStringAsFixed(0)} kg)', style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      onSeeAll: () {
        Provider.of<NavigationProvider>(context, listen: false).setIndex(3); // Go to Distribusi
      },
    );

    if (isMobile) {
      return Column(
        children: [
          revenueChart,
          const SizedBox(height: 24),
          salesPie,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: revenueChart),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: salesPie),
      ],
    );
  }

  Widget _buildListsRow(
    BuildContext context,
    DashboardProvider data,
    StokProvider stok,
    DistribusiProvider distribusi,
  ) {
    final isMobile = Responsive.isMobile(context);

    final Widget recentShipmentsCard = _buildSectionCard(
      context,
      'Pengiriman Terbaru',
      Column(
        children: dataPengirimanGlobal.map((data) {
          Color statusColor = data.status == 'Selesai' ? Colors.green : (data.status == 'Perjalanan' ? Colors.orange : Colors.amber);
          IconData statusIcon = data.status == 'Selesai' ? Icons.check_circle : (data.status == 'Perjalanan' ? Icons.local_shipping : Icons.schedule);
          return ListTile(
            leading: Icon(statusIcon, color: statusColor),
            title: Text(data.tujuan, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${data.jumlah} - ${data.kendaraan}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(data.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        }).toList(),
      ),
      onSeeAll: () {
        Provider.of<NavigationProvider>(context, listen: false).setIndex(3); // Go to Distribusi (index 3)
      },
    );

    final Widget eggStockCard = _buildSectionCard(
      context,
      'Stok Telur',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stok.monitoringStok.map((item) {
          final String nama = item['nama'] as String;
          final String current = (item['current'] ?? '${(item['persentase'] * 40).toInt()} kg') as String;
          final String min = (item['min'] ?? 'Min: 1.000 kg') as String;
          final double progress = (item['persentase'] as num) / 100;
          final Color color = Color(item['color'] as int);
          final String status = (item['status'] ?? (item['persentase'] < 30 ? 'Kritis' : (item['persentase'] < 60 ? 'Perhatian' : 'Aman'))) as String;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildProgressBar(
              context,
              nama,
              current,
              min,
              progress,
              color,
              status,
            ),
          );
        }).toList(),
      ),
      onSeeAll: () {
        Provider.of<NavigationProvider>(context, listen: false).setIndex(1); // Go to Stok (index 1)
      },
    );

    if (isMobile) {
      return Column(
        children: [
          recentShipmentsCard,
          const SizedBox(height: 24),
          eggStockCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: recentShipmentsCard),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: eggStockCard),
      ],
    );
  }

  Widget _buildAnalisisTelurPecahSection(
    BuildContext context,
    DashboardProvider data,
    AnalisisProvider analisis,
  ) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    // Rule 2: Wrap wide widgets (Pie charts) in scroll view
    final chartContent = isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 500,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: analisis.penyebabKerusakan.map((item) {
                          return PieChartSectionData(
                            color: Color(item['color']),
                            value: item['value'],
                            title: '${item['value'].toInt()}%',
                            radius: 18,
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: analisis.penyebabKerusakan.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(item['color']), shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item['penyebab'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor))),
                              Text('${item['value'].toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: analisis.penyebabKerusakan.map((item) {
                        return PieChartSectionData(
                          color: Color(item['color']),
                          value: item['value'],
                          title: '${item['value'].toInt()}%',
                          radius: 18,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: analisis.penyebabKerusakan.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(item['color']), shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item['penyebab'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor))),
                          Text('${item['value'].toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );

    final userRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Analisis Telur Pecah (Minggu Ini)', style: AppTextStyles.h4.copyWith(color: textColor)),
                  if (userRole == 'Admin')
                    ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<NavigationProvider>(context, listen: false).setIndex(4); // Navigate to Analisis (index 4)
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Lapor Kerusakan'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            chartContent,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSidebar(BuildContext context, DashboardProvider data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey[400] : AppColors.textLight;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifikasi', style: AppTextStyles.h4.copyWith(color: textColor)),
                InkWell(
                  onTap: () => data.clearNotifications(),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text('Bersihkan', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (data.notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'Tidak ada notifikasi baru',
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ),
              )
            else
              ...data.notifications.map((notif) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Color(notif['color']).withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(notif['icon'], color: Color(notif['color']), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['title'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 2),
                            Text(notif['desc'], style: TextStyle(fontSize: 11, color: subTextColor, height: 1.3)),
                            const SizedBox(height: 4),
                            Text(notif['time'], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // --- HELPER SUITE ELEMENTS ---

  Widget _buildSummaryCard(
    String title,
    String value,
    String badgeText,
    String subtitle,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    final isMobile = Responsive.isMobile(context);
    final double valueFontSize = isMobile ? 18.0 : 24.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey[400] : AppColors.textLight;

    return Card(
      child: Padding(
        padding: isMobile ? const EdgeInsets.all(12.0) : AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: isMobile ? 16 : 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: color,
                      fontSize: isMobile ? 9 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w400,
                color: subTextColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, Widget content, {VoidCallback? onSeeAll}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.h4.copyWith(color: textColor), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text('Lihat Semua', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  )
                else
                  const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, IconData icon, Color iconColor, String title, String desc, String status, Color statusColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey[400] : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.caption.copyWith(color: subTextColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String title, String current, String min, double progress, Color color, String status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey[400] : AppColors.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(current, style: AppTextStyles.caption.copyWith(color: subTextColor)),
            Text(min, style: AppTextStyles.caption.copyWith(color: subTextColor)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }
}