import 'package:flutter/painting.dart';

/// Corner radii (valores do Finance Management).
abstract final class AppRadius {
  static const double sm = 8; // ícones com borda, chips
  static const double md = 12; // campos de texto
  static const double lg = 20; // cards e modais
  static const double pill = 999; // botões em pílula

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
