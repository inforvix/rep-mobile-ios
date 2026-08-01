class LoginFuncionarioModel {
  String? cpf;
  String? senha;

  LoginFuncionarioModel({this.cpf, this.senha});

  LoginFuncionarioModel.fromJson(Map<String, dynamic> json) {
    cpf = json['cpf'];
    senha = json['senha'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cpf'] = cpf;
    data['senha'] = senha;
    return data;
  }
}
