import '../utils/datas.dart';

/// Categorias usadas para organizar as tarefas.
enum Categoria {
  trabalho('Trabalho'),
  estudo('Estudo'),
  pessoal('Pessoal'),
  saude('Saúde'),
  outros('Outros');

  const Categoria(this.rotulo);

  /// Nome exibido na tela.
  final String rotulo;
}

/// Níveis de prioridade. O [peso] define a ordem na lista (menor vem antes).
enum Prioridade {
  alta('Alta', 0),
  media('Média', 1),
  baixa('Baixa', 2);

  const Prioridade(this.rotulo, this.peso);

  final String rotulo;
  final int peso;
}

/// Uma tarefa. É imutável: para alterar, crie uma cópia com [copyWith].
class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.criadaEm,
    this.descricao = '',
    this.categoria = Categoria.outros,
    this.prioridade = Prioridade.media,
    this.concluida = false,
    this.prazo,
  });

  /// Cria uma tarefa nova, gerando o id e a data de criação.
  factory Tarefa.nova({
    required String titulo,
    String descricao = '',
    Categoria categoria = Categoria.outros,
    Prioridade prioridade = Prioridade.media,
    DateTime? prazo,
  }) {
    final agora = DateTime.now();
    return Tarefa(
      id: '${agora.microsecondsSinceEpoch}-${_contador++}',
      titulo: titulo,
      criadaEm: agora,
      descricao: descricao,
      categoria: categoria,
      prioridade: prioridade,
      prazo: prazo,
    );
  }

  /// Lê uma tarefa do JSON salvo no aparelho. Campos ausentes recebem
  /// valores padrão, para que um dado antigo nunca trave o app.
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      titulo: '${json['titulo'] ?? ''}',
      criadaEm: DateTime.tryParse('${json['criadaEm']}') ?? DateTime.now(),
      descricao: '${json['descricao'] ?? ''}',
      categoria: _porNome(Categoria.values, json['categoria'], Categoria.outros),
      prioridade:
          _porNome(Prioridade.values, json['prioridade'], Prioridade.media),
      concluida: json['concluida'] == true,
      prazo:
          json['prazo'] == null ? null : DateTime.tryParse('${json['prazo']}'),
    );
  }

  static int _contador = 0;

  final String id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final Prioridade prioridade;
  final bool concluida;
  final DateTime criadaEm;
  final DateTime? prazo;

  /// Atrasada = ainda pendente e com prazo em um dia que já passou.
  bool estaAtrasada([DateTime? referencia]) {
    final limite = prazo;
    if (concluida || limite == null) return false;
    return diasAte(limite, referencia ?? DateTime.now()) < 0;
  }

  /// Copia a tarefa trocando só os campos informados.
  /// Use [removerPrazo] para apagar o prazo.
  Tarefa copyWith({
    String? titulo,
    String? descricao,
    Categoria? categoria,
    Prioridade? prioridade,
    bool? concluida,
    DateTime? prazo,
    bool removerPrazo = false,
  }) {
    return Tarefa(
      id: id,
      titulo: titulo ?? this.titulo,
      criadaEm: criadaEm,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
      prazo: removerPrazo ? null : (prazo ?? this.prazo),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria.name,
        'prioridade': prioridade.name,
        'concluida': concluida,
        'criadaEm': criadaEm.toIso8601String(),
        'prazo': prazo?.toIso8601String(),
      };

  static T _porNome<T extends Enum>(List<T> valores, Object? nome, T padrao) {
    for (final valor in valores) {
      if (valor.name == nome) return valor;
    }
    return padrao;
  }
}
