// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:rep_p_mobile/src/common/dados.dart';
import 'package:rep_p_mobile/src/common/funcoes_globais.dart';
import 'package:rep_p_mobile/src/pages/home/home_page_quiosque.dart';
import 'package:rep_p_mobile/src/repositories/empresa_repository.dart';
import 'package:rep_p_mobile/src/repositories/funcionarios_repository.dart';
import 'package:rep_p_mobile/src/pages/home/home_page.dart';
import 'package:rep_p_mobile/src/service/api_exception.dart';
import 'package:rep_p_mobile/src/ui/cores.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';
import 'package:rep_p_mobile/src/ui/widgets/button.dart';
import 'package:rep_p_mobile/src/ui/widgets/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _entrando = false;

  @override
  void initState() {
    super.initState();

    _carregarLoginSalvo();
    _carregarModoOperacao();
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _carregarLoginSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    String? cpfSalvo = prefs.getString('login');
    if (cpfSalvo != null && mounted) {
      setState(() {
        loginController.text = cpfSalvo;
      });
    }
  }

  Future<void> _carregarModoOperacao() async {
    final prefs = await SharedPreferences.getInstance();
    DadosGlobais.modoQuiosque = prefs.getBool('modoOperacao') ?? false;

    if (mounted) setState(() {});
  }

  Future<void> _salvarLogin(String login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', login);
  }

  Future<void> _salvarModoOperacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOperacao', DadosGlobais.modoQuiosque);
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: mensagem),
    );
  }

  Future<void> _fazerLogin() async {
    if (_entrando) return;

    if (loginController.text.isEmpty || passwordController.text.isEmpty) {
      _mostrarErro('Preencha todos os campos');
      return;
    }

    setState(() => _entrando = true);
    DadosGlobais.token = '';

    try {
      if (DadosGlobais.modoQuiosque) {
        await EmpresaRepository().login(
          login: FuncoesGlobais.somenteNumeros(loginController.text),
          senha: passwordController.text,
        );
      } else {
        await FuncionarioRepository().login(
          cpf: FuncoesGlobais.somenteNumeros(loginController.text),
          senha: passwordController.text,
        );
      }
    } on ApiException catch (e) {
      _mostrarErro(e.message);
      return;
    } catch (_) {
      _mostrarErro('Não foi possível conectar ao servidor');
      return;
    } finally {
      if (mounted) setState(() => _entrando = false);
    }

    if (DadosGlobais.token == '') {
      _mostrarErro('Usuário ou senha inválidos');
      return;
    }

    await _salvarLogin(loginController.text);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DadosGlobais.modoQuiosque
              ? const HomePageQuiosque()
              : const HomePage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 230,
              color: PaletaCores.backgroundBlue,
              child: Image.asset(
                'assets/images/logo_pontovix.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 180),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 180,
                decoration: BoxDecoration(
                  color: PaletaCores.backgroundWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                // Scroll evita overflow em telas baixas ou com o teclado
                // aberto; IntrinsicHeight preserva o Spacer em telas altas.
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 180,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          DadosGlobais.modoQuiosque
                              ? EditInforvixCNPJ(
                                  controller: loginController,
                                  titulo: 'CNPJ',
                                  hint: 'Informe o CNPJ',
                                )
                              : EditInforvixCPF(
                                  controller: loginController,
                                  titulo: 'CPF',
                                  hint: 'Informe seu CPF',
                                ),
                          SizedBox(height: 40),
                          EditInforvixSenha(
                            controller: passwordController,
                            titulo: 'Senha',
                            hint: 'Informe sua senha',
                            onFieldSubmitted: _fazerLogin,
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.075),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Modo Quiosque',
                                      style: Fonts.textStyleTituloEdit,
                                    ),
                                    SizedBox(height: 05),
                                    Switch(
                                      value: DadosGlobais.modoQuiosque,
                                      activeThumbColor:
                                          PaletaCores.backgroundBlue,
                                      padding: EdgeInsets.all(1),
                                      onChanged: (bool valor) async {
                                        setState(() {
                                          DadosGlobais.modoQuiosque = valor;
                                        });
                                        loginController.clear();
                                        passwordController.clear();
                                        await _salvarModoOperacao();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          _entrando
                              ? const CircularProgressIndicator()
                              : ButtonPrimaryInforvix(
                                  titulo: 'Entrar',
                                  funcao: _fazerLogin,
                                ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Spacer(),
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: PaletaCores.backgroundWhiteSolid,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                        'assets/images/logo_inforvix.png'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
