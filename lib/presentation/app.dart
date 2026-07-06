import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/viewer_screen.dart';

/// Root MaterialApp with routing and theming.
class HmiViewerApp extends StatelessWidget {
  const HmiViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HMI Viewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/viewer') {
          return MaterialPageRoute(
            builder: (_) => const ViewerScreen(),
          );
        }
        return null;
      },
    );
  }
}
