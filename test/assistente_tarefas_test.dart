import 'package:flutter_test/flutter_test.dart';

import 'package:gerenciador_tarefas/models/tarefa.dart';
import 'package:gerenciador_tarefas/utils/assistente_tarefas.dart';

void main() {
  // Data fixa para os testes não dependerem do dia em que rodam.
  final agora = DateTime(2026, 11, 13, 9);

  group('AssistenteTarefas.sugerir', () {
    test('prova amanhã vira Estudo com prioridade Alta', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Estudar para a prova de cálculo amanhã',
        agora: agora,
      );
      expect(sugestao.categoria, Categoria.estudo);
      expect(sugestao.prioridade, Prioridade.alta);
    });

    test('reunião com cliente vira Trabalho', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Reunião com o cliente',
        agora: agora,
      );
      expect(sugestao.categoria, Categoria.trabalho);
      expect(sugestao.prioridade, isNull);
    });

    test('consulta no dentista vira Saúde', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Marcar consulta no dentista',
        agora: agora,
      );
      expect(sugestao.categoria, Categoria.saude);
    });

    test('"quando der" vira prioridade Baixa', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Comprar presente para a mãe quando der',
        agora: agora,
      );
      expect(sugestao.categoria, Categoria.pessoal);
      expect(sugestao.prioridade, Prioridade.baixa);
    });

    test('prazo para amanhã eleva a prioridade para Alta', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Ligar para o João',
        prazo: DateTime(2026, 11, 14),
        agora: agora,
      );
      expect(sugestao.categoria, isNull);
      expect(sugestao.prioridade, Prioridade.alta);
    });

    test('prazo em 3 dias tira a tarefa da prioridade Baixa', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Organizar fotos quando der',
        prazo: DateTime(2026, 11, 16),
        agora: agora,
      );
      expect(sugestao.prioridade, Prioridade.media);
    });

    test('texto sem pistas não gera sugestão', () {
      final sugestao = AssistenteTarefas.sugerir(
        titulo: 'Ligar para o João',
        agora: agora,
      );
      expect(sugestao.vazia, isTrue);
    });
  });
}
