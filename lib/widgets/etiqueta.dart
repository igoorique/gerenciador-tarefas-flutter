import 'package:flutter/material.dart';

/// Pequena etiqueta colorida com ícone (categoria, prioridade, prazo).
class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.icone,
    required this.texto,
    required this.cor,
    required this.corFundo,
  });

  final IconData icone;
  final String texto;
  final Color cor;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
