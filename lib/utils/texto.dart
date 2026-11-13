// Funções para comparar textos digitados pelo usuário.

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
const _semAcento = 'aaaaaeeeeiiiiooooouuuuc';

/// Converte para minúsculas e remove acentos.
/// Ex.: "Reunião às 14h" → "reuniao as 14h".
String normalizar(String texto) {
  final resultado = StringBuffer();
  for (final codigo in texto.toLowerCase().runes) {
    final caractere = String.fromCharCode(codigo);
    final posicao = _comAcento.indexOf(caractere);
    resultado.write(posicao >= 0 ? _semAcento[posicao] : caractere);
  }
  return resultado.toString();
}
