import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_digital/scenes/login/login_coordinator.dart';
import 'package:carteira_digital/scenes/login/login_factory.dart';
import 'package:carteira_digital/scenes/login/login_view.dart';
import 'package:carteira_digital/scenes/login/login_view_model.dart';
import 'package:carteira_digital/scenes/login/server_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeServerLogin implements ServerLogin {
  _FakeServerLogin(this.result);

  final Result<void> result;
  int calls = 0;

  @override
  Future<Result<void>> fetchLogin({
    required String email,
    required String password,
  }) async {
    calls++;
    return result;
  }
}

class _FakeLoginCoordinator implements LoginCoordinator {
  int homeCalls = 0;

  @override
  void goToHome() => homeCalls++;
}

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

void main() {
  testWidgets('LoginFactory.make builds the login scene', (tester) async {
    await tester.pumpWidget(_app(LoginFactory.make()));

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('renders e-mail, password and primary button', (tester) async {
    final viewModel = LoginViewModel(
      serverLogin: _FakeServerLogin(const Ok(null)),
      coordinator: _FakeLoginCoordinator(),
    );
    await tester.pumpWidget(_app(LoginView(viewModel: viewModel)));

    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(find.byType(PasswordField), findsOneWidget);

    final button = tester.widget<AppButton>(
      find.byKey(const Key('login_submit')),
    );
    expect(button.variant, AppButtonVariant.primary);
  });

  testWidgets('success goes to home', (tester) async {
    final server = _FakeServerLogin(const Ok(null));
    final coordinator = _FakeLoginCoordinator();
    final viewModel = LoginViewModel(
      serverLogin: server,
      coordinator: coordinator,
    );
    await tester.pumpWidget(_app(LoginView(viewModel: viewModel)));

    await tester.enterText(find.byKey(const Key('login_email')), 'a@b.com');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(viewModel.email, 'a@b.com');
    expect(server.calls, 1);
    expect(coordinator.homeCalls, 1);
  });

  testWidgets('failure shows the error message', (tester) async {
    final coordinator = _FakeLoginCoordinator();
    final viewModel = LoginViewModel(
      serverLogin: _FakeServerLogin(
        const Failure(UnauthorizedError(invalidCredentials: true)),
      ),
      coordinator: coordinator,
    );
    await tester.pumpWidget(_app(LoginView(viewModel: viewModel)));

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(coordinator.homeCalls, 0);
  });
}
