import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceSoft,
    required this.primary,
    required this.primaryDeep,
    required this.secondary,
    required this.accent,
    required this.accentSoft,
    required this.textMuted,
    required this.glow,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color primaryDeep;
  final Color secondary;
  final Color accent;
  final Color accentSoft;
  final Color textMuted;
  final Color glow;

  static const dark = AppPalette(
    background: Color(0xFF091310),
    backgroundAlt: Color(0xFF10211C),
    surface: Color(0xFF11211D),
    surfaceSoft: Color(0xFF183129),
    primary: Color(0xFF436850),
    primaryDeep: Color(0xFF12372A),
    secondary: Color(0xFFADBC9F),
    accent: Color(0xFFFB8B24),
    accentSoft: Color(0xFFFFB347),
    textMuted: Color(0xFF92A79A),
    glow: Color(0xFFFBFADA),
  );

  static const light = AppPalette(
    background: Color(0xFFF5F3EC),
    backgroundAlt: Color(0xFFE9E5D7),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF1EDDF),
    primary: Color(0xFF436850),
    primaryDeep: Color(0xFF12372A),
    secondary: Color(0xFF6F8A63),
    accent: Color(0xFFFB8B24),
    accentSoft: Color(0xFFFFC971),
    textMuted: Color(0xFF5F6D65),
    glow: Color(0xFFFBFADA),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceSoft,
    Color? primary,
    Color? primaryDeep,
    Color? secondary,
    Color? accent,
    Color? accentSoft,
    Color? textMuted,
    Color? glow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      textMuted: textMuted ?? this.textMuted,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      backgroundAlt:
          Color.lerp(backgroundAlt, other.backgroundAlt, t) ?? backgroundAlt,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t) ?? surfaceSoft,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t) ?? primaryDeep,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      glow: Color.lerp(glow, other.glow, t) ?? glow,
    );
  }
}
