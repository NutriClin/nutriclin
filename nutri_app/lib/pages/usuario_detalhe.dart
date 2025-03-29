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
  final TextEditingController senhaController = TextEditingController();
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
    setState(() {
      isLoading = true;
    });

    String resultado = await _usuarioController.salvarUsuario(
      idUsuario: widget.idUsuario,
      nome: nomeController.text,
      email: emailController.text,
      tipoUsuario: _tipoUsuario,
      senha: senhaController.text,
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
                              width: 80,
                              controller: nomeController,
                              enabled: _isAtivo,
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              label: 'Email:',
                              width: 80,
                              controller: emailController,
                              enabled: _isAtivo,
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              label: 'Senha:',
                              width: 80,
                              controller: senhaController,
                              obscureText: true,
                              enabled: _isAtivo,
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
                              width: 80,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  text: _isAtivo ? 'Desativar' : 'Ativar',
                                  onPressed: _ativarDesativarUsuario,
                                  color: Colors.white,
                                  textColor: _isAtivo
                                      ? Color(0xFFFF3B30)
                                      : Color(0xFFF34C759),
                                  boxShadowColor: Colors.black,
                                  isLoading: isLoading,
                                ),
                                Row(
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
                                    const SizedBox(width: 10),
                                    CustomButton(
                                      text: 'Salvar',
                                      onPressed: _salvarUsuario,
                                      isLoading: isLoading,
                                    ),
                                  ],
                                ),
                              ],
                            )
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
