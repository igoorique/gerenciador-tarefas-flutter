import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tarefa.dart';

/// Camada de dados: salva e lê as tarefas no armazenamento local.
///
/// O pacote shared_preferences usa SharedPreferences no Android,
/// NSUserDefaults no iOS e localStorage na web. As tarefas são guardadas
/// como uma lista em JSON.
class TarefaRepository {
  static const _chave = 'tarefas';

  Future<List<Tarefa>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = prefs.getString(_chave);
    if (conteudo == null || conteudo.isEmpty) return [];

    try {
      final lista = jsonDecode(conteudo) as List<dynamic>;
      return [
        for (final item in lista)
          if (item is Map<String, dynamic>) Tarefa.fromJson(item),
      ];
    } catch (erro) {
      debugPrint('Não foi possível ler as tarefas salvas: $erro');
      return [];
    }
  }

  Future<void> salvar(List<Tarefa> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    final conteudo = jsonEncode([for (final tarefa in tarefas) tarefa.toJson()]);
    await prefs.setString(_chave, conteudo);
  }
}
