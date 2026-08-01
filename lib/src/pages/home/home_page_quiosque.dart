// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/pages/home/telas_quiosque/tela_home_quiosque.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePageQuiosque extends StatefulWidget {
  const HomePageQuiosque({super.key});

  @override
  State<HomePageQuiosque> createState() => _HomePageQuiosqueState();
}

class _HomePageQuiosqueState extends State<HomePageQuiosque> {
  int _currentIndex = 0;

  final List<Widget> telas = [
    TelaRegistrarMarcacaoQuiosque(),
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
            icon: Icon(Icons.fingerprint),
            title: Text("Principal"),
            selectedColor: PaletaCores.backgroundBlue,
          ),
        ],
      ),
      body: telas[_currentIndex],
    );
  }
}
