import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_manager_frontend/services/account_service.dart';
import 'package:password_manager_frontend/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/services/login_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/pages/login_page.dart';
import 'package:mockito/annotations.dart';

import 'login_test.mocks.dart';

@GenerateMocks([LoginService, AuthService, AccountService, UserService])
void main() {
  late MockLoginService mockLoginService;
  late MockAuthService mockAuthService;
  late MockAccountService mockAccountService;
  late MockUserService mockUserService;

  setUp(() {
    mockLoginService = MockLoginService();
    mockAuthService = MockAuthService();
    mockAccountService = MockAccountService();
    mockUserService = MockUserService();
  });

  testWidgets('Успешный вход перенаправляет на HomePage', (tester) async {
    when(mockLoginService.login(
      accountLogin: argThat(isA<String>(), named: 'accountLogin'),
      password: argThat(isA<String>(), named: 'password'),
    )).thenAnswer((_) async => {
          'account_id': 1,
          'user_id': 2,
          'aes_key': 'SOME_AES_KEY',
        });

    when(mockAuthService.setSession(accountId: 1, userId: 2))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
            Provider<LoginService>.value(value: mockLoginService),
            Provider<AccountService>.value(value: mockAccountService),
            Provider<UserService>.value(value: mockUserService),
          ],
          child: const LoginPage(),
        ),
      ),
    );

    final loginField = find.widgetWithText(TextFormField, 'Логин аккаунта');
    final passwordField = find.widgetWithText(TextFormField, 'Пароль');

    await tester.enterText(loginField, 'demo');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(find.byType(ElevatedButton));

    await tester.pumpAndSettle();

    verify(mockLoginService.login(
      accountLogin: 'demo',
      password: 'password123',
    )).called(1);

    verify(mockAuthService.setSession(accountId: 1, userId: 2)).called(1);
  });
}
