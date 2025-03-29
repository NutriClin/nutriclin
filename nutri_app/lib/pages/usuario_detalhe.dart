import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';

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
  String _tipoUsuario = 'Aluno'; // Padrão para novo usuário
  bool _ativo = true; // Estado inicial para usuários ativos

  bool _isEditMode = false; // Define se é edição ou criação

  @override
  void initState() {
    super.initState();
    if (widget.idUsuario != null && widget.idUsuario!.isNotEmpty) {
      _buscarUsuario(widget.idUsuario!);
      _isEditMode = true;
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

      if (_isEditMode) {
        // Atualizar usuário existente
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
        // Criar novo usuário
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

        // Limpa os campos após o cadastro
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
                              width: 50,
                              controller: nomeController,
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              label: 'Email:',
                              width: 50,
                              controller: emailController,
                              enabled:
                                  !_isEditMode, // Desabilita edição do email ao editar
                            ),
                            if (!_isEditMode) ...[
                              const SizedBox(height: 15),
                              CustomInput(
                                label: 'Senha:',
                                width: 50,
                                controller: senhaController,
                                obscureText: true,
                              ),
                            ],
                            const SizedBox(height: 15),
                            DropdownButton<String>(
                              value: _tipoUsuario,
                              items: ['Aluno', 'Professor', 'Coordenador']
                                  .map((tipo) => DropdownMenuItem(
                                      value: tipo, child: Text(tipo)))
                                  .toList(),
                              onChanged: (valor) {
                                setState(() {
                                  _tipoUsuario = valor!;
                                });
                              },
                            ),
                            const SizedBox(height: 15),
                            SwitchListTile(
                              title: const Text('Ativo'),
                              value: _ativo,
                              onChanged: (valor) {
                                setState(() {
                                  _ativo = valor;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _salvarUsuario,
                              child: Text(_isEditMode ? 'Atualizar' : 'Salvar'),
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
