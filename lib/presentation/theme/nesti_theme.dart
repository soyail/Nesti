import 'package:flutter/material.dart';

abstract final class NestiColors {
  static const ink = Color(0xFF24332C);
  static const moss = Color(0xFF416B55);
  static const mossDark = Color(0xFF2F5040);
  static const leaf = Color(0xFF87A884);
  static const paper = Color(0xFFF7F2E7);
  static const warmWhite = Color(0xFFFFFCF5);
  static const peach = Color(0xFFE9AD84);
  static const honey = Color(0xFFF2CB7B);
  static const mist = Color(0xFFDDE8DE);
  static const muted = Color(0xFF6F7C73);
}

ThemeData buildNestiTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: NestiColors.moss,
    brightness: Brightness.light,
    primary: NestiColors.moss,
    secondary: NestiColors.peach,
    surface: NestiColors.warmWhite,
    onSurface: NestiColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: NestiColors.paper,
    fontFamilyFallback: const [
      'PingFang SC',
      'Microsoft YaHei',
      'Noto Sans CJK SC',
    ],
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'STKaiti',
        fontFamilyFallback: ['KaiTi', 'Noto Serif CJK SC'],
        fontSize: 42,
        height: 1.12,
        fontWeight: FontWeight.w600,
        color: NestiColors.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'STKaiti',
        fontFamilyFallback: ['KaiTi', 'Noto Serif CJK SC'],
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: NestiColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: NestiColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: NestiColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: NestiColors.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: NestiColors.ink),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NestiColors.moss,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 46),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NestiColors.ink,
        minimumSize: const Size(48, 44),
        side: const BorderSide(color: Color(0xFFD5DCCF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NestiColors.moss, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : const Color(0xFFFAFAF5),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? NestiColors.moss
            : const Color(0xFFD9DED7),
      ),
    ),
    dividerColor: const Color(0xFFE0E2D9),
  );
}
