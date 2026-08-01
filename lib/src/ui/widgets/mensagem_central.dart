import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';

/// Mensagem centralizada com ícone, usada em estados de lista vazia/erro,
/// com botão de ação opcional (ex.: "Tentar novamente").
class MensagemCentral extends StatelessWidget {
  const MensagemCentral({
    super.key,
    required this.icone,
    required this.texto,
    this.acaoTitulo,
    this.acao,
  });

  final IconData icone;
  final String texto;
  final String? acaoTitulo;
  final Future<void> Function()? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 60, color: Colors.black26),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          if (acaoTitulo != null && acao != null) ...[
            const SizedBox(height: 16),
            ButtonPrimaryInforvix(titulo: acaoTitulo!, funcao: acao!),
          ],
        ],
      ),
    );
  }
}
