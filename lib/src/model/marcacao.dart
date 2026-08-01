class GetMarcacoesModel {
  String? nsr;
  String? cpf;
  String? data;
  String? hora;
  String? cnpj;
  String? inpiCodigo;
  String? funcionario;

  GetMarcacoesModel({
    this.nsr,
    this.cpf,
    this.data,
    this.hora,
    this.cnpj,
    this.inpiCodigo,
    this.funcionario,
  });

  GetMarcacoesModel.fromJson(Map<String, dynamic> json) {
    nsr = json['nsr'];
    cpf = json['cpf'];
    data = json['data'];
    hora = json['hora'];
    cnpj = json['cnpj'];
    inpiCodigo = json['inpi_codigo'];
    funcionario = json['funcionario'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['nsr'] = nsr;
    map['cpf'] = cpf;
    map['data'] = data;
    map['hora'] = hora;
    map['cnpj'] = cnpj;
    map['inpi_codigo'] = inpiCodigo;
    map['funcionario'] = funcionario;
    return map;
  }
}
