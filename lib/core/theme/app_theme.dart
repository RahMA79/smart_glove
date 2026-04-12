import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2F6BFF);
  static const Color _lightBg = Color(0xFFF5F7FB);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFFFFFF);

  static const Color _darkBg = Color(0xFF101018);
  static const Color _darkSurface = Color(0xFF1C1C26);
  static const Color _darkCard = Color(0xFF1C1C26);

  // ── Light theme ────────────────────────────────────────────
  static ThemeData light() {
    const cs = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF00BFA5),
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: Color(0xFF1A1A2E),
      background: _lightBg,
      onBackground: Color(0xFF1A1A2E),
      error: Color(0xFFE53935),
      onError: Colors.white,
      outline: Color(0xFFDDE1EA),
      surfaceVariant: Color(0xFFEDF0F7),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      colorScheme: cs,
      primaryColor: primary,
      scaffoldBackgroundColor: _lightBg,
      cardColor: _lightCard,
      dividerColor: const Color(0xFFE4E8F0),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightCard,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF9AA3B2),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w900,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w800,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        labelLarge: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: Color(0xFF6B7280)),
        labelSmall: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFF1A1A2E),
        iconColor: Color(0xFF6B7280),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1A1A2E),
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? primary : Colors.white,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary.withOpacity(0.4)
              : const Color(0xFFDDE1EA),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF00BFA5),
      onSecondary: Colors.white,
      surface: _darkSurface,
      onSurface: Color(0xFFE8EAF0),
      background: _darkBg,
      onBackground: Color(0xFFE8EAF0),
      error: Color(0xFFEF5350),
      onError: Colors.white,
      outline: Color(0xFF2E2E3E),
      surfaceVariant: Color(0xFF252535),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      colorScheme: cs,
      primaryColor: primary,
      scaffoldBackgroundColor: _darkBg,
      cardColor: _darkCard,
      dividerColor: const Color(0xFF2A2A3A),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFE8EAF0)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFE8EAF0),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkCard,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF6B7280),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        labelStyle: const TextStyle(color: Color(0xFF9AA3B2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w900,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w800,
        ),
        displaySmall: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: Color(0xFFE8EAF0), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFFE8EAF0), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFF9AA3B2), fontSize: 12),
        labelLarge: TextStyle(
          color: Color(0xFFE8EAF0),
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: Color(0xFF9AA3B2)),
        labelSmall: TextStyle(color: Color(0xFF9AA3B2), fontSize: 11),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFFE8EAF0),
        iconColor: Color(0xFF9AA3B2),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF252535),
        contentTextStyle: TextStyle(color: Color(0xFFE8EAF0)),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF9AA3B2)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary
              : const Color(0xFF6B7280),
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary.withOpacity(0.4)
              : const Color(0xFF2A2A3A),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
      ),
    );
  }
}
