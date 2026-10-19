class DadosGlobais {
  //static const String baseUrl = 'http://149.18.51.246:50011'; // HOMOLOGACAO NO SERVER REPP
  static const String baseUrl =
      'http://repvixbackend.inforvix.net.br:50001'; // PRODUCAO NO SERVER REPP
  //static const String baseUrl = 'https://repvixbackend.inforvix.net.br:50006';

  static String token = '';
  static int idEmpresa = 0;
  static String cpfLogin = '';
  static bool modoQuiosque = false;
  static bool funcionarioBatePontoFacial = false;

  /// Contrato da empresa do funcionário logado.
  /// É a chave da collection de rostos no backend — o endpoint de facial
  /// individual identifica o rosto dentro do contrato, não do CPF.
  static String contratoEmpresa = '';
}

String nomeFuncionarioModoQuiosque = '';
String dataModoQuiosque = '';
String horaModoQuiosque = '';
