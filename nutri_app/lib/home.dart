import 'package:flutter/material.dart';
import 'calculos.dart';
import 'components/custom_appbar.dart';

class HomePage extends StatelessWidget {
  final String tipoUsuario; // ✅ Agora armazenamos o tipo de usuário

  const HomePage({super.key, required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home - $tipoUsuario', // ✅ Exibe o tipo do usuário
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, 'Cálculos', 'assets/imagens/calculos.png', true),
              const SizedBox(width: 20),
              _buildButton(context, 'Atendimento', 'assets/imagens/atendimentos.png', false),
              const SizedBox(width: 20),
              Stack(
                children: [
                  _buildButton(context, 'Relatórios', 'assets/imagens/relatorios.png', false),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
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

  Widget _buildButton(BuildContext context, String text, String imagePath, bool isClickable) {
    return GestureDetector(
      onTap: isClickable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalculosPage()),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
