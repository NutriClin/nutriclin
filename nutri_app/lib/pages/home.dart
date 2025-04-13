import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/components/custom_drawer.dart';
import 'package:nutri_app/pages/calculos/calculos.dart';
import 'usuarios/usuarios.dart';

class HomePage extends StatelessWidget {
  final String tipoUsuario;

  const HomePage({super.key, required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      drawer: const CustomDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildCards(context),
          ),
        ),
      ),
    );
  }

  // Método para retornar os cards com base no tipo de usuário
  List<Widget> _buildCards(BuildContext context) {
    List<Widget> cards = [];

    cards.add(
      CustomBox(
        text: 'Cálculos',
        imagePath: 'assets/imagens/calculadora.svg',
        onTap: () {
          print("Clicou no box Cálculos");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalculosPage()),
          );
        },
      ),
    );
    cards.add(const SizedBox(width: 20));

    // Exibe os cards dependendo do tipo de usuário
    if (tipoUsuario == 'Coordenador') {
      cards.addAll([
        CustomBox(
          text: 'Usuários',
          imagePath: 'assets/imagens/user-group.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsuarioPage(),
              ),
            );
          },
        ),
      ]);
    } else if (tipoUsuario == 'Professor') {
    } else if (tipoUsuario == 'Aluno') {
      cards.addAll([
        CustomBox(
          text: 'Atendimento',
          imagePath: 'assets/imagens/stethoscope.svg',
          onTap: () {
            print("Clicou no box Atendimento");
          },
        ),
      ]);
    }

    return cards;
  }
}
