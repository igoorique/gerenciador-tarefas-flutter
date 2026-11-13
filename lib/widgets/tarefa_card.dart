import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../ui/aparencia.dart';
import '../utils/datas.dart';
import 'etiqueta.dart';

/// Card de uma tarefa na lista: checkbox, título, descrição e etiquetas.
class TarefaCard extends StatelessWidget {
  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onAlternarConclusao,
    required this.onAbrir,
  });

  final Tarefa tarefa;
  final VoidCallback onAlternarConclusao;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final prazo = tarefa.prazo;
    final atrasada = tarefa.estaAtrasada();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAbrir,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: tarefa.concluida,
                onChanged: (_) => onAlternarConclusao(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarefa.titulo,
                        style: tema.textTheme.titleMedium?.copyWith(
                          color:
                              tarefa.concluida ? cores.outline : cores.onSurface,
                          decoration: tarefa.concluida
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (tarefa.descricao.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          tarefa.descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodyMedium
                              ?.copyWith(color: cores.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Etiqueta(
                            icone: tarefa.categoria.icone,
                            texto: tarefa.categoria.rotulo,
                            cor: cores.onSecondaryContainer,
                            corFundo: cores.secondaryContainer,
                          ),
                          Etiqueta(
                            icone: Icons.flag,
                            texto: tarefa.prioridade.rotulo,
                            cor: tarefa.prioridade.cor,
                            corFundo: tarefa.prioridade.corFundo,
                          ),
                          if (prazo != null)
                            Etiqueta(
                              icone:
                                  atrasada ? Icons.error_outline : Icons.event,
                              texto: atrasada
                                  ? 'Atrasada · ${descreverPrazo(prazo)}'
                                  : descreverPrazo(prazo),
                              cor: atrasada
                                  ? Colors.red.shade700
                                  : cores.onSurfaceVariant,
                              corFundo: atrasada
                                  ? Colors.red.shade50
                                  : cores.surfaceContainerHighest,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
