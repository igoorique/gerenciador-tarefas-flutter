// Funções de apoio para datas (sem pacotes externos).

/// Quantos dias de calendário faltam de [referencia] até [data].
/// Amanhã → 1, hoje → 0, ontem → -1. As horas são ignoradas.
int diasAte(DateTime data, DateTime referencia) {
  final alvo = DateTime.utc(data.year, data.month, data.day);
  final base = DateTime.utc(referencia.year, referencia.month, referencia.day);
  return alvo.difference(base).inDays;
}

/// Formata no padrão brasileiro: 13/11/2026.
String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// Texto curto para o prazo: "Hoje", "Amanhã", "Ontem" ou a data.
String descreverPrazo(DateTime prazo, [DateTime? referencia]) {
  final dias = diasAte(prazo, referencia ?? DateTime.now());
  if (dias == 0) return 'Hoje';
  if (dias == 1) return 'Amanhã';
  if (dias == -1) return 'Ontem';
  return formatarData(prazo);
}

/// Versão completa, usada no formulário: "Amanhã · 14/11/2026".
String descreverPrazoCompleto(DateTime prazo, [DateTime? referencia]) {
  final curto = descreverPrazo(prazo, referencia);
  final data = formatarData(prazo);
  return curto == data ? data : '$curto · $data';
}
