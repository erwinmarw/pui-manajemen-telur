import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../providers/user_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // Controller untuk membaca inputan user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _emailController.text = 'erwinmarw@gmail.com';
      _passwordController.text = '123';
    } else {
      _emailController.text = 'muklas@gmail.com';
      _passwordController.text = '123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000), 
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.maxWidth > 800;

                return Row(
                  children: [
                    // Sisi Kiri: Form Login
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 40),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Silakan login untuk mengelola data keuangan, stok, dan distribusi telur.',
                              style: TextStyle(fontSize: 14, color: AppColors.textLight),
                            ),
                            const SizedBox(height: 32),
                            
                            // Field Email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'admin@tokotelurhmuklas.com',
                                    hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textLight, size: 20),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Field Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textLight, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textLight, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildRememberForgot(),
                            const SizedBox(height: 32),
                            
                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 6,
                                  shadowColor: Colors.orange.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  final email = _emailController.text;
                                  final password = _passwordController.text;
                                  
                                  if ((email == 'erwinmarw@gmail.com' && password == '123') ||
                                      (email == 'muklas@gmail.com' && password == '123')) {
                                    // Menjalankan fungsi login dari AuthProvider
                                    Provider.of<AuthProvider>(context, listen: false).login(email, password);
                                    
                                    // Sync user details to UserProvider
                                    Provider.of<UserProvider>(context, listen: false).loginAs(email);

                                    // Navigasi ke DashboardScreen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DashboardScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email atau Password salah!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            Center(
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Need help? ',
                                  style: TextStyle(color: AppColors.textLight, fontFamily: 'Inter'),
                                  children: [
                                    TextSpan(
                                      text: 'Contact Support',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sisi Kanan: Banner Gelap (Hanya tampil di Desktop)
                    if (isDesktop)
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_transportation, color: AppColors.primary, size: 16),
                                    SizedBox(width: 8),
                                    Text('Egg Distribution Management System', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Kelola Distribusi Telur\nLebih Mudah dan\nTerstruktur',
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Membantu pengelolaan stok, distribusi, keuangan, dan analisis telur pecah dalam satu sistem terintegrasi.',
                                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                              ),
                              const SizedBox(height: 40),
                              
                              // Kotak Statistik
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            const Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Monitoring Operasional', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                Text('Real-time tracking', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildStatItem('TELUR PECAH', '2.1 %'),
                                            _buildStatItem('DAILY DELIVERIES', '1.200+ Butir'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---- WIDGET KECIL ----
  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.egg_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Text(
          'Toko Telur ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const Text(
          'H. Muklas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text('Remember me', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}