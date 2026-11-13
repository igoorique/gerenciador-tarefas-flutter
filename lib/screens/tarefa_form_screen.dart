import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';
import '../ui/aparencia.dart';
import '../utils/assistente_tarefas.dart';
import '../utils/datas.dart';

/// Formulário para criar (tarefa == null) ou editar uma tarefa.
class TarefaFormScreen extends StatefulWidget {
  const TarefaFormScreen({super.key, this.tarefa});

  final Tarefa? tarefa;

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;

  late Categoria _categoria;
  late Prioridade _prioridade;
  DateTime? _prazo;

  // Depois que o usuário escolhe um valor na mão, o assistente não mexe mais
  // naquele campo. Na edição, os valores existentes são respeitados.
  late bool _categoriaManual;
  late bool _prioridadeManual;
  Sugestao _sugestao = const Sugestao();

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final tarefa = widget.tarefa;
    _tituloController = TextEditingController(text: tarefa?.titulo ?? '');
    _descricaoController = TextEditingController(text: tarefa?.descricao ?? '');
    _categoria = tarefa?.categoria ?? Categoria.outros;
    _prioridade = tarefa?.prioridade ?? Prioridade.media;
    _prazo = tarefa?.prazo;
    _categoriaManual = tarefa != null;
    _prioridadeManual = tarefa != null;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  /// Pede uma nova sugestão ao assistente e aplica nos campos automáticos.
  void _atualizarSugestao() {
    final sugestao = AssistenteTarefas.sugerir(
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      prazo: _prazo,
    );
    setState(() {
      _sugestao = sugestao;
      if (!_categoriaManual) {
        _categoria = sugestao.categoria ?? Categoria.outros;
      }
      if (!_prioridadeManual) {
        _prioridade = sugestao.prioridade ?? Prioridade.media;
      }
    });
  }

  /// Texto da dica "Sugestão automática: ..." (null = não mostrar).
  String? get _textoSugestao {
    final partes = [
      if (!_categoriaManual && _sugestao.categoria != null)
        'categoria ${_sugestao.categoria!.rotulo}',
      if (!_prioridadeManual && _sugestao.prioridade != null)
        'prioridade ${_sugestao.prioridade!.rotulo}',
    ];
    if (partes.isEmpty) return null;
    return 'Sugestão automática: ${partes.join(' e ')}';
  }

  Future<void> _escolherPrazo() async {
    final hoje = DateTime.now();
    final atual = _prazo ?? hoje;
    final inicio = DateTime(hoje.year - 5);
    final fim = DateTime(hoje.year + 5);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      // Um prazo muito antigo (ou distante) continua dentro do intervalo.
      firstDate: atual.isBefore(inicio) ? atual : inicio,
      lastDate: atual.isAfter(fim) ? atual : fim,
      helpText: 'Prazo da tarefa',
    );
    if (escolhida == null || !mounted) return;
    _prazo = escolhida;
    _atualizarSugestao();
  }

  void _removerPrazo() {
    _prazo = null;
    _atualizarSugestao();
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<TarefaProvider>();
    final titulo = _tituloController.text.trim();
    final descricao = _descricaoController.text.trim();
    final original = widget.tarefa;

    if (original == null) {
      provider.adicionar(
        Tarefa.nova(
          titulo: titulo,
          descricao: descricao,
          categoria: _categoria,
          prioridade: _prioridade,
          prazo: _prazo,
        ),
      );
    } else {
      provider.atualizar(
        original.copyWith(
          titulo: titulo,
          descricao: descricao,
          categoria: _categoria,
          prioridade: _prioridade,
          prazo: _prazo,
          removerPrazo: _prazo == null,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmarExclusao() async {
    final original = widget.tarefa;
    if (original == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('"${original.titulo}" será excluída.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    context.read<TarefaProvider>().remover(original.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textoSugestao = _textoSugestao;
    final prazo = _prazo;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir tarefa',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmarExclusao,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('campoTitulo'),
                controller: _tituloController,
                autofocus: !_editando,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex.: Estudar para a prova de cálculo amanhã',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
                onChanged: (_) => _atualizarSugestao(),
              ),
              if (textoSugestao != null) _DicaSugestao(texto: textoSugestao),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _atualizarSugestao(),
              ),
              const SizedBox(height: 24),
              Text('Categoria', style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final categoria in Categoria.values)
                    ChoiceChip(
                      avatar: Icon(categoria.icone),
                      label: Text(categoria.rotulo),
                      selected: _categoria == categoria,
                      onSelected: (_) => setState(() {
                        _categoria = categoria;
                        _categoriaManual = true;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Prioridade', style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<Prioridade>(
                segments: [
                  for (final prioridade in Prioridade.values)
                    ButtonSegment<Prioridade>(
                      value: prioridade,
                      icon: Icon(Icons.flag, color: prioridade.cor),
                      label: Text(prioridade.rotulo),
                    ),
                ],
                selected: {_prioridade},
                onSelectionChanged: (selecao) => setState(() {
                  _prioridade = selecao.first;
                  _prioridadeManual = true;
                }),
              ),
              const SizedBox(height: 24),
              Text('Prazo', style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _escolherPrazo,
                      icon: const Icon(Icons.event),
                      label: Text(
                        prazo == null
                            ? 'Definir prazo'
                            : descreverPrazoCompleto(prazo),
                      ),
                    ),
                  ),
                  if (prazo != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remover prazo',
                      icon: const Icon(Icons.close),
                      onPressed: _removerPrazo,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: Text(_editando ? 'Salvar alterações' : 'Salvar tarefa'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha com o ícone ✨ explicando o que o assistente sugeriu.
class _DicaSugestao extends StatelessWidget {
  const _DicaSugestao({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = tema.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 18, color: cor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: tema.textTheme.bodySmall?.copyWith(color: cor),
            ),
          ),
        ],
      ),
    );
  }
}
