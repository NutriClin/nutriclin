import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'components/custom_appbar.dart';
import 'usuarios.dart';

class HomePage extends StatelessWidget {
  final String tipoUsuario;

  const HomePage({super.key, required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
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

    // Adiciona o card de Cálculos, que será exibido para todos os tipos de usuário
    // cards.add(
    //   CustomBox(
    //     text: 'Cálculos',
    //     imagePath: 'assets/imagens/calculadora.svg',
    //     onTap: () {
    //       print("Clicou no box Cálculos");
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => const CalculosPage()),
    //       );
    //     },
    //   ),
    // );
    // cards.add(const SizedBox(width: 20));

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
                builder: (context) =>
                    const UsuarioPage(),
              ),
            );
          },
        ),
        // const SizedBox(width: 20),
        // CustomBox(
        //   text: 'Relatórios',
        //   imagePath: 'assets/imagens/relatorios.svg',
        //   onTap: () {
        //     print("Clicou no box Relatórios");
        //   },
        // ),
      ]);
    } else if (tipoUsuario == 'Professor') {
      // cards.addAll([
      //   CustomBox(
      //     text: 'Relatórios Específicos',
      //     imagePath: 'assets/imagens/relatorios.svg',
      //     onTap: () {
      //       print("Clicou no box Relatórios Específicos");
      //     },
      //   ),
      // ]);
    } else if (tipoUsuario == 'Aluno') {
      cards.addAll([
        CustomBox(
          text: 'Atendimento',
          imagePath: 'assets/imagens/stethoscope.svg',
          onTap: () {
            print("Clicou no box Atendimento");
          },
        ),
        const SizedBox(width: 20),
        CustomBox(
          text: 'Relatórios',
          imagePath: 'assets/imagens/relatorios.svg',
          onTap: () {
            print("Clicou no box relatorios");
          },
        ),
      ]);
    }

    return cards;
  }
}
