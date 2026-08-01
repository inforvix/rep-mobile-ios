import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/funcionario.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';

class FuncionarioApi {
  Future<void> loginFuncionario(LoginFuncionarioModel funcionario) async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/funcionario/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(funcionario.toJson());

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final responseBody = json.decode(response.body);

      DadosGlobais.token = responseBody['token'] ?? '';
      DadosGlobais.cpfLogin = funcionario.cpf!;
      // Versões diferentes do backend retornam chaves diferentes para
      // indicar se o funcionário registra ponto por foto.
      DadosGlobais.funcionarioBatePontoFacial =
          (responseBody['funcionarioUsaFoto'] ??
                  responseBody['solicitaFoto'] ??
                  false) ==
              true;
    } else {
      throw ApiException(ApiException.extrairMensagem(
          response.body, 'Falha ao fazer login (${response.statusCode})'));
    }
  }
}
