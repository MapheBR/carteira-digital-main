import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'app/app_navigator.dart';
import 'app/theme_mode_button.dart';
import 'scenes/splash/splash_factory.dart';

void main() {
  runApp(const CarteiraApp());
}

class CarteiraApp extends StatelessWidget {
  const CarteiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Carteira Digital',
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        // Splash decide: sessão salva → Home; sem sessão → Login.
        home: SplashFactory.make(),
      ),
    );
  }
}
