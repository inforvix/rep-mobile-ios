import 'package:rep_p_mobile/src/model/funcionario.dart';
import 'package:rep_p_mobile/src/service/funcionarios_api.dart';

class FuncionarioRepository {
  Future<void> login({
    required String cpf,
    required String senha,
  }) {
    return FuncionarioApi().loginFuncionario(
      LoginFuncionarioModel(cpf: cpf, senha: senha),
    );
  }
}
