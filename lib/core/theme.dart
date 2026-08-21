import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muza Top-Up — Dark Gaming Theme
/// Palette: deep space background, neon blue glow, gold highlights
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF121826);
  static const Color surfaceElevated = Color(0xFF1A2233);
  static const Color card = Color(0xFF161D2E);

  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonBluePale = Color(0xFF5CE1FF);
  static const Color gold = Color(0xFFFFC94A);
  static const Color goldDeep = Color(0xFFE0A82E);

  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textSecondary = Color(0xFF8E97AC);
  static const Color textMuted = Color(0xFF5C6478);

  static const Color success = Color(0xFF31D48A);
  static const Color warning = Color(0xFFFFB347);
  static const Color danger = Color(0xFFFF5C6C);
  static const Color processing = Color(0xFF4E9CFF);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E17), Color(0xFF152036), Color(0xFF0A0E17)],
  );

  static const LinearGradient neonButtonGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF3E7BFA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFFFC94A), Color(0xFFE0A82E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonBlue,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: Colors.white.withOpacity(0.06),
    );
  }
}
