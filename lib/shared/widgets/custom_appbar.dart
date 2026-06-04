import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  const CustomAppBar({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : const Color(0xFF1F2937));
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final borderColor = theme.dividerColor;

    // Platform-specific profile definitions
    final String userName = kIsWeb ? 'Erwin Marwah' : 'H. Muklas';
    final String userRole = kIsWeb ? 'Admin' : 'Owner';

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sisi Kiri: Judul Halaman Dinamis + subtitle opsional
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDesktop) ...[
                  IconButton(
                    icon: Icon(Icons.menu_rounded, color: textColor),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (subtitle != null && !isMobile) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: subTextColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Sisi Kanan: Search Bar, Notifikasi, & Avatar
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Search Bar
                if (isMobile)
                  IconButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: DashboardSearchDelegate(),
                      );
                    },
                    icon: Icon(Icons.search_rounded, color: textColor),
                  )
                else
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, color: subTextColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              onTap: () {
                                showSearch(
                                  context: context,
                                  delegate: DashboardSearchDelegate(),
                                );
                              },
                              style: TextStyle(color: textColor, fontSize: 14),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: 'Cari sesuatu...',
                                hintStyle: TextStyle(fontSize: 13, color: subTextColor),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(width: isMobile ? 0 : 20),

                // Notification Icon dengan Badge Merah
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_none_rounded, color: textColor),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                ),
                // Theme Toggle Icon
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return IconButton(
                      onPressed: () => themeProvider.toggleTheme(),
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: textColor,
                      ),
                    );
                  },
                ),

                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  // Garis Pembatas Vertikal Tipis
                  Container(
                    width: 1,
                    height: 24,
                    color: borderColor,
                  ),
                  const SizedBox(width: 16),
                  // Status Pengguna Aktif
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        backgroundImage: kIsWeb ? const AssetImage('assets/images/erwin.jpeg') : const AssetImage('assets/images/muklas.jpeg'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          Text(
                            userRole,
                            style: TextStyle(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardSearchDelegate extends SearchDelegate<String> {
  final List<String> searchItems = [
    'Dashboard',
    'Inventori',
    'Keuangan',
    'Distribusi',
    'Analisis Telur Pecah',
    'Laporan',
    'Manajemen User',
    'Stok Telur Ayam',
    'Rute Pengiriman'
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFilteredList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFilteredList(context);
  }

  Widget _buildFilteredList(BuildContext context) {
    final filteredItems = searchItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada hasil ditemukan',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading: const Icon(Icons.subdirectory_arrow_right_rounded, color: Colors.grey),
          title: Text(
            item,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () {
            close(context, item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Mengarahkan ke modul: $item...',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}