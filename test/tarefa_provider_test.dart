import 'package:flutter_test/flutter_test.dart';

import 'package:gerenciador_tarefas/models/tarefa.dart';
import 'package:gerenciador_tarefas/providers/tarefa_provider.dart';
import 'package:gerenciador_tarefas/services/tarefa_repository.dart';

/// Repositório falso, em memória, para testar o provider sem o aparelho.
class RepositorioEmMemoria implements TarefaRepository {
  List<Tarefa> salvas = [];

  @override
  Future<List<Tarefa>> carregar() async => List.of(salvas);

  @override
  Future<void> salvar(List<Tarefa> tarefas) async {
    salvas = List.of(tarefas);
  }
}

void main() {
  late RepositorioEmMemoria repositorio;
  late TarefaProvider provider;

  setUp(() async {
    repositorio = RepositorioEmMemoria();
    provider = TarefaProvider(repositorio: repositorio);
    await provider.carregar();
  });

  group('TarefaProvider', () {
    test('lista pendentes primeiro, ordenadas por prioridade', () async {
      await provider.adicionar(
        Tarefa.nova(titulo: 'Baixa', prioridade: Prioridade.baixa),
      );
      await provider.adicionar(
        Tarefa.nova(titulo: 'Alta', prioridade: Prioridade.alta),
      );
      await provider.adicionar(
        Tarefa.nova(titulo: 'Feita', prioridade: Prioridade.alta),
      );
      final feita =
          provider.tarefasVisiveis.firstWhere((t) => t.titulo == 'Feita');
      await provider.alternarConclusao(feita.id);

      expect(
        provider.tarefasVisiveis.map((t) => t.titulo).toList(),
        ['Alta', 'Baixa', 'Feita'],
      );
      expect(repositorio.salvas, hasLength(3));
    });

    test('busca ignora acentos e combina com o filtro de categoria', () async {
      await provider.adicionar(
        Tarefa.nova(
          titulo: 'Reunião com cliente',
          categoria: Categoria.trabalho,
        ),
      );
      await provider.adicionar(
        Tarefa.nova(titulo: 'Reunião de pais', categoria: Categoria.pessoal),
      );

      provider.buscar('reuniao');
      expect(provider.tarefasVisiveis, hasLength(2));

      provider.filtrarCategoria(Categoria.trabalho);
      expect(provider.tarefasVisiveis.single.titulo, 'Reunião com cliente');

      provider.limparFiltros();
      expect(provider.temFiltroAtivo, isFalse);
    });

    test('excluir e desfazer devolvem a tarefa', () async {
      final tarefa = Tarefa.nova(titulo: 'Comprar pão');
      await provider.adicionar(tarefa);

      final posicao = provider.remover(tarefa.id);
      expect(provider.total, 0);

      provider.restaurar(tarefa, posicao);
      expect(provider.total, 1);
    });
  });

  group('Tarefa', () {
    test('JSON de ida e volta mantém os dados', () {
      final original = Tarefa.nova(
        titulo: 'Entregar o trabalho',
        descricao: 'Código no GitHub e slides',
        categoria: Categoria.estudo,
        prioridade: Prioridade.alta,
        prazo: DateTime(2026, 11, 13),
      );
      final copia = Tarefa.fromJson(original.toJson());

      expect(copia.id, original.id);
      expect(copia.titulo, original.titulo);
      expect(copia.descricao, original.descricao);
      expect(copia.categoria, Categoria.estudo);
      expect(copia.prioridade, Prioridade.alta);
      expect(copia.prazo, DateTime(2026, 11, 13));
    });

    test('pendente com prazo vencido está atrasada', () {
      final referencia = DateTime(2026, 11, 13);
      final tarefa =
          Tarefa.nova(titulo: 'Pagar boleto', prazo: DateTime(2026, 11, 10));

      expect(tarefa.estaAtrasada(referencia), isTrue);
      expect(
        tarefa.copyWith(concluida: true).estaAtrasada(referencia),
        isFalse,
      );
    });
  });
}
