import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_input_password.dart';
import 'package:nutri_app/pages/home.dart';
import 'package:nutri_app/services/auth_service.dart';
import 'package:nutri_app/services/preferences_service.dart';
import 'package:nutri_app/components/toast_util.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;
  bool _emailError = false;
  bool _senhaError = false;
  String _emailErrorMessage = '';
  String _senhaErrorMessage = '';

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (!_validarCampos(email, senha)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usuario = await _authService.login(email, senha);

      if (usuario != null) {
        await PreferencesService.saveUserType(usuario['tipo_usuario']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(tipoUsuario: usuario['tipo_usuario']),
          ),
        );
      } else {
        ToastUtil.showToast(
          context: context,
          message: "Email ou senha inválidos",
          isError: true,
        );

        _emailError = true;
        _senhaError = true;
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: "Erro ao realizar login: ${e.toString()}",
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validarCampos(String email, String senha) {
    bool valido = true;

    if (email.isEmpty) {
      _emailError = true;
      _emailErrorMessage = 'Email é obrigatório';
      valido = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = true;
      _emailErrorMessage = 'Email inválido';
      valido = false;
    } else {
      _emailError = false;
      _emailErrorMessage = '';
    }

    if (senha.isEmpty) {
      _senhaError = true;
      _senhaErrorMessage = 'Senha é obrigatória';
      valido = false;
    } else {
      _senhaError = false;
      _senhaErrorMessage = '';
    }

    setState(() {});

    return valido;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    // Cálculos responsivos
    final logoSize = isSmallScreen ? screenWidth * 0.5 : screenWidth * 0.3;
    final cardWidth = isSmallScreen ? screenWidth * 0.9 : screenWidth * 0.4;
    final cardPadding = isSmallScreen ? 20.0 : 30.0;
    final verticalSpacing = isSmallScreen ? 20.0 : 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 32.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo responsiva
                      SizedBox(
                        width: logoSize,
                        height: logoSize,
                        child: SvgPicture.asset(
                          'assets/imagens/campologo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: verticalSpacing),

                      // Card de Login responsivo
                      CustomCard(
                        width: cardWidth,
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomInput(
                                label: 'Email',
                                controller: _emailController,
                                error: _emailError,
                                errorMessage: _emailErrorMessage,
                                onChanged: (value) {
                                  if (_emailError) {
                                    _validarCampos(
                                      _emailController.text.trim(),
                                      _senhaController.text.trim(),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: verticalSpacing * 0.75),
                              CustomInputPassword(
                                label: 'Senha',
                                controller: _senhaController,
                                error: _senhaError,
                                errorMessage: _senhaErrorMessage,
                                onChanged: (value) {
                                  if (_senhaError) {
                                    _validarCampos(
                                      _emailController.text.trim(),
                                      _senhaController.text.trim(),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: verticalSpacing),
                              CustomButton(
                                text: "Entrar",
                                onPressed: _login,
                                isLoading: _isLoading,
                                enabled: !_isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
