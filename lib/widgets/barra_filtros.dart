import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';
import '../ui/aparencia.dart';

/// Linha rolável de filtros: situação, prioridade e categoria.
class BarraFiltros extends StatelessWidget {
  const BarraFiltros({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TarefaProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          for (final status in FiltroStatus.values)
            _Espacado(
              ChoiceChip(
                label: Text(status.rotulo),
                selected: provider.statusFiltro == status,
                onSelected: (_) => provider.filtrarStatus(status),
              ),
            ),
          const _Separador(),
          for (final prioridade in Prioridade.values)
            _Espacado(
              FilterChip(
                avatar: Icon(Icons.flag, color: prioridade.cor),
                label: Text(prioridade.rotulo),
                selected: provider.prioridadeFiltro == prioridade,
                onSelected: (marcado) =>
                    provider.filtrarPrioridade(marcado ? prioridade : null),
              ),
            ),
          const _Separador(),
          for (final categoria in Categoria.values)
            _Espacado(
              FilterChip(
                avatar: Icon(categoria.icone),
                label: Text(categoria.rotulo),
                selected: provider.categoriaFiltro == categoria,
                onSelected: (marcado) =>
                    provider.filtrarCategoria(marcado ? categoria : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _Espacado extends StatelessWidget {
  const _Espacado(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: child);
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.only(right: 8),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
