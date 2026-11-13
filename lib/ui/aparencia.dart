import 'package:flutter/material.dart';

import '../models/tarefa.dart';

/// Ícone de cada categoria (a parte visual fica fora do modelo).
extension CategoriaAparencia on Categoria {
  IconData get icone => switch (this) {
        Categoria.trabalho => Icons.work_outline,
        Categoria.estudo => Icons.school_outlined,
        Categoria.pessoal => Icons.person_outline,
        Categoria.saude => Icons.favorite_border,
        Categoria.outros => Icons.label_outline,
      };
}

/// Cores de cada prioridade.
extension PrioridadeAparencia on Prioridade {
  Color get cor => switch (this) {
        Prioridade.alta => Colors.red.shade700,
        Prioridade.media => Colors.orange.shade800,
        Prioridade.baixa => Colors.green.shade700,
      };

  Color get corFundo => switch (this) {
        Prioridade.alta => Colors.red.shade50,
        Prioridade.media => Colors.orange.shade50,
        Prioridade.baixa => Colors.green.shade50,
      };
}
