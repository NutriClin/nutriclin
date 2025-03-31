import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/controllers/usuario_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.idUsuario != null && widget.idUsuario!.isNotEmpty;
    if (_isEditMode) {
      _buscarUsuario(widget.idUsuario!);
    }
  }

  Future<void> _buscarUsuario(String id) async {
    var dados = await _usuarioController.buscarUsuario(id);
    if (dados != null) {
      setState(() {
        nomeController.text = dados['nome'] ?? '';
        emailController.text = dados['email'] ?? '';
        _tipoUsuario = dados['tipo_usuario'] ?? 'Aluno';
        _ativo = dados['ativo'] ?? true;
        _isAtivo = dados['ativo'] ?? true;
      });
    }
  }

Future<void> _salvarUsuario() async {
  String email = emailController.text.trim();

  if (!email.endsWith('@camporeal.edu.br')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deve ser usado email da instituição Campo Real.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  String resultado = await _usuarioController.salvarUsuario(
    idUsuario: widget.idUsuario,
    nome: nomeController.text,
    email: email,
    tipoUsuario: _tipoUsuario,
    ativo: _ativo,
  );

  setState(() {
    isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(resultado)),
  );
}


  Future<void> _ativarDesativarUsuario() async {
    setState(() {
      isLoading = true;
    });

    String resultado = await _usuarioController.ativarDesativarUsuario(
      idUsuario: widget.idUsuario,
      ativo: !_ativo,
    );

    setState(() {
      isLoading = false;
    });

    if (resultado.contains('sucesso')) {
      setState(() {
        _isAtivo = !_isAtivo;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado)),
    );
  }

  void _mostrarAlterarSenhaModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40),
          backgroundColor: Colors.transparent,
          child: CustomCard(
            width: MediaQuery.of(context).size.width * 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
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
                        String resultado = await _usuarioController
                            .enviarRedefinicaoSenha(widget.idUsuario!);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(resultado)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
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

    return Scaffold(
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
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              label: 'Email:',
                              width: 60,
                              controller: emailController,
                              enabled: _isAtivo,
                            ),
                            !_isEditMode
                                ? SizedBox.shrink()
                                : const SizedBox(height: 15),
                            !_isEditMode
                                ? SizedBox.shrink()
                                : CustomButton(
                                    text: 'Redefinir Senha',
                                    onPressed: _mostrarAlterarSenhaModal,
                                    isLoading: isLoading,
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
                                  isLoading: isLoading,
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
                                  isLoading: isLoading,
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
    );
  }
}
