import '../models/tarefa.dart';
import 'datas.dart';
import 'texto.dart';

/// Resultado da análise feita pelo [AssistenteTarefas].
class Sugestao {
  const Sugestao({this.categoria, this.prioridade});

  final Categoria? categoria;
  final Prioridade? prioridade;

  bool get vazia => categoria == null && prioridade == null;
}

/// A parte "inteligente" do app.
///
/// Lê o título, a descrição e o prazo e sugere categoria e prioridade.
/// Funciona offline, com regras de palavras-chave (expressões regulares)
/// aplicadas ao texto já sem acentos.
class AssistenteTarefas {
  AssistenteTarefas._();

  static final Map<Categoria, List<RegExp>> _regrasCategoria = {
    Categoria.estudo: _compilar([
      r'estud\w*', r'provas?', r'aulas?', r'tcc', r'faculdade',
      r'universidade', r'semin\w*', r'artigos?', r'leitura', r'ler',
      r'exercicios?', r'materias?', r'disciplinas?', r'apostilas?',
      r'resum\w*', r'calculo', r'fisica', r'quimica', r'matematica',
      r'simulados?', r'vestibular', r'enem', r'professora?',
    ]),
    Categoria.trabalho: _compilar([
      r'trabalho', r'reuniao', r'reunioes', r'clientes?', r'relatorios?',
      r'projetos?', r'deploy', r'e-?mails?', r'planilhas?', r'chefe',
      r'gerente', r'sprint', r'empresa', r'escritorio', r'orcamentos?',
      r'propostas?', r'contratos?', r'entrevista', r'call',
    ]),
    Categoria.saude: _compilar([
      r'medic\w*', r'consultas?', r'dentista', r'academia',
      r'trein(?:o|os|ar)', r'remedios?', r'exames?', r'corrida', r'correr',
      r'caminhada', r'psicolog\w*', r'terapia', r'vacina\w*',
      r'fisioterapia', r'nutricionista', r'dieta', r'yoga', r'pilates',
      r'hospital', r'beber agua',
    ]),
    Categoria.pessoal: _compilar([
      r'compr\w*', r'mercado', r'supermercado', r'aniversario',
      r'presentes?', r'familia', r'pagar', r'contas?', r'boletos?',
      r'aluguel', r'limp\w*', r'faxina', r'lavar', r'roupas?', r'casa',
      r'viage\w*', r'viajar', r'banco', r'cozinhar', r'jantar', r'mae',
      r'pai', r'amig\w*', r'festa', r'cinema', r'cachorro', r'gato', r'pet',
    ]),
  };

  static final List<RegExp> _regrasUrgencia = _compilar([
    r'urgente', r'urgencia', r'importante', r'hoje', r'agora', r'amanha',
    r'imediat\w*', r'critic[oa]', r'sem falta', r'o quanto antes', r'asap',
  ]);

  static final List<RegExp> _regrasSemPressa = _compilar([
    r'quando der', r'quando puder', r'algum dia', r'sem pressa', r'talvez',
    r'opcional', r'eventualmente', r'se (?:der|sobrar) tempo',
    r'futuramente',
  ]);

  /// Analisa o texto (e o prazo, se houver) e devolve a sugestão.
  static Sugestao sugerir({
    required String titulo,
    String descricao = '',
    DateTime? prazo,
    DateTime? agora,
  }) {
    final texto = normalizar('$titulo $descricao');
    return Sugestao(
      categoria: _sugerirCategoria(texto),
      prioridade: _sugerirPrioridade(texto, prazo, agora ?? DateTime.now()),
    );
  }

  /// A categoria com mais palavras-chave encontradas vence.
  static Categoria? _sugerirCategoria(String texto) {
    Categoria? melhor;
    var maiorPontuacao = 0;
    for (final regra in _regrasCategoria.entries) {
      final pontos = _contar(texto, regra.value);
      if (pontos > maiorPontuacao) {
        melhor = regra.key;
        maiorPontuacao = pontos;
      }
    }
    return melhor;
  }

  static Prioridade? _sugerirPrioridade(
    String texto,
    DateTime? prazo,
    DateTime agora,
  ) {
    Prioridade? prioridade;
    if (_contar(texto, _regrasUrgencia) > 0) {
      prioridade = Prioridade.alta;
    } else if (_contar(texto, _regrasSemPressa) > 0) {
      prioridade = Prioridade.baixa;
    }

    if (prazo != null) {
      final dias = diasAte(prazo, agora);
      if (dias <= 1) {
        // Vence hoje, amanhã ou já venceu.
        prioridade = Prioridade.alta;
      } else if (dias <= 3 && prioridade != Prioridade.alta) {
        // Vence em até 3 dias: no mínimo, prioridade média.
        prioridade = Prioridade.media;
      }
    }
    return prioridade;
  }

  static int _contar(String texto, List<RegExp> regras) =>
      regras.where((regra) => regra.hasMatch(texto)).length;

  /// Cada padrão vira uma expressão que só casa com palavras inteiras.
  static List<RegExp> _compilar(List<String> padroes) =>
      [for (final padrao in padroes) RegExp('\\b(?:$padrao)\\b')];
}
