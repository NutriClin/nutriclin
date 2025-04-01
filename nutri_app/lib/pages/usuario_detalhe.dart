import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/controllers/usuario_controller.dart';
import 'package:toastification/toastification.dart';

class UsuarioDetalhe extends StatefulWidget {
  final String? idUsuario;
  const UsuarioDetalhe({super.key, this.idUsuario});

  @override
  _UsuarioDetalheState createState() => _UsuarioDetalheState();
}

class _UsuarioDetalheState extends State<UsuarioDetalhe> {
  final UsuarioController _usuarioController = UsuarioController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String _tipoUsuario = 'Aluno';
  bool _ativo = true;
  late bool _isEditMode;
  late bool _isAtivo = true;
  bool isLoading = false;

  void _mostrarToast(String mensagem, {bool isError = true}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
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
      icon: Icon(isError ? Icons.error : Icons.check_circle),
      primaryColor: isError ? Colors.red : Colors.green,
      backgroundColor: isError ? Colors.red[50] : Colors.green[50],
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
  void initState() {
    super.initState();
    _isEditMode = widget.idUsuario != null && widget.idUsuario!.isNotEmpty;
    if (_isEditMode) {
      _buscarUsuario(widget.idUsuario!);
    }
  }

  Future<void> _buscarUsuario(String id) async {
    setState(() {
      isLoading = true;
    });

    try {
      var dados = await _usuarioController.buscarUsuario(id);

      if (dados != null) {
        setState(() {
          nomeController.text = dados['nome'] ?? '';
          emailController.text = dados['email'] ?? '';
          _tipoUsuario = dados['tipo_usuario'] ?? 'Aluno';
          _ativo = dados['ativo'] ?? true;
          _isAtivo = dados['ativo'] ?? true;
        });
      } else {
        _mostrarToast('Falha ao carregar dados do usuário');
      }
    } catch (e) {
      _mostrarToast('Erro ao buscar usuário: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _nomeError = false;
  bool _emailError = false;
  String _nomeErrorMessage = '';
  String _emailErrorMessage = '';

  // Método para validar todos os campos
  bool _validarCampos() {
    bool valido = true;
    String nome = nomeController.text.trim();
    String email = emailController.text.trim();

    if (nome.isEmpty) {
      _nomeError = true;
      _nomeErrorMessage = 'Nome é obrigatório';
      valido = false;
    } else if (nome.length < 3) {
      _nomeError = true;
      _nomeErrorMessage = 'Nome deve conter pelo menos 3 caracteres';
      valido = false;
    } else if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(nome)) {
      _nomeError = true;
      _nomeErrorMessage = 'Nome deve conter apenas letras e espaços';
      valido = false;
    } else {
      _nomeError = false;
      _nomeErrorMessage = '';
    }

    if (email.isEmpty) {
      _emailError = true;
      _emailErrorMessage = 'Email é obrigatório';
      valido = false;
    } else if (!email.endsWith('@camporeal.edu.br')) {
      _emailError = true;
      _emailErrorMessage = 'Deve ser email da instituição Campo Real';
      valido = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = true;
      _emailErrorMessage = 'Email inválido';
      valido = false;
    } else {
      _emailError = false;
      _emailErrorMessage = '';
    }

    setState(() {});

    return valido;
  }

  Future<void> _salvarUsuario() async {
    if (!_validarCampos()) {
      _mostrarToast('Por favor, verifique o formulário!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String resultado = await _usuarioController.salvarUsuario(
        idUsuario: widget.idUsuario,
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        tipoUsuario: _tipoUsuario,
        ativo: _ativo,
      );

      if (resultado.contains('sucesso')) {
        _mostrarToast(resultado, isError: false);
        Navigator.pop(context);
      } else {
        _mostrarToast(resultado);
      }
    } catch (e) {
      _mostrarToast('Erro ao salvar usuário: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _ativarDesativarUsuario() async {
    setState(() {
      isLoading = true;
    });

    try {
      String resultado = await _usuarioController.ativarDesativarUsuario(
        idUsuario: widget.idUsuario,
        ativo: !_ativo,
      );

      if (resultado.contains('sucesso')) {
        setState(() {
          _isAtivo = !_isAtivo;
        });
        _mostrarToast(resultado, isError: false);
        Navigator.pop(context);
      } else {
        _mostrarToast(resultado);
      }
    } catch (e) {
      _mostrarToast('Erro ao alterar status do usuário: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _mostrarAlterarSenhaModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              CustomCard(
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Redefinir senha',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Tem certeza que deseja redefinir a senha deste usuário?',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          text: 'Voltar',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.white,
                          textColor: Colors.black,
                          boxShadowColor: Colors.black,
                        ),
                        const SizedBox(width: 5),
                        CustomButton(
                          text: 'Confirmar',
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              String resultado = await _usuarioController
                                  .enviarRedefinicaoSenha(widget.idUsuario!);

                              if (resultado.contains('sucesso')) {
                                _mostrarToast(resultado, isError: false);
                              } else {
                                _mostrarToast(resultado);
                              }
                            } catch (e) {
                              _mostrarToast(
                                  'Erro ao redefinir senha: ${e.toString()}');
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          appBar: CustomAppBar(
              title: _isEditMode ? 'Editar Usuário' : 'Cadastro de Usuário'),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CustomCard(
                            width: cardWidth,
                            child: Column(
                              children: [
                                CustomInput(
                                  label: 'Nome:',
                                  width: 60,
                                  controller: nomeController,
                                  enabled: _isAtivo,
                                  error: _nomeError,
                                  errorMessage: _nomeErrorMessage,
                                  obrigatorio: true,
                                  onChanged: (value) {
                                    if (_nomeError) {
                                      _validarCampos();
                                    }
                                  },
                                ),
                                const SizedBox(height: 15),
                                CustomInput(
                                  label: 'Email:',
                                  width: 60,
                                  controller: emailController,
                                  enabled: _isAtivo,
                                  error: _emailError,
                                  errorMessage: _emailErrorMessage,
                                  obrigatorio: true,
                                  onChanged: (value) {
                                    if (_emailError) {
                                      _validarCampos();
                                    }
                                  },
                                ),
                                !_isEditMode
                                    ? SizedBox.shrink()
                                    : const SizedBox(height: 15),
                                !_isEditMode
                                    ? SizedBox.shrink()
                                    : CustomButton(
                                        text: 'Redefinir Senha',
                                        onPressed: _mostrarAlterarSenhaModal,
                                      ),
                                const SizedBox(height: 15),
                                CustomDropdown(
                                  label: 'Cargo:',
                                  value: _tipoUsuario,
                                  items: ['Aluno', 'Professor', 'Coordenador'],
                                  enabled: _isAtivo,
                                  onChanged: (valor) {
                                    setState(() {
                                      _tipoUsuario = valor!;
                                    });
                                  },
                                  width: 60,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    CustomButton(
                                      text: _isAtivo ? 'Desativar' : 'Ativar',
                                      onPressed: _ativarDesativarUsuario,
                                      color: Colors.white,
                                      textColor: _isAtivo
                                          ? Color(0xFFFF3B30)
                                          : Color(0xFF34C759),
                                      boxShadowColor: Colors.black,
                                    ),
                                    Expanded(child: SizedBox.shrink()),
                                    CustomButton(
                                      text: 'Voltar',
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      boxShadowColor: Colors.black,
                                    ),
                                    SizedBox(width: 8),
                                    CustomButton(
                                      text: 'Salvar',
                                      onPressed: _salvarUsuario,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (isLoading)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
