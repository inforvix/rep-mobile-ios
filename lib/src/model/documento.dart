class DocumentoModel {
  final int? id;
  final String? tipo;
  final String? dataDocumento;
  final String? observacao;
  final String? nomeArquivo;
  final String? createdAt;
  final bool lido;

  DocumentoModel({
    this.id,
    this.tipo,
    this.dataDocumento,
    this.observacao,
    this.nomeArquivo,
    this.createdAt,
    this.lido = false,
  });

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id'],
      tipo: json['tipo'],
      dataDocumento: json['data_documento'],
      observacao: json['observacao'],
      nomeArquivo: json['nome_arquivo'],
      createdAt: json['createdAt'],
      lido: json['lido'] == true,
    );
  }
}
