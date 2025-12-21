import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Melon Brand Colors
  static const Color blue = Color(0xFF002654); // Bleu Foncé (Drapeau)
  static const Color lightBlue = Color(0xFF0055A4);
  static const Color yellow = Color(0xFFFFC400); // Jaune Vif
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);
  static const Color primary = Color(0xFF13B6EC);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.offWhite,
      primaryColor: AppColors.blue,
      colorScheme: ColorScheme.light(
        primary: AppColors.blue,
        secondary: AppColors.yellow,
        surface: AppColors.cardLight,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.blue,
      colorScheme: ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.yellow,
        surface: AppColors.cardDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
