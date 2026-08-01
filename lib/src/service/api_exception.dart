import 'dart:convert';

/// Exceção com a mensagem de erro retornada pela API (ou uma mensagem padrão),
/// pronta para ser exibida ao usuário.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  /// Extrai o campo 'message' do body JSON da resposta; se não existir,
  /// retorna [padrao].
  static String extrairMensagem(String body, String padrao) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}
    return padrao;
  }

  @override
  String toString() => message;
}
