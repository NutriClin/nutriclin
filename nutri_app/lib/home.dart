import 'package:flutter/material.dart';
import 'calculos.dart'; 


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 216, 216, 216),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildButton(context, 'Cálculos', 'assets/imagens/calculos.png', true),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildButton(context, 'Atendimento', 'assets/imagens/atendimentos.png', false),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildButton(context, 'Relatórios', 'assets/imagens/relatorios.png', false),
            ),
          ],
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
