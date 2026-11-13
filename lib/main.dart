import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/tarefa_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // O Provider deixa o estado das tarefas disponível para todas as telas.
    ChangeNotifierProvider(
      create: (_) => TarefaProvider()..carregar(),
      child: const GerenciadorTarefasApp(),
    ),
  );
}

class GerenciadorTarefasApp extends StatelessWidget {
  const GerenciadorTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      // Português do Brasil em todo o app (inclusive no calendário).
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
