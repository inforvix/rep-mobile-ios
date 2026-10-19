import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda as credenciais entre sessões e encerra a sessão atual.
///
/// Login e preferências continuam em [SharedPreferences] (como já era feito).
/// A senha vai para o armazenamento seguro da plataforma — Keychain no iOS,
/// KeyStore/AES-GCM no Android e WebCrypto no navegador —, nunca em texto
/// puro. Quiosque e individual têm chaves separadas porque um guarda CNPJ e
/// o outro CPF.
class CredenciaisService {
  static const FlutterSecureStorage _cofre = FlutterSecureStorage();

  /// Chave legada: já era usada para o CPF antes do modo quiosque existir.
  static const String _kLoginIndividual = 'login';
  static const String _kLoginQuiosque = 'login_quiosque';
  static const String _kSalvarSenha = 'salvarSenha';

  static String _chaveLogin(bool quiosque) =>
      quiosque ? _kLoginQuiosque : _kLoginIndividual;

  static String _chaveSenha(bool quiosque) =>
      quiosque ? 'senha_quiosque' : 'senha_individual';

  static Future<String?> lerLogin(bool quiosque) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveLogin(quiosque));
  }

  static Future<bool> lerSalvarSenha() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSalvarSenha) ?? false;
  }

  /// Retorna a senha guardada, ou `null` se não houver — ou se o cofre da
  /// plataforma falhar (navegador sem WebCrypto, Keychain bloqueado, etc.).
  /// Falhar aqui só significa digitar a senha de novo, então nunca propaga.
  static Future<String?> lerSenha(bool quiosque) async {
    try {
      return await _cofre.read(key: _chaveSenha(quiosque));
    } catch (_) {
      return null;
    }
  }

  static Future<void> salvarLogin(bool quiosque, String login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveLogin(quiosque), login);
  }

  static Future<bool> lerModoOperacao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('modoOperacao') ?? false;
  }

  static Future<void> salvarModoOperacao(bool quiosque) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOperacao', quiosque);
  }

  /// Guarda ou apaga a senha conforme o switch "Salvar senha".
  static Future<void> definirSenha({
    required bool quiosque,
    required bool salvar,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSalvarSenha, salvar);

    try {
      if (salvar) {
        await _cofre.write(key: _chaveSenha(quiosque), value: senha);
      } else {
        await _cofre.delete(key: _chaveSenha(quiosque));
      }
    } catch (_) {
      // Cofre indisponível: o app segue funcionando, só não lembra a senha.
    }
  }

  /// Apaga as senhas guardadas nos dois modos.
  static Future<void> apagarSenhas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSalvarSenha, false);

    try {
      await _cofre.delete(key: _chaveSenha(true));
      await _cofre.delete(key: _chaveSenha(false));
    } catch (_) {
      // Ver comentário em definirSenha.
    }
  }

  /// Encerra a sessão: derruba o token e os dados do usuário logado.
  ///
  /// O login e a senha guardados são preservados de propósito — quem marcou
  /// "Salvar senha" espera reencontrá-la no próximo acesso. Use
  /// [apagarSenhas] quando a intenção for esquecer a credencial.
  static Future<void> logout() async {
    DadosGlobais.token = '';
    DadosGlobais.cpfLogin = '';
    DadosGlobais.idEmpresa = 0;
    DadosGlobais.contratoEmpresa = '';
    DadosGlobais.funcionarioBatePontoFacial = false;

    nomeFuncionarioModoQuiosque = '';
    dataModoQuiosque = '';
    horaModoQuiosque = '';
  }
}
