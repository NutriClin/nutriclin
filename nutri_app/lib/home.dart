import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/calculos.dart';
import 'components/custom_appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomBox(
                text: 'Cálculos',
                imagePath: 'assets/imagens/calculadora.svg',
                onTap: () {
                  print("Clicou no box Cálculos");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalculosPage()),
                  );
                },
              ),
              const SizedBox(width: 20),
              CustomBox(
                text: 'Atendimento',
                imagePath: 'assets/imagens/stethoscope.svg',
                onTap: () {
                  print("Clicou no box Atendimento");
                },
              ),
              const SizedBox(width: 20),
              Stack(
                children: [
                  CustomBox(
                    text: 'Relatórios',
                    imagePath: 'assets/imagens/relatorios.svg',
                    
                    onTap: () {
                      print("Clicou no box Relatórios");
                    },
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
