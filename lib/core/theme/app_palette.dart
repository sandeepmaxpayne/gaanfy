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
    background: Color(0xFF080618),
    backgroundAlt: Color(0xFF130E2D),
    surface: Color(0xFF110D24),
    surfaceSoft: Color(0xFF191338),
    primary: Color(0xFF6C57FF),
    primaryDeep: Color(0xFF050313),
    secondary: Color(0xFF9B8DDF),
    accent: Color(0xFF7C66FF),
    accentSoft: Color(0xFF5946E8),
    textMuted: Color(0xFF9A93C9),
    glow: Color(0xFFF4F1FF),
  );

  static const light = AppPalette(
    background: Color(0xFFE8ECFF),
    backgroundAlt: Color(0xFFD8DFFF),
    surface: Color(0xFFF8F4FF),
    surfaceSoft: Color(0xFFEADDFB),
    primary: Color(0xFF7A62FF),
    primaryDeep: Color(0xFF2A2F72),
    secondary: Color(0xFF9E91D8),
    accent: Color(0xFFC45CFF),
    accentSoft: Color(0xFF7FD6FF),
    textMuted: Color(0xFF706B96),
    glow: Color(0xFFFFFFFF),
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
