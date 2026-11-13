import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tarefa_provider.dart';

/// Card de resumo no topo: progresso, pendentes e atrasadas.
class ResumoTarefas extends StatelessWidget {
  const ResumoTarefas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TarefaProvider>();
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    final pendentes = provider.totalPendentes;
    final atrasadas = provider.totalAtrasadas;
    final detalhes = [
      '$pendentes ${pendentes == 1 ? 'pendente' : 'pendentes'}',
      if (atrasadas > 0)
        '$atrasadas ${atrasadas == 1 ? 'atrasada' : 'atrasadas'}',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: cores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${provider.totalConcluidas} de ${provider.total} concluídas',
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.progresso,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              detalhes,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: cores.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
