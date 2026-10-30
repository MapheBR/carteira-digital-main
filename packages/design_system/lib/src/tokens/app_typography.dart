import 'package:flutter/material.dart';

/// Type scale do Finance Management: Poppins, empacotada neste pacote.
///
/// Referências do Finance Management (lib/common/app_text_styles.dart):
/// title 20/w600, subtitle 15/w500, paragraph 13/w300.
abstract final class AppTypography {
  static const String fontFamily = 'Poppins';
  static const String fontPackage = 'carteira_design_system';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 20, // FM title
    fontWeight: FontWeight.w600,
    height: 1.1,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 15, // FM subtitle
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 13, // FM paragraph
    fontWeight: FontWeight.w300,
    height: 1.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 15, // texto dos botões
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
  );

  /// Money figures use tabular digits so columns line up.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
