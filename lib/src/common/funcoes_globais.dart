import 'package:intl/intl.dart';

class FuncoesGlobais {
  /// Converte uma data digitada pelo usuário (dd/MM/yyyy) para o formato
  /// da API (yyyy-MM-dd). Lança [FormatException] se a data for inválida.
  static String formatarDataYYYYMMDD(String dataOriginal) {
    DateFormat formatadorOriginal = DateFormat("dd/MM/yyyy");
    DateTime dataConvertida = formatadorOriginal.parseStrict(dataOriginal);

    DateFormat formatadorNovo = DateFormat("yyyy-MM-dd");
    String dataFormatada = formatadorNovo.format(dataConvertida);
    return dataFormatada;
  }

  static String formatarDataExibicao(String dataOriginal) {
    try {
      final clean = dataOriginal.split('T').first;

      DateFormat formatadorOriginal = DateFormat("MM/dd/yyyy");
      DateTime dataConvertida = formatadorOriginal.parse(clean);

      DateFormat formatadorNovo = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
      return formatadorNovo.format(dataConvertida);
    } catch (e) {
      return dataOriginal;
    }
  }

  static String formatarHora(String horaOriginal) {
    try {
      return horaOriginal.substring(0, 5);
    } catch (e) {
      return horaOriginal;
    }
  }

  static String somenteNumeros(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Converte uma data ISO (yyyy-MM-dd ou yyyy-MM-ddTHH:mm:ss...) para
  /// dd/MM/yyyy. Retorna '-' para nulo/vazio.
  static String formatarDataIso(String? dataIso) {
    if (dataIso == null || dataIso.isEmpty) return '-';
    try {
      final somenteData = dataIso.split('T').first;
      final partes = somenteData.split('-');
      if (partes.length != 3) return dataIso;
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    } catch (_) {
      return dataIso;
    }
  }
}
