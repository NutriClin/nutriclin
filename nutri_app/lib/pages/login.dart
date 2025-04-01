import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_input_password.dart';
import 'package:nutri_app/pages/home.dart';
import 'package:nutri_app/services/auth_service.dart';
import 'package:toastification/toastification.dart';

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
    FocusScope.of(context).unfocus();

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
      _mostrarMensagem("Email ou senha inválidos.");
    }
  }

  void _mostrarMensagem(String mensagem) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      description: Text(mensagem),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: Icon(Icons.error),
      primaryColor: Colors.red,
      backgroundColor: Colors.red[50],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth =
        screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.4;

    return Stack(
      children: [
        Scaffold(
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
                            width: 300,
                            height: 300,
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
                                  controller: emailController,
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
                                  onPressed: isLoading ? () {} : _login,
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
        ),
        if (isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
