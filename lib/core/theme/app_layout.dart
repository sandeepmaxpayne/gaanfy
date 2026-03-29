import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLayout {
  static bool isWeb(BuildContext context) => kIsWeb;

  static bool isDesktop(BuildContext context) {
    if (!kIsWeb) {
      return false;
    }
    return MediaQuery.sizeOf(context).width >= 1100;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 700;

  static bool isApple(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1520;
    }
    if (isTablet(context)) {
      return 920;
    }
    return double.infinity;
  }
}
