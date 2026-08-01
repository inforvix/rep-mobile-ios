import 'package:rep_p_mobile/src/database/database_provider.dart';

class LembreteDao {
  static Future<int> insertLembrete({
    required String titulo,
    required String hora,
    required List<String> diasSemana,
  }) async {
    final db = await DatabaseProvider.database;
    if (db == null) return -1;

    return await db.insert('lembretes', {
      'titulo': titulo,
      'hora': hora,
      'dias_semana': diasSemana.join(','),
    });
  }

  static Future<List<Map<String, dynamic>>> getLembretes() async {
    final db = await DatabaseProvider.database;
    if (db == null) return [];
    return await db.query('lembretes');
  }

  static Future<int> deleteLembrete(int id) async {
    final db = await DatabaseProvider.database;
    if (db == null) return 0;
    return await db.delete('lembretes', where: 'id = ?', whereArgs: [id]);
  }
}
