import 'package:flutter/material.dart';

class BikerColors {
  static const Color blue = Color(0xFF0066FF);
  static const Color blueLt = Color(0xFF1E88E5); // ← Yeh add karo
  static const Color darkBlue = Color(0xFF001F3F);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E); // ← Yeh add karo
  static const Color greyLt = Color(0xFFF8F9FA); // ← Yeh add karo
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: BikerColors.white,
    primaryColor: BikerColors.blue,
    colorScheme: const ColorScheme.light(
      primary: BikerColors.blue,
      secondary: BikerColors.darkBlue,
      error: BikerColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BikerColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: BikerColors.black),
      titleTextStyle: TextStyle(
        color: BikerColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BikerColors.blue,
        foregroundColor: BikerColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BikerColors.blue,
        side: const BorderSide(color: BikerColors.blue, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BikerColors.blue,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BikerColors.greyLt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle:
          TextStyle(color: BikerColors.grey.withOpacity(0.7), fontSize: 14),
      prefixIconColor: BikerColors.blue,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BikerColors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BikerColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BikerColors.error, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: BikerColors.white,
      selectedItemColor: BikerColors.blue,
      unselectedItemColor: BikerColors.black,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    primaryColor: BikerColors.blue,
    colorScheme: const ColorScheme.dark(
      primary: BikerColors.blue,
      secondary: BikerColors.blueLt,
      error: BikerColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D0D0D),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: BikerColors.white),
      titleTextStyle: TextStyle(
        color: BikerColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BikerColors.blue,
        foregroundColor: BikerColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      prefixIconColor: BikerColors.blue,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BikerColors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BikerColors.error, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1.5),
      ),
    ),
  );
}
