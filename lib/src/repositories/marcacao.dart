import 'package:rep_p_mobile/src/common/funcoes_globais.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/service/registrar_marcacao.dart';

class MarcacaoRepository {
  Future<void> registrarMarcacao(
      {required double latitude, required double longitude}) {
    return MarcacaoApi().marcacaoToken(latitude, longitude);
  }

  Future<void> registrarMarcacaoCpfSenha({
    required String cpf,
    required String senha,
  }) {
    return MarcacaoApi().marcacaoCpfSenha(cpf, senha);
  }

  Future<void> justificarMarcacao(
      {required String nsr,
      required String cpf,
      required String hora,
      required String observacao}) {
    return MarcacaoApi().justificarMarcacao(nsr, cpf, hora, observacao);
  }

  Future<void> solicitarMarcacao(
      {required String data,
      required String hora,
      required String observacao}) {
    return MarcacaoApi().solicitarMarcacao(
        FuncoesGlobais.formatarDataYYYYMMDD(data), hora, observacao);
  }

  Future<List<GetMarcacoesModel>> getMarcacoes(String cpf) {
    return MarcacaoApi().buscarMarcacoesDia(cpf);
  }

  Future<List<GetMarcacoesModel>> getMarcacoesPeriodo(
      String dataIni, String dataFim, String cpf) {
    return MarcacaoApi().buscarMarcacoesPorPeriodo(
        FuncoesGlobais.formatarDataYYYYMMDD(dataIni),
        FuncoesGlobais.formatarDataYYYYMMDD(dataFim),
        cpf);
  }
}
