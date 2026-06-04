import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import halaman fitur yang sudah selesai di-slicing
import 'dashboard_content.dart';
import '../../stok/screens/stok_screen.dart';
import '../../keuangan/screens/keuangan_screen.dart';
import '../../distribusi/screens/distribusi_screen.dart';
import '../../analisis/screens/analisis_screen.dart';
import '../../laporan/screens/laporan_screen.dart';
import '../../manajemen_user/screens/manajemen_user_screen.dart';

// Import komponen global dan state management
import '../../../core/routes/navigation_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_sidebar.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../auth/providers/user_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final isDesktop = Responsive.isDesktop(context);

    final userRole = Provider.of<UserProvider>(context).currentUser.role;

    // List title halaman berdasarkan index navigasi sesuai desain Figma
    final List<String> pageTitles = [
      'Dashboard Utama',
      'Manajemen Inventori',
      'Manajemen Keuangan',
      'Manajemen Distribusi',
      'Analisis Telur Pecah',
      'Laporan Bisnis',
      'Manajemen User & Hak Akses',
    ];

    // Mengintegrasikan widget halaman asli ke dalam array berdasarkan index
    final List<Widget> pages = [
      const DashboardContent(),    // Index 0: Dashboard Utama
      const StokScreen(),          // Index 1: Manajemen Inventori
      const KeuanganScreen(),      // Index 2: Manajemen Keuangan
      const DistribusiScreen(),    // Index 3: Manajemen Distribusi
      const AnalisisScreen(),      // Index 4: Analisis Telur Pecah
      const LaporanScreen(),       // Index 5: Laporan Bisnis
      const ManajemenUserScreen(), // Index 6: Manajemen User & Hak Akses
    ];

    // Prevent Owner from accessing index 6 (Manajemen User) by redirecting or showing fallback
    final activeIndex = (userRole == 'Owner' && navProvider.selectedIndex >= 6) ? 0 : navProvider.selectedIndex;

    final mainContent = Column(
      children: [
        // AppBar Atas yang judul dan statusnya berganti sesuai menu aktif
        CustomAppBar(title: pageTitles[activeIndex]),
        
        // Area Konten Utama yang merender widget secara reaktif tanpa reload penuh
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: pages[activeIndex],
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Komponen Sidebar Menu di sisi kiri tetap menetap saat berpindah halaman
            const CustomSidebar(),
            
            // Sisi Kanan: Menampilkan AppBar dan Konten Utama secara Dinamis
            Expanded(
              child: mainContent,
            ),
          ],
        ),
      );
    } else {
      // Mobile and Tablet: Sidebar moves to Drawer
      return Scaffold(
        drawer: const Drawer(
          child: CustomSidebar(),
        ),
        body: SafeArea(
          child: mainContent,
        ),
      );
    }
  }
}