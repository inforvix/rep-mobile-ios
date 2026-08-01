import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';

class BagdeDyaOfWeek extends StatelessWidget {
  const BagdeDyaOfWeek({
    required this.day,
    super.key,
  });

  final String day;

  /// A API retorna datas no formato MM/dd/yyyy (ou ISO yyyy-MM-dd).
  String _formatarData(String dataOriginal) {
    try {
      final clean = dataOriginal.split('T').first;

      DateTime dateTime;

      if (clean.contains('/')) {
        final partes = clean.split('/');
        dateTime = DateTime(
          int.parse(partes[2]), // ano
          int.parse(partes[0]), // mes
          int.parse(partes[1]), // dia
        );
      } else {
        dateTime = DateTime.parse(clean);
      }
      DateFormat formatter = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
      return formatter.format(dateTime);
    } catch (e) {
      return dataOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      height: 20,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.1),
          child: Text(
            _formatarData(day),
            style: Fonts.textStyleTituloEdit
                .copyWith(color: Colors.black, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
