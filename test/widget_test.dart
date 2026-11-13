import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gerenciador_tarefas/main.dart';
import 'package:gerenciador_tarefas/providers/tarefa_provider.dart';

Future<void> abrirApp(WidgetTester tester) async {
  // Armazenamento falso e vazio para cada teste.
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => TarefaProvider()..carregar(),
      child: const GerenciadorTarefasApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre com a lista vazia', (tester) async {
    await abrirApp(tester);

    expect(find.text('Minhas tarefas'), findsOneWidget);
    expect(find.text('Nenhuma tarefa por aqui'), findsOneWidget);
  });

  testWidgets('cria uma tarefa usando a sugestão automática', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('campoTitulo')),
      'Reunião urgente com cliente',
    );
    await tester.pump();
    expect(find.textContaining('Sugestão automática'), findsOneWidget);

    final salvar = find.text('Salvar tarefa');
    await tester.ensureVisible(salvar);
    await tester.pumpAndSettle();
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(find.text('Reunião urgente com cliente'), findsOneWidget);
    expect(find.text('1 pendente'), findsOneWidget);
  });
}
