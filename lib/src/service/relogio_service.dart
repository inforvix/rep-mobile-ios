import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rep_p_mobile/src/common/dados.dart';

class RelogioService {
  Future<DateTime> buscarHoraAtual() async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/rep/datahora/agora');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${DadosGlobais.token}'
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      final data = jsonResponse['data']; // "07/05/2025"
      final hora = jsonResponse['hora']; // "08:51:19"
      final dataHoraStr = "$data $hora";

      final format = DateFormat("dd/MM/yyyy HH:mm:ss");
      return format.parse(dataHoraStr);
    } else {
      throw Exception('Falha ao buscar hora atual: ${response.statusCode}');
    }
  }
}
