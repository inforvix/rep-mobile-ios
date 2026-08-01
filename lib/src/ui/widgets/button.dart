import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';

class ButtonPrimaryInforvix extends StatelessWidget {
  const ButtonPrimaryInforvix({
    super.key,
    required this.titulo,
    required this.funcao,
  });
  final String titulo;
  final Function funcao;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => funcao(),
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: PaletaCores.backgroundBlue,
        ),
        child: Center(
          child: Text(
            titulo,
            style: Fonts.textStyleBotao,
          ),
        ),
      ),
    );
  }
}

class ButtonSecundaryInforvix extends StatelessWidget {
  const ButtonSecundaryInforvix({
    super.key,
    required this.titulo,
    required this.funcao,
  });
  final String titulo;
  final Future<void> Function() funcao;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => funcao(),
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width * 0.50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: PaletaCores.backgroundWhite,
        ),
        child: Center(
          child: Text(
            titulo,
            style: Fonts.textStyleBotao
                .copyWith(color: PaletaCores.backgroundBlue),
          ),
        ),
      ),
    );
  }
}

class ButtonTertiaryInforvix extends StatelessWidget {
  const ButtonTertiaryInforvix({
    super.key,
    required this.titulo,
    required this.funcao,
  });
  final String titulo;
  final Future<void> Function() funcao;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => funcao(),
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width * 0.50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey//PaletaCores.cinza,
        ),
        child: Center(
          child: Text(
            titulo,
            style: Fonts.textStyleBotao
                .copyWith(color: PaletaCores.textButtonColorWhite),
          ),
        ),
      ),
    );
  }
}

class ButtonIconInforvix extends StatelessWidget {
  const ButtonIconInforvix({
    super.key,
    required this.icon,
    this.color = PaletaCores.backgroundWhiteSolid,
    required this.funcao,
  });
  final Color color;
  final Icon icon;
  final Future<void> Function() funcao;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => funcao(),
      child: Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Center(child: icon),
      ),
    );
  }
}
