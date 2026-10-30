import 'package:flutter/material.dart';

/// Tema escolhido no app. Um [ValueNotifier] basta: um valor, sem pacote.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

/// Botão do topo que alterna entre tema claro e escuro.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => IconButton(
        tooltip: 'Alternar tema',
        icon: const Icon(Icons.brightness_medium_outlined),
        onPressed: () => appThemeMode.value = mode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark,
      ),
    );
  }
}
