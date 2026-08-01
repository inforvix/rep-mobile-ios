import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';

class MarcacaoApi {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${DadosGlobais.token}'
      };

  Future<void> marcacaoToken(double lat, double lon) async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/marcacao/registraToken');

    final body = jsonEncode({
      'latitude': lat,
      'longitude': lon,
    });

    final response = await http.post(url, headers: _headers, body: body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao registrar marcação (${response.statusCode})'));
    }
  }

  Future<void> marcacaoCpfSenha(String cpf, String senha) async {
    final url =
        Uri.parse('${DadosGlobais.baseUrl}/marcacao/registra-cpf-senha');

    final body = jsonEncode({
      'cpf': cpf,
      'senha': senha,
    });

    final response = await http.post(url, headers: _headers, body: body);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final responseBody = json.decode(response.body);

      // A API retorna a data no formato MM/dd/yyyy.
      nomeFuncionarioModoQuiosque = responseBody['funcionario'] ?? '';
      dataModoQuiosque = responseBody['data'] ?? '';
      horaModoQuiosque = responseBody['hora'] ?? '';
    } else {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao registrar marcação (${response.statusCode})'));
    }
  }

  Future<void> justificarMarcacao(
      String nsr, String cpf, String hora, String observacao) async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/marcacao/observacao');

    final body = jsonEncode({
      'nsr': nsr,
      'cpf': cpf,
      'hora': hora,
      'observacao': observacao,
    });

    final response = await http.patch(url, headers: _headers, body: body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao salvar observação (${response.statusCode})'));
    }
  }

  Future<void> solicitarMarcacao(
      String data, String hora, String observacao) async {
    final url =
        Uri.parse('${DadosGlobais.baseUrl}/marcacao-solicitada/solicitar');

    final body = jsonEncode({
      'data': data,
      'hora': hora,
      'observacao': observacao,
    });

    final response = await http.post(url, headers: _headers, body: body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao solicitar marcação (${response.statusCode})'));
    }
  }

  Future<List<GetMarcacoesModel>> buscarMarcacoesDia(String cpf) async {
    final url = Uri.parse('${DadosGlobais.baseUrl}/marcacao/dia/$cpf');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return _parseMarcacoes(response.body);
    } else {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao buscar marcações do dia (${response.statusCode})'));
    }
  }

  Future<List<GetMarcacoesModel>> buscarMarcacoesPorPeriodo(
      String dataIni, String dataFim, String cpf) async {
    final url =
        Uri.parse('${DadosGlobais.baseUrl}/marcacao/$dataIni/$dataFim/$cpf');

    final response = await http.get(url, headers: _headers);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return _parseMarcacoes(response.body);
    } else {
      throw ApiException(ApiException.extrairMensagem(response.body,
          'Falha ao buscar marcações do período (${response.statusCode})'));
    }
  }

  List<GetMarcacoesModel> _parseMarcacoes(String body) {
    final Map<String, dynamic> jsonResponse = json.decode(body);

    if (jsonResponse['marcacoes'] == null) return [];

    final List<dynamic> marcacoesList = jsonResponse['marcacoes'];
    return marcacoesList
        .map((json) => GetMarcacoesModel.fromJson(json))
        .toList();
  }
}
