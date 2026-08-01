// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/repositories/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/comprovante.dart';
import 'package:rep_p_mobile/src/ui/widgets/edit.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ConsultaMarcacoesTelas extends StatefulWidget {
  const ConsultaMarcacoesTelas({
    super.key,
  });

  @override
  State<ConsultaMarcacoesTelas> createState() => _ConsultaMarcacoesTelasState();
}

class _ConsultaMarcacoesTelasState extends State<ConsultaMarcacoesTelas> {
  final TextEditingController dataInicioController = TextEditingController();
  final TextEditingController dataFimController = TextEditingController();

  List<GetMarcacoesModel> marcacoes = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();

    final DateTime dataAtual = DateTime.now();
    final DateTime dataInicio = dataAtual.subtract(Duration(days: 3));
    dataInicioController.text = _formatarData(dataInicio);
    dataFimController.text = _formatarData(dataAtual);
  }

  @override
  void dispose() {
    dataInicioController.dispose();
    dataFimController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  Future<void> buscarMarcacoes() async {
    if (_buscando) return;

    if (dataInicioController.text.isEmpty || dataFimController.text.isEmpty) {
      _mostrarErro('Favor selecionar o período');
      return;
    }

    setState(() => _buscando = true);

    try {
      List<GetMarcacoesModel> resultado = await MarcacaoRepository()
          .getMarcacoesPeriodo(dataInicioController.text,
              dataFimController.text, DadosGlobais.cpfLogin);

      if (!mounted) return;
      setState(() {
        marcacoes = resultado;
      });

      if (marcacoes.isEmpty) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message: 'Não existem marcações no período selecionado',
          ),
        );
      }
    } on ApiException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Erro ao buscar marcações');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PaletaCores.backgroundBlue,
        foregroundColor: Colors.white,
        title: const Text('Consulta de Marcações'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: PaletaCores.backgroundWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EditData(
                  controller: dataInicioController,
                  titulo: 'Data Inicio',
                ),
                EditData(
                  controller: dataFimController,
                  titulo: 'Data Fim',
                ),
              ],
            ),
            Center(
              child: _buscando
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )
                  : ButtonPrimaryInforvix(
                      titulo: 'Consultar Marcações',
                      funcao: buscarMarcacoes,
                    ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: marcacoes.length,
                itemBuilder: (context, index) {
                  return ComprovanteWidget(marcacao: marcacoes[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
