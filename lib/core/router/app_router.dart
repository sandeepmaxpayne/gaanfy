import 'package:go_router/go_router.dart';

import '../../views/auth/login_screen.dart';
import '../../views/auth/signup_screen.dart';
import '../../views/home/home_shell_screen.dart';
import '../../views/player/offline_now_playing_screen.dart';
import '../../views/player/online_now_playing_screen.dart';
import '../../views/splash/logo_splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LogoSplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShellScreen()),
      GoRoute(
        path: '/online-player',
        builder: (_, __) => const OnlineNowPlayingScreen(),
      ),
      GoRoute(
        path: '/offline-player',
        builder: (_, __) => const OfflineNowPlayingScreen(),
      ),
    ],
  );
}
