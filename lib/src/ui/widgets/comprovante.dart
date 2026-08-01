import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart';
import 'package:rep_p_mobile/src/common/funcoes_globais.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/repositories/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/titulo_data.dart';
import 'package:svg_flutter/svg.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ComprovanteWidget extends StatefulWidget {
  const ComprovanteWidget({
    super.key,
    required this.marcacao,
  });

  final GetMarcacoesModel marcacao;

  @override
  State<ComprovanteWidget> createState() => _ComprovanteWidgetState();
}

class _ComprovanteWidgetState extends State<ComprovanteWidget> {
  final TextEditingController memoInforvix = TextEditingController();

  @override
  void dispose() {
    memoInforvix.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  Future<void> _salvarObservacao(BuildContext dialogContext) async {
    if (memoInforvix.text.isEmpty) {
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'Observação não pode ser vazia',
        ),
      );
      return;
    }

    if (widget.marcacao.nsr == null) {
      _mostrarErro('Esta marcação ainda não pode ser justificada');
      return;
    }

    try {
      await MarcacaoRepository().justificarMarcacao(
          nsr: widget.marcacao.nsr!,
          cpf: widget.marcacao.cpf ?? '',
          hora: widget.marcacao.hora ?? '',
          observacao: memoInforvix.text);

      memoInforvix.clear();

      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Observação salva com sucesso',
        ),
      );
    } on ApiException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Erro ao salvar observação');
    }
  }

  void _abrirDialogJustificar() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text('Justificar Marcação',
                  style: Fonts.textStyleTituloHoras),
              const SizedBox(height: 10),
              EditMemoInforvix(
                title: 'Digite uma observação para esta marcação',
                controller: memoInforvix,
                hintText: 'Ex: tive problemas de saúde',
              )
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ButtonTertiaryInforvix(
                    titulo: 'Cancelar',
                    funcao: () async {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ButtonPrimaryInforvix(
                    titulo: 'Salvar',
                    funcao: () => _salvarObservacao(dialogContext),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 10,
        child: GestureDetector(
          onTap: _abrirDialogJustificar,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: PaletaCores.backgroundWhiteSolid,
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      FuncoesGlobais.formatarHora(widget.marcacao.hora ?? ''),
                      style: Fonts.textStyleTituloHoras,
                    ),
                    const SizedBox(height: 3),
                    BagdeDyaOfWeek(day: widget.marcacao.data ?? ''),
                  ],
                ),
                const Spacer(),
                SvgPicture.asset(
                  'assets/icons/comprovante.svg',
                  height: 38,
                  width: 38,
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ComprovanteWidgetQuiosque extends StatelessWidget {
  const ComprovanteWidgetQuiosque({
    super.key,
    required this.titulo,
    required this.subTitulo,
    this.nomeFuncionario,
    this.destaque = false,
  });

  final String titulo;
  final String subTitulo;
  final String? nomeFuncionario;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: destaque ? 16 : 10,
        shape: destaque
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.green, width: 2),
              )
            : null,
        child: Container(
          height: nomeFuncionario != null ? 100 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: destaque
                ? Colors.green.shade50
                : PaletaCores.backgroundWhiteSolid,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (destaque)
                      const Text('Última marcação registrada :',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    if (nomeFuncionario != null) ...[
                      Text(
                        nomeFuncionario!,
                        style: Fonts.textStyleTituloHoras.copyWith(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(FuncoesGlobais.formatarHora(titulo),
                        style: Fonts.textStyleTituloHoras),
                    const SizedBox(height: 2),
                    Text(
                      FuncoesGlobais.formatarDataExibicao(subTitulo),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (destaque) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
