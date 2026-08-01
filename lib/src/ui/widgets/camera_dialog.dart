import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rep_p_mobile/src/ui/face_mask.dart';

/// Dialog que abre a câmera frontal, captura a foto automaticamente após
/// 3 segundos e devolve o arquivo via [onFotoCapturada].
class CameraDialog extends StatefulWidget {
  final Function(File foto) onFotoCapturada;

  const CameraDialog({super.key, required this.onFotoCapturada});

  @override
  State<CameraDialog> createState() => _CameraDialogState();
}

class _CameraDialogState extends State<CameraDialog>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCapturing = false;
  bool _showProcessing = false;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();

      await _initializeControllerFuture;

      // Marca como pronta (ativa fade-in do preview)
      if (mounted) {
        setState(() {
          _cameraReady = true;
        });
      }

      Future.delayed(const Duration(seconds: 3), () async {
        await _tirarFoto();
      });
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _tirarFoto() async {
    if (_isCapturing ||
        !mounted ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final foto = await _controller!.takePicture();

      final dir = await getTemporaryDirectory();
      final filePath = path.join(
          dir.path, 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final savedFile = await File(foto.path).copy(filePath);

      if (!mounted) return;
      setState(() {
        _showProcessing = true;
      });

      // Chama callback para enviar a foto
      widget.onFotoCapturada(savedFile);

      // Mantém a câmera visível por 3 segundos a mais
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      debugPrint('Erro ao capturar foto: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: !_cameraReady
          ? Container(
              key: const ValueKey('loading'),
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Inicializando câmera...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: Colors.grey),
                  ],
                ),
              ),
            )
          : Stack(
              key: const ValueKey('camera'),
              alignment: Alignment.center,
              children: [
                // Suave fade-in no CameraPreview
                AnimatedOpacity(
                  opacity: _cameraReady ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CameraPreview(_controller!),
                  ),
                ),

                // Máscara oval de rosto
                const FaceCircleMask(
                  width: 300,
                  height: 400,
                  circleRadius: 100,
                ),

                // Indicadores de captura/processamento
                if (_isCapturing || _showProcessing)
                  Positioned(
                    bottom: 16,
                    child: Column(
                      children: [
                        _showProcessing
                            ? const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 40)
                            : const CircularProgressIndicator(
                                color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          _showProcessing ? 'Processando...' : 'Capturando...',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'Aguarde...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
              ],
            ),
    );
  }
}
