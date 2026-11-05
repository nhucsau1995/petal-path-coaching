import 'package:flutter/material.dart';

/// Design tokens from the Stitch design system (design/DESIGN.md, palette P29).
class AppColors {
  static const background = Color(0xFFF4FBFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEAF5F7);
  static const accent = Color(0xFF00C2E8);
  static const accentFill = Color(0xFF00788F);
  static const accentTint = Color(0xFFDBF6FC);
  static const accentPressed = Color(0xFF006F85);
  static const support = Color(0xFFFF7AB6);
  static const supportStrong = Color(0xFFFF529E);
  static const textPrimary = Color(0xFF0C1C1F);
  static const textSecondary = Color(0xFF4A5D61);
  static const textTertiary = Color(0xFF66767A);
  static const border = Color(0xFFD5E6E9);
  static const borderStrong = Color(0xFF669C9F);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);
  static const info = Color(0xFF00748A);
  static const infoTint = Color(0xFFE0EFF2);
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF00788F), Color(0xFF006F85)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

/// Type scale: display 32/700, title 20/600, body 16/400, label 14/500,
/// caption 13/500. Oswald for display + numerals, Barlow Condensed for UI.
class AppText {
  static const _body = 'BarlowCondensed';
  static const _display = 'Oswald';

  static TextStyle oswald(double size, double weight, {Color color = AppColors.textPrimary, double? spacing}) =>
      TextStyle(
        fontFamily: _display,
        fontSize: size,
        fontWeight: FontWeight.values[((weight ~/ 100) - 1).clamp(0, 8)],
        fontVariations: [FontVariation('wght', weight)],
        color: color,
        letterSpacing: spacing,
        height: 1.2,
      );

  static TextStyle display({Color color = AppColors.textPrimary}) => oswald(32, 700, color: color, spacing: -0.64);
  static TextStyle title({Color color = AppColors.textPrimary}) => oswald(20, 600, color: color);
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      TextStyle(fontFamily: _body, fontSize: 16, fontWeight: FontWeight.w400, color: color, height: 1.45);
  static TextStyle label({Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w500}) =>
      TextStyle(fontFamily: _body, fontSize: 14, fontWeight: weight, color: color, height: 1.35);
  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      TextStyle(fontFamily: _body, fontSize: 13, fontWeight: FontWeight.w500, color: color, height: 1.35);
}

const cardShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentFill,
      primary: AppColors.accentFill,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'BarlowCondensed',
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accentFill : AppColors.border,
      ),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppText.label(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
