import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/navigation_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/user_provider.dart';
import '../../features/auth/screens/login_screen.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : const Color(0xFF1F2937));
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final borderColor = theme.dividerColor;

    // Retrieve the user profile dynamically from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final String userName = userProvider.currentUser.name;
    final String userRole = userProvider.currentUser.role;

    // Daftar menu sesuai dengan urutan desain figma
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Dashboard', 'icon': Icons.home_rounded},
      {'title': 'Inventori', 'icon': Icons.inventory_2_rounded},
      {'title': 'Keuangan', 'icon': Icons.account_balance_wallet_rounded},
      {'title': 'Distribusi', 'icon': Icons.local_shipping_rounded},
      {'title': 'Analisis Telur Pecah', 'icon': Icons.analytics_rounded},
      {'title': 'Laporan', 'icon': Icons.description_rounded},
      if (userRole == 'Admin')
        {'title': 'Manajemen User', 'icon': Icons.people_alt_rounded},
    ];

    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header Sidebar: Logo & Nama Toko
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.egg_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Telur',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      'H. Muklas',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List Menu Navigasi
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final bool isActive = navProvider.selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => navProvider.setIndex(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              color: isActive ? Colors.white : subTextColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  color: isActive ? Colors.white : textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Footer Sidebar: Info Akun & Button Logout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  backgroundImage: kIsWeb ? const AssetImage('assets/images/erwin.jpeg') : const AssetImage('assets/images/muklas.jpeg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole,
                        style: TextStyle(fontSize: 11, color: subTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Logika Keluar Sistem
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    // Reset navigasi kembali to index 0 (Dashboard Utama)
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(0);

                    // Navigasi ke Halaman Login dan bersihkan stack navigasi
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                  tooltip: 'Keluar Sistem',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}