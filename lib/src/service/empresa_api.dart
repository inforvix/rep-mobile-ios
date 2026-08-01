import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/empresa.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';

class EmpresaApi {
  Future<void> loginEmpresa(LoginEmpresaModel empresa) async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/empresa/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(empresa.toJson());

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final responseBody = json.decode(response.body);

      DadosGlobais.token = responseBody['token'] ?? '';
      DadosGlobais.cpfLogin = empresa.login!;
      DadosGlobais.idEmpresa = responseBody['userid'] ?? 0;
    } else {
      throw ApiException(ApiException.extrairMensagem(
          response.body, 'Falha ao fazer login (${response.statusCode})'));
    }
  }
}
