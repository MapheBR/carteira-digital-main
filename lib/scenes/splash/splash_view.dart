import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'splash_view_model.dart';

/// "Tela invisível": aparece só enquanto o app verifica a sessão salva.
class SplashView extends StatefulWidget {
  const SplashView({required this.viewModel, super.key});

  final SplashViewModel viewModel;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.start();
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(showAppBar: false, body: StateView.loading());
  }
}
