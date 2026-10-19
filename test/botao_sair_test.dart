import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_p_mobile/src/pages/home/telas_quiosque/tela_home_quiosque.dart';

void main() {
  testWidgets('cabeçalho do quiosque mostra o botão Sair sem estourar layout',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TelaRegistrarMarcacaoQuiosque())),
    );
    await tester.pump();

    expect(find.text('Sair'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
