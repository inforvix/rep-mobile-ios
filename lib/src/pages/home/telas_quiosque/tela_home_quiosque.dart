// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/common/funcoes_globais.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/repositories/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/camera_dialog.dart';
import 'package:rep_p_mobile/src/ui/widgets/comprovante.dart';
import 'package:rep_p_mobile/src/ui/widgets/digital_clock.dart';
import 'package:rep_p_mobile/src/ui/widgets/edit.dart';
import 'package:rep_p_mobile/src/ui/widgets/oval_clipper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TelaRegistrarMarcacaoQuiosque extends StatefulWidget {
  const TelaRegistrarMarcacaoQuiosque({super.key});

  @override
  State<TelaRegistrarMarcacaoQuiosque> createState() =>
      _TelaRegistrarMarcacaoQuiosqueState();
}

class _TelaRegistrarMarcacaoQuiosqueState
    extends State<TelaRegistrarMarcacaoQuiosque> {
  List<GetMarcacoesModel> marcacoes = [];
  final FocusNode myFocusNode = FocusNode();

  final TextEditingController cpfController = TextEditingController();
  final TextEditingController chaveController = TextEditingController();

  bool _enviando = false;

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  void _mostrarSucesso(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(message: mensagem),
    );
  }

  Future<void> _abrirCameraDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 400,
            width: 300,
            child: CameraDialog(
              onFotoCapturada: (foto) async {
                Navigator.of(context).pop(); // Fecha o dialog
                await _enviarFoto(foto); // Envia a foto
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _enviarFoto(File foto) async {
    setState(() => _enviando = true);

    const String url = '${DadosGlobais.baseUrl}/marcacao/facial';

    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(foto.path, filename: 'foto.jpg'),
      });

      final response = await Dio().post(url,
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer ${DadosGlobais.token}',
          }));

      final responseBody = response.data;

      setState(() {
        marcacoes.insert(
          0,
          GetMarcacoesModel(
            funcionario: responseBody['funcionario'] ?? '',
            data: responseBody['data'] ?? '',
            hora: responseBody['hora'] ?? '',
          ),
        );
      });
      _mostrarSucesso('Marcação realizada com sucesso');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        _mostrarErro(data['message'] as String);
      } else {
        _mostrarErro('Usuário não identificado');
      }
    } catch (e) {
      _mostrarErro('Falha ao realizar marcação');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    cpfController.dispose();
    chaveController.dispose();
    super.dispose();
  }

  Future<void> _registrarMarcacaoCpfSenha(BuildContext dialogContext) async {
    try {
      await MarcacaoRepository().registrarMarcacaoCpfSenha(
          cpf: FuncoesGlobais.somenteNumeros(cpfController.text),
          senha: chaveController.text);
    } on ApiException catch (e) {
      _mostrarErro(e.message);
      return;
    } catch (_) {
      _mostrarErro('Ocorreu um erro ao registrar marcação');
      return;
    }

    _mostrarSucesso('Marcação registrada com sucesso');

    setState(() {
      marcacoes.insert(
        0,
        GetMarcacoesModel(
          funcionario: nomeFuncionarioModoQuiosque,
          data: dataModoQuiosque,
          hora: horaModoQuiosque,
        ),
      );
    });

    cpfController.clear();
    chaveController.clear();

    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            children: [
              Text(
                'Registrar Marcação',
                style: Fonts.textStyleTituloEdit,
              ),
              SizedBox(height: 20),
              EditInforvixCPF(
                controller: cpfController,
                titulo: 'CPF',
                hint: 'informe seu CPF',
              ),
              SizedBox(height: 20),
              EditInforvixSenha(
                controller: chaveController,
                titulo: 'Senha',
                hint: 'informe sua senha',
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonIconInforvix(
                      color: Colors.redAccent,
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                      funcao: () async {
                        cpfController.clear();
                        chaveController.clear();
                        Navigator.of(dialogContext).pop();
                      }),
                  ButtonIconInforvix(
                      color: PaletaCores.backgroundBlue,
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 35,
                      ),
                      funcao: () => _registrarMarcacaoCpfSenha(dialogContext)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_enviando) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      color: PaletaCores.backgroundWhite,
      child: Column(
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper2(),
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PaletaCores.backgroundBlue,
              ),
              child: Stack(children: [
                Positioned(
                  top: 12,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/logo_inforvix.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 10,
                    ),
                    AnalogClockInforvix(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonIconInforvix(
                          icon: Icon(
                            Icons.keyboard,
                            size: 50,
                          ),
                          funcao: () async {
                            _dialogBuilder(context);
                          },
                        ),
                        SizedBox(width: 30),
                        ButtonIconInforvix(
                          icon: Icon(
                            Icons.face,
                            size: 50,
                          ),
                          funcao: () async {
                            _abrirCameraDialog(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ]),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: marcacoes.length,
              itemBuilder: (context, index) {
                return ComprovanteWidgetQuiosque(
                  nomeFuncionario: marcacoes[index].funcionario,
                  titulo: marcacoes[index].hora ?? '',
                  subTitulo: marcacoes[index].data ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
