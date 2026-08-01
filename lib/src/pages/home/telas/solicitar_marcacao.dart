import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart' as externo;
import 'package:rep_p_mobile/src/repositories/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/edit.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SolicitarInclusaoMarcacao extends StatefulWidget {
  const SolicitarInclusaoMarcacao({super.key});

  @override
  State<SolicitarInclusaoMarcacao> createState() =>
      _SolicitarInclusaoMarcacaoState();
}

class _SolicitarInclusaoMarcacaoState extends State<SolicitarInclusaoMarcacao> {
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();

  bool _enviando = false;

  @override
  void dispose() {
    _dataController.dispose();
    _horaController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  Future<void> _solicitarInclusao() async {
    if (_enviando) return;

    if (_dataController.text.isEmpty || _horaController.text.isEmpty) {
      _mostrarErro('Por favor, preencha todos os campos.');
      return;
    }

    setState(() => _enviando = true);

    try {
      await MarcacaoRepository().solicitarMarcacao(
          data: _dataController.text,
          hora: _horaController.text,
          observacao: _observacaoController.text);

      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Solicitação enviada com sucesso!',
        ),
      );

      _observacaoController.clear();
      _dataController.clear();
      _horaController.clear();
    } on ApiException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Falha ao enviar a solicitação. Tente novamente.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PaletaCores.backgroundBlue,
        foregroundColor: Colors.white,
        title: const Text('Solicitar Inclusão de Marcação'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: PaletaCores.backgroundWhite,
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EditData(
                        titulo: 'Data',
                        controller: _dataController,
                      ),
                      EditHora(
                        titulo: 'Hora',
                        controller: _horaController,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: externo.EditMemoInforvix(
                    title: 'Observação',
                    hintText: 'Ex: Problemas com a internet',
                    controller: _observacaoController,
                  ),
                ),
                const Spacer(),
                _enviando
                    ? const CircularProgressIndicator()
                    : ButtonPrimaryInforvix(
                        titulo: 'Solicitar Inclusão',
                        funcao: _solicitarInclusao,
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
