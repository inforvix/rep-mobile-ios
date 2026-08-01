// Smoke test: garante que o app sobe e exibe a tela de login.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rep_p_mobile/main.dart';

void main() {
  testWidgets('Tela de login é exibida', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Modo Quiosque'), findsOneWidget);
  });
}
