import 'package:flutter/material.dart';

// ============================================================================
// DESIGN TOKENS - Warna, Tipografi, Spacing, Breakpoint
// Seluruh nilai di sini wajib dipakai di semua file UI.
// JANGAN gunakan Colors.xxx secara langsung di file _screen.dart.
// ============================================================================

class AppColors {
  // Warna Utama (Brand Colors)
  static const Color primary = Color(0xFFF59E0B); // Oranye khas Toko Telur
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFDE68A);

  // Warna Background & Surface
  static const Color background = Color(0xFFF8F9FA); // Abu-abu sangat muda untuk background luar
  static const Color surface = Colors.white; // Putih bersih untuk Card/Container
  static const Color sidebarBg = Colors.white; // Background sidebar

  // Warna Teks
  static const Color textDark = Color(0xFF1F2937); // Hitam keabu-abuan untuk teks utama
  static const Color textLight = Color(0xFF6B7280); // Abu-abu untuk teks sekunder/subtitle

  // Warna Status
  static const Color success = Color(0xFF10B981); // Hijau untuk status "Aman" / "Selesai"
  static const Color danger = Color(0xFFEF4444); // Merah untuk status "Rendah" / "Pecah Tinggi"
  static const Color warning = Color(0xFFF59E0B); // Oranye kekuningan untuk "Pending"
  static const Color info = Color(0xFF3B82F6); // Biru untuk info netral

  // Warna Aksen & UI
  static const Color accent = Color(0xFF8B5CF6); // Ungu untuk badge/aksen
  static const Color border = Color(0xFFE5E7EB); // Abu-abu border tipis
  static const Color divider = Color(0xFFF3F4F6); // Warna divider sangat tipis

  // Warna Kategori Pie Chart
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartGreen = Color(0xFF22C55E);
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartYellow = Color(0xFFFBBF24);
  static const Color chartTeal = Color(0xFF14B8A6);

  // Warna Login Panel Gelap
  static const Color darkPanel = Color(0xFF111827);
}

class AppTextStyles {
  // Heading
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  // Caption & Label
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    fontFamily: 'Inter',
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  // Card Value (angka besar di summary card)
  static const TextStyle cardValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  static const TextStyle cardValueLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  // Table
  static const TextStyle tableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
  );

  static const TextStyle tableCell = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Padding standar konten utama
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);

  // Padding di dalam Card
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
}

class AppBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1280;

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= mobile && MediaQuery.of(context).size.width < tablet;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= tablet;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Mengatur font default untuk seluruh aplikasi
      fontFamily: 'Inter',

      // Skema warna utama
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,

      // ColorScheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),

      // Pengaturan default untuk AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),

      // Pengaturan default untuk Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Pengaturan default untuk ElevatedButton (Tombol Oranye)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
      ),

      // Pengaturan default untuk OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            fontSize: 13,
          ),
        ),
      ),

      // Pengaturan default untuk Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Dropdown Menu Theme
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(AppColors.surface),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF111827),
      dividerColor: const Color(0xFF374151),

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: const Color(0xFF1F2937),
        error: AppColors.danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1F2937),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF374151), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF374151)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            fontSize: 13,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
        space: 1,
      ),

      // Dropdown Menu Theme
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1F2937)),
        ),
      ),
    );
  }
}