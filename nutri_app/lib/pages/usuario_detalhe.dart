import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';

class UsuarioDetalhe extends StatefulWidget {
  final String? idUsuario;
  const UsuarioDetalhe({super.key, this.idUsuario});

  @override
  _UsuarioDetalheState createState() => _UsuarioDetalheState();
}

class _UsuarioDetalheState extends State<UsuarioDetalhe> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  String _tipoUsuario = 'Aluno';
  bool _ativo = true;

  late bool _isEditMode;
  late bool _isAtivo = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.idUsuario != null && widget.idUsuario!.isNotEmpty;
    if (_isEditMode) {
      _buscarUsuario(widget.idUsuario!);
    }
  }

  Future<void> _buscarUsuario(String id) async {
    var doc = await _firestore.collection('usuarios').doc(id).get();
    if (doc.exists) {
      var dados = doc.data()!;
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
    try {
      User? usuarioAtual = _auth.currentUser;
      if (usuarioAtual == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado!')),
        );
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(usuarioAtual.uid).get();
      String tipoAtual = userDoc['tipo_usuario'];

      if (tipoAtual != 'Coordenador') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Apenas Coordenadores podem gerenciar usuários!')),
        );
        return;
      }

      if (widget.idUsuario != null && widget.idUsuario!.isNotEmpty) {
        await _firestore.collection('usuarios').doc(widget.idUsuario).update({
          'nome': nomeController.text,
          'email': emailController.text,
          'tipo_usuario': _tipoUsuario,
          'ativo': _ativo,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário atualizado com sucesso!')),
        );
      } else {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: senhaController.text,
        );

        await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nome': nomeController.text,
          'email': emailController.text,
          'tipo_usuario': _tipoUsuario,
          'ativo': true,
          'data': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );

        nomeController.clear();
        emailController.clear();
        senhaController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar usuário: $e')),
      );
    }
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
                                  onPressed: () {
                                    setState(() {
                                      _isAtivo = !_isAtivo;
                                    });
                                  },
                                  color: Colors.white,
                                  textColor: _isAtivo
                                      ? Color(0xFFFF3B30)
                                      : Color(0xFFF34C759),
                                  boxShadowColor: Colors.black,
                                ),
                                Row(
                                  children: [
                                    CustomButton(
                                      text: 'Voltar',
                                      onPressed: _salvarUsuario,
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      boxShadowColor: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    CustomButton(
                                      text: 'Salvar',
                                      onPressed: _salvarUsuario,
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
