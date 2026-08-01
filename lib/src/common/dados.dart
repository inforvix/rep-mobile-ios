class DadosGlobais {
  //static const String baseUrl = 'http://149.18.51.246:50011'; // HOMOLOGACAO NO SERVER REPP
  static const String baseUrl =
  'http://localhost:50001';
      //'http://repvixbackend.inforvix.net.br:50001'; // PRODUCAO NO SERVER REPP
  //static const String baseUrl = 'https://repvixbackend.inforvix.net.br:50006';

  static String token = '';
  static int idEmpresa = 0;
  static String cpfLogin = '';
  static bool modoQuiosque = false;
  static bool funcionarioBatePontoFacial = false;
}

String nomeFuncionarioModoQuiosque = '';
String dataModoQuiosque = '';
String horaModoQuiosque = '';
