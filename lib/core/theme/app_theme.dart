import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

class AppTheme {
  static TextTheme _textTheme(Brightness brightness, Color color) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return GoogleFonts.dmSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.8,
        color: color,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.2,
        color: color,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        color: color,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
        color: color,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: color,
      ),
    );
  }

  static AppPalette paletteOf(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>();
    return palette ?? AppPalette.dark;
  }

  static ThemeData get darkTheme {
    const palette = AppPalette.dark;
    final textTheme = _textTheme(Brightness.dark, Colors.white);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF436850),
        secondary: Color(0xFFADBC9F),
        surface: Color(0xFF11211D),
      ),
      extensions: const [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.glow,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSoft.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: palette.secondary.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: palette.secondary.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.26),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.glow
                : palette.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: palette.glow, size: 24),
        unselectedIconTheme: IconThemeData(
          color: palette.textMuted,
          size: 22,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.glow,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.textMuted,
        ),
        indicatorColor: palette.primary.withValues(alpha: 0.34),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    const palette = AppPalette.light;
    final textTheme = _textTheme(Brightness.light, palette.primaryDeep);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7A62FF),
        secondary: Color(0xFFC45CFF),
        surface: Color(0xFFF8F4FF),
      ),
      extensions: const [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.primaryDeep,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.primaryDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.52),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: palette.glow.withValues(alpha: 0.55),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: palette.glow.withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.accentSoft, width: 1.4),
        ),
        prefixIconColor: palette.primaryDeep.withValues(alpha: 0.72),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.76),
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.primaryDeep
                : palette.textMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: palette.primaryDeep, size: 24),
        unselectedIconTheme: IconThemeData(
          color: palette.textMuted,
          size: 22,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.primaryDeep,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.textMuted,
        ),
        indicatorColor: palette.primary.withValues(alpha: 0.18),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      useMaterial3: true,
    );
  }
}
