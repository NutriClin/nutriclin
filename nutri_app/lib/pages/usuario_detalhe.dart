import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';

class UsuarioDetalhe extends StatefulWidget {
  final int idUsuario;
  UsuarioDetalhe({super.key, required this.idUsuario});

  @override
  _UsuarioDetalheState createState() => _UsuarioDetalheState();
}

class _UsuarioDetalheState extends State<UsuarioDetalhe> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  String _tipoUsuario = 'Aluno'; // Padrão para novo usuário

  Future<void> _criarUsuario() async {
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
          const SnackBar(content: Text('Apenas Coordenadores podem cadastrar usuários!')),
        );
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: senhaController.text,
      );

      // Salvando usuário no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth =
        screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.4;

    return Scaffold(
      appBar: CustomAppBar(title: 'Cadastro de Usuário'),
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
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              label: 'Senha:',
                              width: 50,
                              controller: senhaController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 15),
                            DropdownButton<String>(
                              value: _tipoUsuario,
                              items: ['Aluno', 'Professor', 'Coordenador']
                                  .map((tipo) =>
                                      DropdownMenuItem(value: tipo, child: Text(tipo)))
                                  .toList(),
                              onChanged: (valor) {
                                setState(() {
                                  _tipoUsuario = valor!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _criarUsuario,
                              child: const Text('Salvar'),
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
