import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/local_database_service.dart';
import 'services/offline_music_service.dart';
import 'services/online_music_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/offline_music_view_model.dart';
import 'viewmodels/online_music_view_model.dart';
import 'viewmodels/theme_view_model.dart';

class GaanfyApp extends StatelessWidget {
  const GaanfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = LocalDatabaseService();
    final authService = AuthService();

    return MultiProvider(
      providers: [
        Provider.value(value: authService),
        Provider.value(value: databaseService),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnlineMusicViewModel(
            musicService: OnlineMusicService(),
            databaseService: databaseService,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => OfflineMusicViewModel(
            musicService: OfflineMusicService(),
            databaseService: databaseService,
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()..initialize()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp.router(
            title: 'Gaanfy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
