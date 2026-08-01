import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/model/documento.dart';
import 'package:rep_p_mobile/src/pages/home/telas/justificar.dart';
import 'package:rep_p_mobile/src/repositories/arquivos_repository.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/documento_card.dart';
import 'package:rep_p_mobile/src/ui/widgets/mensagem_central.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Documentos que o funcionário enviou para a empresa (tabela Documentos),
/// com botão para cadastrar um novo. Tocar em um documento abre o arquivo.
class DocumentosPage extends StatefulWidget {
  const DocumentosPage({super.key});

  @override
  State<DocumentosPage> createState() => _DocumentosPageState();
}

class _DocumentosPageState extends State<DocumentosPage> {
  List<DocumentoModel> _documentos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDocumentos();
  }

  Future<void> _carregarDocumentos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final documentos = await ArquivosRepository().listarDocumentos();
      if (!mounted) return;
      setState(() {
        _documentos = documentos;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os documentos.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirCadastro() async {
    final enviou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const JustificarPage()),
    );

    // Se um documento foi enviado, recarrega a lista.
    if (enviou == true) {
      await _carregarDocumentos();
      if (!mounted) return;
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Documento enviado com sucesso!',
        ),
      );
    }
  }

  /// Abre o arquivo do documento no navegador/visualizador.
  Future<void> _abrirArquivo(DocumentoModel doc) async {
    if (doc.id == null) return;

    final url = ArquivosRepository()
        .urlAbrirDocumento(origem: 'funcionario', id: doc.id!);

    final aberto = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!aberto && mounted) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Não foi possível abrir o documento',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PaletaCores.backgroundBlue,
        foregroundColor: Colors.white,
        title: const Text('Meus Documentos'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: PaletaCores.backgroundWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            Center(
              child: ButtonPrimaryInforvix(
                titulo: 'Cadastrar Novo Documento',
                funcao: _abrirCadastro,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildConteudo()),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return MensagemCentral(
        icone: Icons.error_outline,
        texto: _erro!,
        acaoTitulo: 'Tentar novamente',
        acao: _carregarDocumentos,
      );
    }

    if (_documentos.isEmpty) {
      return const MensagemCentral(
        icone: Icons.folder_open,
        texto: 'Você ainda não enviou nenhum documento.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDocumentos,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: _documentos.length,
        itemBuilder: (context, index) {
          final doc = _documentos[index];
          return DocumentoCard(
            documento: doc,
            rotuloEnvio: 'Enviado em',
            onTap: () => _abrirArquivo(doc),
          );
        },
      ),
    );
  }
}
