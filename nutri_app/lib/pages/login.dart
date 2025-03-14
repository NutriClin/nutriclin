import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_input_password.dart';
import 'package:nutri_app/pages/home.dart';
import 'package:nutri_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarMensagem("Por favor, preencha todos os campos!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    print('Iniciando tentativa de login');
    Map<String, dynamic>? usuario = await _authService.login(email, senha);
    print('Resultado do login: $usuario');

    setState(() {
      isLoading = false;
    });

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(tipoUsuario: usuario['tipo_usuario']),
        ),
      );
    } else {
      _mostrarMensagem("Erro ao fazer login. Verifique suas credenciais.");
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth =
        screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.4;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: SvgPicture.asset(
                          'assets/imagens/campologo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card de Login
                      CustomCard(
                        width: cardWidth,
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Email:',
                              width: 50,
                              controller:
                                  emailController,
                            ),
                            const SizedBox(height: 15),
                            CustomInputPassword(
                              label: 'Senha:',
                              width: 50,
                              controller: senhaController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 15),
                            CustomButton(
                              text: isLoading ? "Entrando..." : "Entrar",
                              onPressed: isLoading
                                  ? () {}
                                  : _login,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
