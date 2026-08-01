import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/model/documento.dart';
import 'package:rep_p_mobile/src/repositories/arquivos_repository.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/widgets/documento_card.dart';
import 'package:rep_p_mobile/src/ui/widgets/mensagem_central.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Documentos que a EMPRESA enviou para o funcionário logado
/// (tabela Documentos_empresa). Tocar em um documento abre o arquivo.
class DocumentosEmp extends StatefulWidget {
  const DocumentosEmp({super.key});

  @override
  State<DocumentosEmp> createState() => _DocumentosEmpState();
}

class _DocumentosEmpState extends State<DocumentosEmp> {
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
      final documentos =
          await ArquivosRepository().listarDocumentosRecebidos();
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

  /// Abre o arquivo do documento no navegador/visualizador.
  Future<void> _abrirArquivo(DocumentoModel doc) async {
    if (doc.id == null) return;

    final url = ArquivosRepository()
        .urlAbrirDocumento(origem: 'empresa', id: doc.id!);

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
      backgroundColor: PaletaCores.backgroundWhite,
      appBar: AppBar(
        backgroundColor: PaletaCores.backgroundBlue,
        foregroundColor: Colors.white,
        title: const Text('Documentos da Empresa'),
        automaticallyImplyLeading: false,
      ),
      body: _buildConteudo(),
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
        texto: 'A empresa ainda não enviou nenhum documento para você.',
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
            rotuloEnvio: 'Recebido em',
            onTap: () => _abrirArquivo(doc),
          );
        },
      ),
    );
  }
}
