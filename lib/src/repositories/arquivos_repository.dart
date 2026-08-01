import 'package:file_picker/file_picker.dart';
import 'package:rep_p_mobile/src/model/documento.dart';
import 'package:rep_p_mobile/src/service/arquivos_api.dart';

class ArquivosRepository {
  Future<List<DocumentoModel>> listarDocumentos() {
    return ArquivosApi().listarDocumentos();
  }

  Future<List<DocumentoModel>> listarDocumentosRecebidos() {
    return ArquivosApi().listarDocumentosRecebidos();
  }

  String urlAbrirDocumento({required String origem, required int id}) {
    return ArquivosApi.urlAbrirDocumento(origem: origem, id: id);
  }

  Future<void> enviarDocumento({
    required PlatformFile arquivo,
    required String nomeArquivo,
    required String tipo,
    required String data,
    required String observacao,
  }) {
    return ArquivosApi().enviarDocumento(
      arquivo: arquivo,
      nomeArquivo: nomeArquivo,
      tipo: tipo,
      data: data,
      observacao: observacao,
    );
  }
}
