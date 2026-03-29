import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_layout.dart';
import '../core/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isDesktop = AppLayout.isDesktop(context);
    final isApple = AppLayout.isApple(context);
    final maxWidth = AppLayout.contentMaxWidth(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isLight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF5F7FF),
                  palette.background,
                  const Color(0xFFF5DDFD),
                  const Color(0xFFE4EEFF),
                ],
                stops: const [0.0, 0.34, 0.72, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.background,
                  palette.primaryDeep.withValues(alpha: 0.94),
                  palette.backgroundAlt,
                ],
              ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: isDesktop
                      ? const Alignment(-0.55, -0.75)
                      : const Alignment(-0.4, -0.8),
                  radius: 1.25,
                  colors: [
                    (isLight ? palette.primary : palette.accentSoft).withValues(
                      alpha: isLight ? 0.18 : 0.12,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (isLight)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.26),
                      Colors.transparent,
                      palette.primary.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: isLight ? -30 : -80,
            right: isLight ? -10 : -40,
            child: _GlowOrb(
              color: (isLight ? palette.accent : palette.primary).withValues(
                alpha: isLight ? 0.22 : 0.24,
              ),
              size: isLight ? 280 : 220,
            ),
          ),
          Positioned(
            bottom: isLight ? -30 : -100,
            left: isLight ? -30 : -60,
            child: _GlowOrb(
              color: (isLight ? palette.accentSoft : palette.accent).withValues(
                alpha: isLight ? 0.28 : 0.16,
              ),
              size: isLight ? 320 : 260,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: padding,
                  child: isDesktop || isApple
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 38 : 30,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: isDesktop ? 14 : 8,
                              sigmaY: isDesktop ? 14 : 8,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: palette.surface.withValues(
                                  alpha: isLight
                                      ? (isDesktop ? 0.3 : 0.18)
                                      : (isDesktop ? 0.24 : 0.14),
                                ),
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 38 : 30,
                                ),
                                border: Border.all(
                                  color: palette.glow.withValues(
                                    alpha: isLight ? 0.44 : 0.08,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isDesktop ? 18 : 6),
                                child: child,
                              ),
                            ),
                          ),
                        )
                      : child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
