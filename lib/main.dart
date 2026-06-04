import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import package Firebase Core dan opsi konfigurasi default
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import konfigurasi tema global
import 'core/theme/app_theme.dart';

// Import semua provider (state management) yang telah dibuat
import 'core/routes/navigation_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/stok/providers/stok_provider.dart';
import 'features/keuangan/providers/keuangan_provider.dart';
import 'features/analisis/providers/analisis_provider.dart';
import 'features/distribusi/providers/distribusi_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/laporan/providers/laporan_provider.dart';
import 'features/manajemen_user/providers/manajemen_user_provider.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/providers/user_provider.dart';

// Import halaman utama dan login
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  // Memastikan inisialisasi binding Flutter selesai dengan benar
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase sebelum aplikasi (runApp) dijalankan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        // Mendaftarkan kontroler status autentikasi login (Dummy Auth)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Mendaftarkan kontroler rute navigasi halaman samping (sidebar)
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        
        // Mendaftarkan kontroler stok telur
        ChangeNotifierProvider(create: (_) => StokProvider()),
        
        // Mendaftarkan kontroler manajemen keuangan
        ChangeNotifierProvider(create: (_) => KeuanganProvider()),
        
        // Mendaftarkan kontroler analisis kerusakan/telur pecah
        ChangeNotifierProvider(create: (_) => AnalisisProvider()),
        
        // Mendaftarkan kontroler manajemen distribusi pengiriman
        ChangeNotifierProvider(create: (_) => DistribusiProvider()), // Mendaftarkan DistribusiProvider

        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => ManajemenUserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Manajemen H. Muklas',
          debugShowCheckedModeBanner: false,
          
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? const DashboardScreen() : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}