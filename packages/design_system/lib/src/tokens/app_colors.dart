import 'package:flutter/material.dart';

/// Raw color palette of the Carteira design system.
///
/// Two palettes, one per brightness, with the same field names so the theme
/// can be built from either one. Widgets never read these directly; they go
/// through [ThemeData] or `AppSemanticColors`.
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.error,
    required this.onError,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color outline;
  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color error;
  final Color onError;
}

/// The two official palettes.
///
/// Valores do design system "Finance Management" (repo financeManagement,
/// lib/common/app_colors.dart). Os nomes dos campos continuam os mesmos,
/// então nenhum widget ou tela precisa mudar.
abstract final class AppColors {
  // Cores de origem do Finance Management.
  static const Color _mainGreen = Color(0xFF00D09E);
  static const Color _oceanBlue = Color(0xFF0068FF);
  static const Color _categoryBlue = Color(0xFF6DB6FE);
  static const Color _lightGreen = Color(0xFFDFF7E2);
  static const Color _honeydew = Color(0xFFF1FFF3); // backgroundWhiteGreen
  static const Color _lettersIcons = Color(0xFF093030);
  static const Color _darkBlack = Color(0xFF031314);
  static const Color _darkBar = Color(0xFF0E3E3E);

  /// Light palette: fundo verde-claro, verde principal e textos verde-escuro.
  static const AppColorPalette light = AppColorPalette(
    primary: _mainGreen,
    onPrimary: _lettersIcons, // texto escuro sobre botão verde
    primaryContainer: _lightGreen,
    onPrimaryContainer: _lettersIcons,
    background: _honeydew,
    surface: _lightGreen,
    surfaceVariant: Color(0xFFC9EED0), // _lightGreen um tom abaixo (trilhas/barras)
    onSurface: _lettersIcons,
    onSurfaceMuted: Color(0xB3093030), // _lettersIcons com 70% de opacidade
    outline: _lightGreen,
    income: _mainGreen,
    expense: _oceanBlue,
    transfer: _categoryBlue,
    // O Finance Management não define aviso/erro: mantidos do Carteira.
    warning: Color(0xFFB26A1B),
    error: Color(0xFFB4483A),
    onError: Color(0xFFFFFFFF),
  );

  /// Dark palette: fundo quase preto, barras verde-petróleo, textos claros.
  static const AppColorPalette dark = AppColorPalette(
    primary: _mainGreen,
    onPrimary: _lettersIcons, // texto escuro mesmo no dark mode
    primaryContainer: _darkBar,
    onPrimaryContainer: _honeydew,
    background: _darkBlack,
    surface: _darkBar,
    surfaceVariant: Color(0xFF175252), // _darkBar um tom acima (trilhas/barras)
    onSurface: _honeydew,
    onSurfaceMuted: Color(0xB3F1FFF3), // _honeydew com 70% de opacidade
    outline: _darkBar,
    income: _mainGreen,
    expense: _oceanBlue,
    transfer: _categoryBlue,
    warning: Color(0xFFE0A24A),
    error: Color(0xFFE07A6C),
    onError: Color(0xFF2A0F0B),
  );
}
