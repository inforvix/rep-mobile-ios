class LoginEmpresaModel {
  String? login;
  String? senha;

  LoginEmpresaModel({this.login, this.senha});

  LoginEmpresaModel.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    senha = json['senha'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['login'] = login;
    data['senha'] = senha;
    return data;
  }
}
