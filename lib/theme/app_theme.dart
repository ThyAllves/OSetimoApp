import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get osetimoTheme {
    const primaryColor = Color(0xFF7C0A02); // vermelho vinho profundo
    const secondaryColor = Color(0xFFE5E5E5); // cinza-claro
    const backgroundColor = Color(0xFFFFFFFF); // branco puro
    const textPrimary = Color(0xFF000000); // grafite
    const highlightColor = Color(0xFFC1A46D); // dourado opaco

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontFamily: 'The Time Roman'
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontFamily: 'The Time Roman'
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          fontFamily: 'The Time Roman'
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'The Time Roman',
          fontSize: 22,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: highlightColor,
      ),
    );
  }
}
