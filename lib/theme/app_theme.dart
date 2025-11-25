import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =================== TEMA CLARO ===================

  // --- Paleta de Cores ---
  static const Color _lightPrimaryColor = Color(0xFF00529B); // Azul corporativo
  static const Color _lightSecondaryColor = Color(0xFF00C853); // Verde para sucesso
  static const Color _lightErrorColor = Color(0xFFD32F2F); // Vermelho para erros
  static const Color _lightBackgroundColor = Color(0xFFF7F8FC); // Fundo geral
  static const Color _lightSurfaceColor = Colors.white; // Fundo de componentes
  static const Color _lightOnSurfaceColor = Color(0xFF212121); // Texto principal
  static const Color _lightBorderColor = Color(0xFFE0E0E0); // Bordas sutis

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _lightPrimaryColor,
    primary: _lightPrimaryColor,
    secondary: _lightSecondaryColor,
    background: _lightBackgroundColor,
    surface: _lightSurfaceColor,
    onSurface: _lightOnSurfaceColor,
    error: _lightErrorColor,
    brightness: Brightness.light,
  );

  static final TextTheme _lightTextTheme = GoogleFonts.poppinsTextTheme(
    ThemeData.light().textTheme,
  ).apply(bodyColor: _lightOnSurfaceColor, displayColor: _lightOnSurfaceColor);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBackgroundColor,
    colorScheme: _lightColorScheme,
    fontFamily: _lightTextTheme.bodyMedium?.fontFamily,
    textTheme: _lightTextTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _lightBackgroundColor,
      foregroundColor: _lightOnSurfaceColor,
      titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightPrimaryColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightBorderColor.withOpacity(0.7)),
      ),
    ),
    // CORREÇÃO: Alterado de CardTheme para CardThemeData
    cardTheme: CardThemeData(
      elevation: 2,
      color: _lightSurfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: _lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        side: BorderSide(color: _lightPrimaryColor, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: _lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        textStyle: _lightTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightBackgroundColor,
      selectedColor: _lightPrimaryColor,
      secondarySelectedColor: _lightPrimaryColor,
      labelStyle: _lightTextTheme.bodySmall?.copyWith(
        color: _lightOnSurfaceColor,
      ),
      secondaryLabelStyle: _lightTextTheme.bodySmall?.copyWith(
        color: Colors.white,
      ),
      side: BorderSide(color: _lightBorderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    // CORREÇÃO: Alterado de DialogTheme para DialogThemeData
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurfaceColor,
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // =================== TEMA ESCURO ===================

  // --- Paleta de Cores ---
  static const Color _darkPrimaryColor = Color(0xFF4095D6);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color _darkOnSurfaceColor = Color(0xFFE0E0E0);
  static const Color _darkBorderColor = Color(0xFF2E2E2E);

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _darkPrimaryColor,
    primary: _darkPrimaryColor,
    secondary: _lightSecondaryColor,
    background: _darkBackgroundColor,
    surface: _darkSurfaceColor,
    onSurface: _darkOnSurfaceColor,
    error: _lightErrorColor,
    brightness: Brightness.dark,
  );

  static final TextTheme _darkTextTheme = GoogleFonts.poppinsTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: _darkOnSurfaceColor, displayColor: _darkOnSurfaceColor);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _darkBackgroundColor,
    colorScheme: _darkColorScheme,
    fontFamily: _darkTextTheme.bodyMedium?.fontFamily,
    textTheme: _darkTextTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _darkBackgroundColor,
      foregroundColor: _darkOnSurfaceColor,
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkPrimaryColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkBorderColor.withOpacity(0.7)),
      ),
    ),
    // CORREÇÃO: Alterado de CardTheme para CardThemeData
    cardTheme: CardThemeData(
      elevation: 0,
      color: _darkSurfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _darkBorderColor),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: _darkTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        side: BorderSide(color: _darkPrimaryColor, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: _darkTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        textStyle: _darkTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedColor: _darkPrimaryColor,
      secondarySelectedColor: _darkPrimaryColor,
      labelStyle: _darkTextTheme.bodySmall?.copyWith(
        color: _darkOnSurfaceColor,
      ),
      secondaryLabelStyle: _darkTextTheme.bodySmall?.copyWith(
        color: Colors.white,
      ),
      side: BorderSide(color: _darkBorderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    // CORREÇÃO: Alterado de DialogTheme para DialogThemeData
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
