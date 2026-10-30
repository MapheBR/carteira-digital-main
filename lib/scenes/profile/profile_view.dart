import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'profile_view_model.dart';

/// "Perfil" tab: who is signed in, the form to change name and photo, and
/// the button to leave.
class ProfileView extends StatefulWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_fillFields);
    widget.viewModel.start();
  }

  /// Puts the loaded profile into the fields once; after that, the text
  /// belongs to the user.
  void _fillFields() {
    final viewModel = widget.viewModel;
    if (_filled || !viewModel.hasProfile) return;
    _filled = true;
    _nameController.text = viewModel.nameInput;
    _avatarUrlController.text = viewModel.avatarUrlInput;
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_fillFields);
    widget.viewModel.dispose();
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final textTheme = Theme.of(context).textTheme;
    final muted = context.semanticColors.muted;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) return const StateView.loading();
        if (viewModel.errorMessage case final message?) {
          return StateView.error(message: message, onRetry: viewModel.start);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap.xxl(),
              Center(
                child: AppAvatar(
                  name: viewModel.name,
                  imageUrl: viewModel.avatarUrl,
                  size: 88,
                ),
              ),
              const Gap.lg(),
              Text(
                viewModel.name,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const Gap.xs(),
              Text(
                viewModel.email,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const Gap.xs(),
              Text(
                viewModel.memberSince,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SectionHeader(title: 'Dados'),
              const Gap.xs(),
              AppTextField(
                key: const Key('profile_name'),
                label: 'Nome',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                errorText: viewModel.nameError,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: viewModel.onNameChanged,
              ),
              const Gap.md(),
              AppTextField(
                key: const Key('profile_avatar_url'),
                label: 'URL da foto',
                controller: _avatarUrlController,
                prefixIcon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: viewModel.onAvatarUrlChanged,
                onSubmitted: (_) => viewModel.save(),
              ),
              const Gap.xl(),
              AppButton(
                key: const Key('profile_save'),
                label: 'Salvar',
                isLoading: viewModel.isSaving,
                onPressed: viewModel.save,
              ),
              const Gap.md(),
              AppButton.secondary(
                key: const Key('profile_logout'),
                label: 'Sair da conta',
                icon: Icons.logout,
                isLoading: viewModel.isLoggingOut,
                onPressed: viewModel.logout,
              ),
              const Gap.xxl(),
            ],
          ),
        );
      },
    );
  }
}
