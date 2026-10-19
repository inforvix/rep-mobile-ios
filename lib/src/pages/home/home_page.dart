// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/pages/home/telas/consulta_marcacoes.dart';
import 'package:rep_p_mobile/src/pages/home/telas/documentos.dart';
import 'package:rep_p_mobile/src/pages/home/telas/documentos_emp.dart';
import 'package:rep_p_mobile/src/pages/home/telas/solicitar_marcacao.dart';
import 'package:rep_p_mobile/src/pages/home/telas/tela_home.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

/// As telas de documentos dependem das rotas /files, que ainda não estão
/// publicadas no backend de produção. Enquanto isso, ficam ocultas no iOS
/// para o app não expor abas que sempre falham.
final bool mostrarDocumentos =
    kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;

  final List<Widget> telas = [
    SolicitarInclusaoMarcacao(),
    ConsultaMarcacoesTelas(),
    TelaRegistrarMarcacao(),
    if (mostrarDocumentos) DocumentosPage(),
    if (mostrarDocumentos) DocumentosEmp(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCores.backgroundWhite,
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.wysiwyg),
            title: Text("Solicitar"),
            selectedColor: PaletaCores.backgroundBlue,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Buscar"),
            selectedColor: PaletaCores.backgroundBlue,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.fingerprint),
            title: Text("Principal"),
            selectedColor: PaletaCores.backgroundBlue,
          ),
          if (mostrarDocumentos)
            SalomonBottomBarItem(
              icon: Icon(Icons.file_copy_outlined),
              title: Text("Arquivos"),
              selectedColor: PaletaCores.backgroundBlue,
            ),
          if (mostrarDocumentos)
            SalomonBottomBarItem(
              icon: Icon(Icons.campaign_outlined),
              title: Text("Arq. Emp."),
              selectedColor: PaletaCores.backgroundBlue,
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: telas,
      ),
    );
  }
}
