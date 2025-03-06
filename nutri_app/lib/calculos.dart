import 'package:flutter/material.dart';
import '../components/custom_box.dart';
import '../components/custom_header.dart';
import 'tmb.dart'; 

class CalculosPage extends StatelessWidget {
  const CalculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: 'Cálculos'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TMBPage()),
                      );
                    },
                    child: const CustomBox(title: 'TMB', description: 'Taxa metabólica basal'),
                  ),
                ),
                const SizedBox(width: 10),
                const Flexible(child: CustomBox(title: 'GET', description: 'Gasto energético total')),
                const SizedBox(width: 10),
                const Flexible(child: CustomBox(title: 'IMC', description: 'Índice de massa corporal')),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: CustomBox(title: 'EE', description: 'Estatura estimada')),
                SizedBox(width: 10),
                Flexible(child: CustomBox(title: 'CC E CB', description: 'Circunferências')),
                SizedBox(width: 10),
                Flexible(child: CustomBox(title: 'CMB', description: 'Pregas cutâneas')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
