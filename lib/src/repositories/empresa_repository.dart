import 'package:rep_p_mobile/src/model/empresa.dart';
import 'package:rep_p_mobile/src/service/empresa_api.dart';

class EmpresaRepository {
  Future<void> login({
    required String login,
    required String senha,
  }) {
    return EmpresaApi().loginEmpresa(
      LoginEmpresaModel(login: login, senha: senha),
    );
  }
}
