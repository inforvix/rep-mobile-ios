import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/documento.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';

class ArquivosApi {
  /// URL autenticada para abrir o arquivo de um documento no navegador.
  /// [origem]: 'empresa' (recebidos) ou 'funcionario' (enviados).
  static String urlAbrirDocumento({required String origem, required int id}) {
    return '${DadosGlobais.baseUrl}/files/abrir/$origem/$id'
        '?token=${DadosGlobais.token}';
  }

  /// Lista os documentos que a empresa enviou para o funcionário logado.
  Future<List<DocumentoModel>> listarDocumentosRecebidos() async {
    const url = '${DadosGlobais.baseUrl}/files/documentos-recebidos';

    try {
      final response = await Dio().get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer ${DadosGlobais.token}',
        }),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => DocumentoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Falha ao carregar os documentos recebidos');
    }
  }

  /// Lista os documentos já enviados pelo funcionário logado.
  Future<List<DocumentoModel>> listarDocumentos() async {
    const url = '${DadosGlobais.baseUrl}/files/documentos';

    try {
      final response = await Dio().get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer ${DadosGlobais.token}',
        }),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => DocumentoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Falha ao carregar os documentos');
    }
  }

  /// Envia um documento (atestado, declaração etc.) para o backend via
  /// multipart. Além do arquivo, envia os textos da tela (tipo, data e
  /// observação) que o backend grava na tabela Documentos.
  ///
  /// [nomeArquivo] é o nome (sem extensão) com que o arquivo será salvo no
  /// servidor. [data] deve estar no formato yyyy-MM-dd.
  Future<void> enviarDocumento({
    required PlatformFile arquivo,
    required String nomeArquivo,
    required String tipo,
    required String data,
    required String observacao,
  }) async {
    const url = '${DadosGlobais.baseUrl}/files/documento';

    final MultipartFile multipart;
    if (arquivo.bytes != null) {
      multipart =
          MultipartFile.fromBytes(arquivo.bytes!, filename: arquivo.name);
    } else if (arquivo.path != null) {
      multipart =
          await MultipartFile.fromFile(arquivo.path!, filename: arquivo.name);
    } else {
      throw ApiException('Não foi possível ler o arquivo selecionado');
    }

    final formData = FormData.fromMap({
      'nome': nomeArquivo,
      'tipo': tipo,
      'data': data,
      'observacao': observacao,
      'arquivo': multipart,
    });

    try {
      await Dio().post(
        url,
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer ${DadosGlobais.token}',
        }),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Falha ao enviar o arquivo');
    }
  }
}
