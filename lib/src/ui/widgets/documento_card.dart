import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/common/funcoes_globais.dart';
import 'package:rep_p_mobile/src/model/documento.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';

/// Card de documento usado nas listas de enviados/recebidos.
/// [rotuloEnvio] é o prefixo da data de criação (ex.: 'Enviado em',
/// 'Recebido em').
class DocumentoCard extends StatelessWidget {
  const DocumentoCard({
    super.key,
    required this.documento,
    required this.rotuloEnvio,
    this.onTap,
  });

  final DocumentoModel documento;
  final String rotuloEnvio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 6,
        color: PaletaCores.backgroundWhiteSolid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.description,
                    color: PaletaCores.backgroundBlue, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.tipo ?? 'Documento',
                        style: Fonts.textStyleTituloEdit,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data do documento: ${FuncoesGlobais.formatarDataIso(documento.dataDocumento)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (documento.observacao != null &&
                          documento.observacao!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          documento.observacao!,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '$rotuloEnvio ${FuncoesGlobais.formatarDataIso(documento.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, color: Colors.black38, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
