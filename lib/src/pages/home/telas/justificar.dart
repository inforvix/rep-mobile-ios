import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inforvix_ux/inforvix_ux.dart' as externo;
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/repositories/arquivos_repository.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/data_edit.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class JustificarPage extends StatefulWidget {
  const JustificarPage({super.key});

  @override
  State<JustificarPage> createState() => _JustificarPageState();
}

class _JustificarPageState extends State<JustificarPage> {
  static const int _tamanhoMaximoBytes = 10 * 1024 * 1024; // 10 MB

  final TextEditingController _tipoDocumentoController =
      TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _dataDocumentoController =
      TextEditingController();

  DateTime? _dataDocumento;
  PlatformFile? _arquivo;
  bool _enviando = false;

  @override
  void dispose() {
    _tipoDocumentoController.dispose();
    _observacaoController.dispose();
    _dataDocumentoController.dispose();
    super.dispose();
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  Future<void> _selecionarArquivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) return;

    final arquivo = resultado.files.first;

    if (arquivo.size > _tamanhoMaximoBytes) {
      _mostrarErro('O arquivo deve ter no máximo 10 MB');
      return;
    }

    setState(() => _arquivo = arquivo);
  }

  /// Monta o nome com que o arquivo será salvo no servidor:
  /// tipo do documento + CPF + data do documento + timestamp (evita
  /// sobrescrever arquivos com o mesmo nome).
  String _montarNomeArquivo() {
    final tipo = _tipoDocumentoController.text.trim();
    final data = _dataDocumento!;
    final dataFormatada = '${data.day.toString().padLeft(2, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-${data.year}';
    final nome =
        '${tipo}_${DadosGlobais.cpfLogin}_${dataFormatada}_${DateTime.now().millisecondsSinceEpoch}';
    return nome.replaceAll(RegExp(r'[^\w\-]'), '_');
  }

  /// Data do documento no formato aceito pelo backend (yyyy-MM-dd).
  String _dataDocumentoIso() {
    final data = _dataDocumento!;
    return '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  Future<void> _enviarDocumento() async {
    if (_enviando) return;

    if (_tipoDocumentoController.text.trim().isEmpty ||
        _dataDocumento == null) {
      _mostrarErro('Preencha o tipo e a data do documento.');
      return;
    }

    if (_arquivo == null) {
      _mostrarErro('Anexe um arquivo (imagem ou PDF).');
      return;
    }

    setState(() => _enviando = true);

    try {
      await ArquivosRepository().enviarDocumento(
        arquivo: _arquivo!,
        nomeArquivo: _montarNomeArquivo(),
        tipo: _tipoDocumentoController.text.trim(),
        data: _dataDocumentoIso(),
        observacao: _observacaoController.text.trim(),
      );

      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Documento enviado com sucesso!',
        ),
      );

      // Volta para a lista sinalizando que houve novo envio (para atualizar).
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Falha ao enviar o documento. Tente novamente.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCores.backgroundWhite,
      appBar: AppBar(
        backgroundColor: PaletaCores.backgroundBlue,
        foregroundColor: Colors.white,
        title: const Text('Registrar Documento'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              externo.EditInforvix(
                  width: MediaQuery.sizeOf(context).width - 40,
                  controller: _tipoDocumentoController,
                  title: 'Tipo de Documento *',
                  hintText: 'Ex: Atestado, Declaração, etc.'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DatePickerField(
                      dataController: _dataDocumentoController,
                      label: 'Data do Documento *',
                      onDataSelecionada: (data) {
                        _dataDocumento = data;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: externo.EditMemoInforvix(
                  title: 'Observação',
                  hintText: 'Ex: Atestado de 2 dias',
                  controller: _observacaoController,
                ),
              ),
              const SizedBox(height: 20),
              ButtonPrimaryInforvix(
                titulo:
                    _arquivo == null ? 'Escolher Arquivo *' : 'Trocar Arquivo',
                funcao: _selecionarArquivo,
              ),
              if (_arquivo != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_file,
                          color: PaletaCores.backgroundBlue, size: 20),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _arquivo!.name,
                          style:
                              Fonts.textStyleTituloEdit.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _arquivo = null),
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Remover arquivo',
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              _enviando
                  ? const CircularProgressIndicator()
                  : ButtonPrimaryInforvix(
                      titulo: 'Enviar Documento',
                      funcao: _enviarDocumento,
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
