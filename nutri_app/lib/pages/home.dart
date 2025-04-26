import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/calculos/calculos.dart';
import 'package:nutri_app/pages/relatorios/relatorios.dart';
import 'usuarios/usuarios.dart';

class HomePage extends StatelessWidget {
  final String tipoUsuario;

  const HomePage({super.key, required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home',
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
    double labelFontSize = 12;

    cards.add(
      CustomBox(
        text: 'Cálculos',
        labelFontSize: labelFontSize,
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
          labelFontSize: labelFontSize,
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
      cards.addAll([
        CustomBox(
          labelFontSize: labelFontSize,
          cardWidth: 40,
          text: 'Relatórios',
          imagePath: 'assets/imagens/relatorio.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RelatoriosPage(),
              ),
            );
          },
        ),
      ]);
    } else if (tipoUsuario == 'Aluno') {
      cards.addAll([
        CustomBox(
          labelFontSize: labelFontSize,
          cardWidth: 40,
          text: 'Atendimento',
          imagePath: 'assets/imagens/stethoscope.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AtendimentoPage(),
              ),
            );
          },
        ),
      ]);
    }

    return cards;
  }
}
