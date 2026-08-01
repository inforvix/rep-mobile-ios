class Lembrete {
  final int? id;
  final String titulo;
  final String hora;
  final List<String> diasSemana;

  Lembrete({
    this.id,
    required this.titulo,
    required this.hora,
    required this.diasSemana,
  });

  factory Lembrete.fromMap(Map<String, dynamic> map) {
    return Lembrete(
      id: map['id'],
      titulo: map['titulo'],
      hora: map['hora'],
      diasSemana: (map['dias_semana'] as String).split(','),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'hora': hora,
      'dias_semana': diasSemana.join(','),
    };
  }
}
