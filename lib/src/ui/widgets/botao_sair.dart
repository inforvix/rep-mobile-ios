// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/pages/login_page.dart';
import 'package:rep_p_mobile/src/service/credenciais_service.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';

/// Botão de sair do cabeçalho azul das telas principais (individual e
/// quiosque). Pede confirmação, limpa a sessão e volta para o login
/// descartando a pilha de navegação, para o botão "voltar" do aparelho não
/// devolver o usuário a uma tela já deslogada.
class BotaoSairInforvix extends StatelessWidget {
  const BotaoSairInforvix({super.key});

  Future<void> _confirmarSaida(BuildContext context) async {
    final bool sair = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text('Sair da conta', style: Fonts.textStyleTituloEdit),
              content: Text('Deseja encerrar a sessão neste aparelho?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    'Sair',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!sair) return;

    await CredenciaisService.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sair',
      child: Material(
        color: PaletaCores.backgroundWhiteSolid,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _confirmarSaida(context),
          child: Container(
            height: 58,
            width: 58,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  color: PaletaCores.backgroundBlue,
                  size: 26,
                ),
                SizedBox(height: 2),
                Text(
                  'Sair',
                  style: TextStyle(
                    color: PaletaCores.backgroundBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
