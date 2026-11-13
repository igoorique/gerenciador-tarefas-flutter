import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';
import '../widgets/barra_filtros.dart';
import '../widgets/resumo_tarefas.dart';
import '../widgets/tarefa_card.dart';
import 'tarefa_form_screen.dart';

/// Tela principal: resumo, busca, filtros e lista de tarefas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirFormulario([Tarefa? tarefa]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TarefaFormScreen(tarefa: tarefa),
      ),
    );
  }

  void _excluir(Tarefa tarefa) {
    final provider = context.read<TarefaProvider>();
    final posicao = provider.remover(tarefa.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${tarefa.titulo}" foi excluída'),
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => provider.restaurar(tarefa, posicao),
          ),
        ),
      );
  }

  void _limparFiltros() {
    _buscaController.clear();
    context.read<TarefaProvider>().limparFiltros();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TarefaProvider>();

    return Scaffold(
      // O teclado da busca cobre a lista em vez de espremer a tela
      // (evita overflow com o celular deitado).
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          if (provider.temFiltroAtivo)
            IconButton(
              tooltip: 'Limpar filtros',
              icon: const Icon(Icons.clear_all),
              onPressed: _limparFiltros,
            ),
        ],
      ),
      body: provider.carregando
          ? const Center(child: CircularProgressIndicator())
          : _conteudo(provider),
      floatingActionButton: provider.carregando
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'),
            ),
    );
  }

  Widget _conteudo(TarefaProvider provider) {
    final tarefas = provider.tarefasVisiveis;

    return Column(
      children: [
        if (provider.total > 0) const ResumoTarefas(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _buscaController,
            onChanged: provider.buscar,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar tarefas',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.busca.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _buscaController.clear();
                        provider.buscar('');
                      },
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const BarraFiltros(),
        Expanded(
          child: tarefas.isEmpty
              ? _EstadoVazio(
                  semTarefas: provider.total == 0,
                  onLimparFiltros: _limparFiltros,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  itemCount: tarefas.length,
                  itemBuilder: (context, indice) {
                    final tarefa = tarefas[indice];
                    // Deslizar para a esquerda exclui (com opção de desfazer).
                    return Dismissible(
                      key: ValueKey(tarefa.id),
                      direction: DismissDirection.endToStart,
                      background: const _FundoExcluir(),
                      onDismissed: (_) => _excluir(tarefa),
                      child: TarefaCard(
                        tarefa: tarefa,
                        onAlternarConclusao: () =>
                            provider.alternarConclusao(tarefa.id),
                        onAbrir: () => _abrirFormulario(tarefa),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Fundo vermelho que aparece ao deslizar um card.
class _FundoExcluir extends StatelessWidget {
  const _FundoExcluir();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Excluir',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Mensagem exibida quando não há nada para mostrar na lista.
class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.semTarefas, required this.onLimparFiltros});

  final bool semTarefas;
  final VoidCallback onLimparFiltros;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              semTarefas ? Icons.check_circle_outline : Icons.search,
              size: 72,
              color: tema.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              semTarefas ? 'Nenhuma tarefa por aqui' : 'Nenhuma tarefa encontrada',
              style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              semTarefas
                  ? 'Toque em "Nova tarefa" para criar a primeira.'
                  : 'Tente outro termo de busca ou limpe os filtros.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
            if (!semTarefas) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onLimparFiltros,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
