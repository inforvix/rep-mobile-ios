// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/model/marcacao.dart';
import 'package:rep_p_mobile/src/repositories/marcacao.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/botao_sair.dart';
import 'package:rep_p_mobile/src/ui/widgets/camera_dialog.dart';
import 'package:rep_p_mobile/src/ui/widgets/comprovante.dart';
import 'package:rep_p_mobile/src/ui/widgets/digital_clock.dart';
import 'package:rep_p_mobile/src/ui/widgets/oval_clipper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TelaRegistrarMarcacao extends StatefulWidget {
  const TelaRegistrarMarcacao({super.key});

  @override
  State<TelaRegistrarMarcacao> createState() => _TelaRegistrarMarcacaoState();
}

class _TelaRegistrarMarcacaoState extends State<TelaRegistrarMarcacao> {
  List<GetMarcacoesModel> marcacoes = [];

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

  Future<void> _abrirCameraDialog(
      BuildContext context, Position posicao) async {
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
                await _enviarFoto(foto, posicao); // Envia a foto
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _enviarFoto(File foto, Position posicao) async {
    setState(() => _enviando = true);

    // O backend espera o CONTRATO da empresa nesse parâmetro (é o nome da
    // collection de rostos). Enviar o CPF fazia a busca falhar sempre — por
    // isso o facial só funcionava no modo quiosque, que usa o contrato vindo
    // do token da empresa.
    final String contrato = DadosGlobais.contratoEmpresa;
    if (contrato.isEmpty) {
      setState(() => _enviando = false);
      _mostrarErro(
          'Contrato da empresa não identificado. Faça login novamente.');
      return;
    }

    final String url =
        '${DadosGlobais.baseUrl}/marcacao/facial/individual/$contrato';

    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(foto.path, filename: 'foto.jpg'),
        'latitude': posicao.latitude.toString(),
        'longitude': posicao.longitude.toString(),
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

  Future<void> buscarMarcacoes() async {
    try {
      List<GetMarcacoesModel> resultado =
          await MarcacaoRepository().getMarcacoes(DadosGlobais.cpfLogin);
      if (!mounted) return;
      setState(() {
        marcacoes = resultado;
      });
    } catch (e) {
      _mostrarErro('Erro ao buscar marcações');
    }
  }

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  // No iOS o sistema só exibe o pedido de permissão uma vez: depois de negado
  // (ou com o serviço desligado) o único caminho é o app Ajustes.
  Future<void> _sugerirAjustes(String mensagem) async {
    if (!mounted) return;
    final abrir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Localização necessária'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Abrir Ajustes'),
          ),
        ],
      ),
    );
    if (abrir == true) await Geolocator.openAppSettings();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_isIOS) {
          await _sugerirAjustes('Ative os Serviços de Localização em '
              'Ajustes > Privacidade e Segurança para registrar o ponto.');
        } else {
          _mostrarErro('Serviço de localização está desativado.');
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarErro('Permissão de localização negada.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (_isIOS) {
          await _sugerirAjustes('Permita o acesso à localização em Ajustes > '
              'INFORVIX - Relogio de Ponto > Localização para registrar o ponto.');
        } else {
          _mostrarErro('Permissão negada permanentemente.');
        }
        return null;
      }

      // iOS 14+: com "Localização Precisa" desligada as coordenadas podem
      // errar por quilômetros. Pede a precisa só para esta marcação; se o
      // usuário recusar, segue com a aproximada.
      if (_isIOS &&
          await Geolocator.getLocationAccuracy() ==
              LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
            purposeKey: 'MarcacaoPonto');
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } on TimeoutException {
        // Sem sinal de GPS a tempo (ambiente fechado): usa a última conhecida.
        final ultima = await Geolocator.getLastKnownPosition();
        if (ultima == null) {
          _mostrarErro('Não foi possível obter a localização. Tente novamente.');
        }
        return ultima;
      }
    } catch (e) {
      _mostrarErro('Erro ao obter localização.');
      return null;
    }
  }

  Future<void> _registrarMarcacao() async {
    if (_enviando) return;

    // Ponto facial usa a câmera em Android e iOS; na Web a marcação segue o
    // fluxo padrão por localização. A localização é obtida antes de abrir a
    // câmera para o pedido de permissão não aparecer por cima do diálogo.
    if (DadosGlobais.funcionarioBatePontoFacial && !kIsWeb) {
      setState(() => _enviando = true);
      final position = await _getCurrentLocation();
      if (mounted) setState(() => _enviando = false);
      if (position == null || !mounted) return;
      _abrirCameraDialog(context, position);
      return;
    }

    double latitude = 0.0;
    double longitude = 0.0;

    // Obter o GPS pode levar alguns segundos: mostra o carregamento e evita
    // marcação duplicada por toques repetidos.
    setState(() => _enviando = true);
    try {
      if (!kIsWeb) {
        final position = await _getCurrentLocation();
        if (position == null) return;
        latitude = position.latitude;
        longitude = position.longitude;
      }

      await MarcacaoRepository()
          .registrarMarcacao(latitude: latitude, longitude: longitude);
    } on ApiException catch (e) {
      _mostrarErro(e.message);
      return;
    } catch (_) {
      _mostrarErro('Ocorreu um erro ao registrar marcação');
      return;
    } finally {
      if (mounted) setState(() => _enviando = false);
    }

    _mostrarSucesso('Marcação registrada com sucesso');
    buscarMarcacoes();
  }

  @override
  void initState() {
    super.initState();
    buscarMarcacoes();
  }

  @override
  Widget build(BuildContext context) {
    if (_enviando) {
      return Container(
        color: PaletaCores.backgroundWhite,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: PaletaCores.backgroundWhite,
      child: Column(
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper2(),
            child: Container(
              // Altura extra + padding: o fundo azul continua atrás da status
              // bar, mas o conteúdo fica abaixo de hora/wifi/bateria.
              height: 300 + MediaQuery.of(context).padding.top,
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                Positioned(
                  top: 12,
                  right: 16,
                  child: BotaoSairInforvix(),
                ),
                Column(
                  children: [
                    Container(
                      height: 10,
                    ),
                    AnalogClockInforvix(),
                    SizedBox(height: 5),
                    ButtonSecundaryInforvix(
                      titulo: 'Registrar Marcação',
                      funcao: _registrarMarcacao,
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
                return ComprovanteWidget(marcacao: marcacoes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
