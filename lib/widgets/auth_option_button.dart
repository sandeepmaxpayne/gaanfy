import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AuthOptionButton extends StatelessWidget {
  const AuthOptionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.badgeText,
    this.badgeColor = Colors.white,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badgeText;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        side: BorderSide(color: palette.secondary.withValues(alpha: 0.18)),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: palette.surface.withValues(alpha: 0.78),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22)
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badgeText ?? '',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
