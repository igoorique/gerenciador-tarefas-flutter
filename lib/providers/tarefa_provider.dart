import 'package:flutter/foundation.dart';

import '../models/tarefa.dart';
import '../services/tarefa_repository.dart';
import '../utils/texto.dart';

/// Filtro de situação mostrado na tela inicial.
enum FiltroStatus {
  todas('Todas'),
  pendentes('Pendentes'),
  concluidas('Concluídas');

  const FiltroStatus(this.rotulo);

  final String rotulo;
}

/// Estado das tarefas (padrão Provider + ChangeNotifier).
///
/// As telas leem o estado com `context.watch<TarefaProvider>()` e chamam os
/// métodos abaixo. Cada alteração chama [notifyListeners], que redesenha as
/// telas, e depois grava tudo no aparelho pelo [TarefaRepository].
class TarefaProvider extends ChangeNotifier {
  TarefaProvider({TarefaRepository? repositorio})
      : _repositorio = repositorio ?? TarefaRepository();

  final TarefaRepository _repositorio;
  final List<Tarefa> _tarefas = [];

  bool _carregando = true;
  String _busca = '';
  Categoria? _categoriaFiltro;
  Prioridade? _prioridadeFiltro;
  FiltroStatus _statusFiltro = FiltroStatus.todas;

  bool get carregando => _carregando;
  String get busca => _busca;
  Categoria? get categoriaFiltro => _categoriaFiltro;
  Prioridade? get prioridadeFiltro => _prioridadeFiltro;
  FiltroStatus get statusFiltro => _statusFiltro;

  int get total => _tarefas.length;
  int get totalConcluidas => _tarefas.where((t) => t.concluida).length;
  int get totalPendentes => total - totalConcluidas;
  int get totalAtrasadas => _tarefas.where((t) => t.estaAtrasada()).length;
  double get progresso => total == 0 ? 0 : totalConcluidas / total;

  bool get temFiltroAtivo =>
      _busca.trim().isNotEmpty ||
      _categoriaFiltro != null ||
      _prioridadeFiltro != null ||
      _statusFiltro != FiltroStatus.todas;

  /// Tarefas exibidas: aplica busca e filtros e ordena de forma "inteligente"
  /// (pendentes primeiro, depois prioridade, prazo e as mais recentes).
  List<Tarefa> get tarefasVisiveis {
    final termo = normalizar(_busca.trim());
    return _tarefas.where((tarefa) {
      if (_statusFiltro == FiltroStatus.pendentes && tarefa.concluida) {
        return false;
      }
      if (_statusFiltro == FiltroStatus.concluidas && !tarefa.concluida) {
        return false;
      }
      if (_categoriaFiltro != null && tarefa.categoria != _categoriaFiltro) {
        return false;
      }
      if (_prioridadeFiltro != null && tarefa.prioridade != _prioridadeFiltro) {
        return false;
      }
      if (termo.isEmpty) return true;
      return normalizar('${tarefa.titulo} ${tarefa.descricao}').contains(termo);
    }).toList()
      ..sort(_comparar);
  }

  static int _comparar(Tarefa a, Tarefa b) {
    if (a.concluida != b.concluida) return a.concluida ? 1 : -1;

    final porPrioridade = a.prioridade.peso.compareTo(b.prioridade.peso);
    if (porPrioridade != 0) return porPrioridade;

    final prazoA = a.prazo;
    final prazoB = b.prazo;
    if (prazoA != null && prazoB == null) return -1;
    if (prazoA == null && prazoB != null) return 1;
    if (prazoA != null && prazoB != null) {
      final porPrazo = prazoA.compareTo(prazoB);
      if (porPrazo != 0) return porPrazo;
    }

    return b.criadaEm.compareTo(a.criadaEm);
  }

  // ---------- Dados ----------

  Future<void> carregar() async {
    final salvas = await _repositorio.carregar();
    _tarefas
      ..clear()
      ..addAll(salvas);
    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionar(Tarefa tarefa) {
    _tarefas.add(tarefa);
    notifyListeners();
    return _salvar();
  }

  Future<void> atualizar(Tarefa tarefa) {
    final indice = _indiceDe(tarefa.id);
    if (indice < 0) return Future.value();
    _tarefas[indice] = tarefa;
    notifyListeners();
    return _salvar();
  }

  Future<void> alternarConclusao(String id) {
    final indice = _indiceDe(id);
    if (indice < 0) return Future.value();
    final tarefa = _tarefas[indice];
    _tarefas[indice] = tarefa.copyWith(concluida: !tarefa.concluida);
    notifyListeners();
    return _salvar();
  }

  /// Remove a tarefa e devolve a posição que ela ocupava (para o "Desfazer").
  int remover(String id) {
    final indice = _indiceDe(id);
    if (indice < 0) return indice;
    _tarefas.removeAt(indice);
    notifyListeners();
    _salvar();
    return indice;
  }

  /// Desfaz uma exclusão, devolvendo a tarefa para a posição original.
  void restaurar(Tarefa tarefa, int posicao) {
    if (_indiceDe(tarefa.id) >= 0) return;
    final destino =
        (posicao < 0 || posicao > _tarefas.length) ? _tarefas.length : posicao;
    _tarefas.insert(destino, tarefa);
    notifyListeners();
    _salvar();
  }

  // ---------- Busca e filtros ----------

  void buscar(String texto) {
    _busca = texto;
    notifyListeners();
  }

  void filtrarStatus(FiltroStatus status) {
    _statusFiltro = status;
    notifyListeners();
  }

  void filtrarCategoria(Categoria? categoria) {
    _categoriaFiltro = categoria;
    notifyListeners();
  }

  void filtrarPrioridade(Prioridade? prioridade) {
    _prioridadeFiltro = prioridade;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _categoriaFiltro = null;
    _prioridadeFiltro = null;
    _statusFiltro = FiltroStatus.todas;
    notifyListeners();
  }

  int _indiceDe(String id) => _tarefas.indexWhere((t) => t.id == id);

  Future<void> _salvar() => _repositorio.salvar(_tarefas);
}
