import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_drawer.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/controllers/usuario_controller.dart';
import 'package:nutri_app/components/toast_util.dart';

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
  bool _nomeError = false;
  bool _emailError = false;
  String _nomeErrorMessage = '';
  String _emailErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.idUsuario != null && widget.idUsuario!.isNotEmpty;
    if (_isEditMode) {
      _buscarUsuario(widget.idUsuario!);
    }
  }

  Future<void> _buscarUsuario(String id) async {
    setState(() => isLoading = true);

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
        ToastUtil.showToast(
          context: context,
          message: 'Falha ao carregar dados do usuário',
          isError: true,
        );
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao buscar usuário: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

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
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String resultado = await _usuarioController.salvarUsuario(
        idUsuario: widget.idUsuario,
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        tipoUsuario: _tipoUsuario,
        ativo: _ativo,
      );

      if (resultado.contains('sucesso')) {
        ToastUtil.showToast(
          context: context,
          message: resultado,
          isError: false,
        );
        Navigator.pop(context);
      } else {
        ToastUtil.showToast(
          context: context,
          message: resultado,
          isError: true,
        );
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao salvar usuário: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleAtivoStatus(bool newValue) async {
    setState(() => isLoading = true);

    try {
      String resultado = await _usuarioController.ativarDesativarUsuario(
        idUsuario: widget.idUsuario,
        ativo: newValue,
      );

      if (resultado.contains('sucesso')) {
        setState(() {
          _isAtivo = newValue;
          _ativo = newValue;
        });
        ToastUtil.showToast(
          context: context,
          message: resultado,
          isError: false,
        );
      } else {
        ToastUtil.showToast(
          context: context,
          message: resultado,
          isError: true,
        );
        setState(() {
          _isAtivo = !newValue;
          _ativo = !newValue;
        });
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao alterar status do usuário: ${e.toString()}',
        isError: true,
      );
      setState(() {
        _isAtivo = !newValue;
        _ativo = !newValue;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _mostrarAlterarSenhaModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              CustomCard(
                width: MediaQuery.of(context).size.width * 0.9,
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
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Isso vai distribuir o espaço entre os widgets
                      children: [
                        CustomButton(
                          text: 'Cancelar',
                          onPressed: () => Navigator.pop(context),
                          color: Colors.white,
                          textColor: Colors.red,
                          boxShadowColor: Colors.black,
                        ),
                        CustomButton(
                          text: 'Confirmar',
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() => isLoading = true);

                            try {
                              String resultado = await _usuarioController
                                  .enviarRedefinicaoSenha(widget.idUsuario!);

                              ToastUtil.showToast(
                                context: context,
                                message: resultado,
                                isError: !resultado.contains('sucesso'),
                              );
                            } catch (e) {
                              ToastUtil.showToast(
                                context: context,
                                message:
                                    'Erro ao redefinir senha: ${e.toString()}',
                                isError: true,
                              );
                            } finally {
                              setState(() => isLoading = false);
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final cardWidth = screenWidth * 0.95;

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: _isEditMode ? 'Editar Usuário' : 'Cadastro de Usuário',
          ),
          drawer: const CustomDrawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: CustomCard(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Nome:',
                          controller: nomeController,
                          enabled: _isAtivo,
                          error: _nomeError,
                          errorMessage: _nomeErrorMessage,
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_nomeError) _validarCampos();
                          },
                        ),
                        const SizedBox(height: 15),
                        CustomInput(
                          label: 'Email:',
                          controller: emailController,
                          enabled: _isAtivo,
                          error: _emailError,
                          errorMessage: _emailErrorMessage,
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_emailError) _validarCampos();
                          },
                        ),
                        const SizedBox(height: 15),
                        CustomDropdown(
                          label: 'Cargo:',
                          value: _tipoUsuario,
                          items: ['Aluno', 'Professor', 'Coordenador'],
                          enabled: _isAtivo,
                          onChanged: (valor) =>
                              setState(() => _tipoUsuario = valor!),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Text(
                                'Ativo:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Switch(
                                value: _isAtivo,
                                onChanged: _toggleAtivoStatus,
                                activeColor: const Color(0xFF007AFF),
                              ),
                            ],
                          ),
                        ),
                        if (_isEditMode) const SizedBox(height: 15),
                        if (_isEditMode)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CustomButton(
                              text: 'Redefinir Senha',
                              onPressed: _mostrarAlterarSenhaModal,
                              color: Colors.white,
                              textColor: Colors.red,
                              boxShadowColor: Colors.black,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                text: 'Voltar',
                                onPressed: () => Navigator.pop(context),
                                color: Colors.white,
                                textColor: Colors.black,
                                boxShadowColor: Colors.black,
                              ),
                              CustomButton(
                                text: 'Salvar',
                                onPressed: _salvarUsuario,
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
