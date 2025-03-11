import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_box.dart';
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
                CustomBox(
                  text: 'TMB',
                  imagePath: 'assets/imagens/tmb.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TMBPage()),
                    );
                  },
                ),
                // const SizedBox(width: 10),
                // const CustomBox(
                //   text: 'GET',
                //   imagePath: 'assets/imagens/get.png', onTap: () {  },
                // ),
                // const SizedBox(width: 10),
                // const CustomBox(
                //   text: 'IMC',
                //   imagePath: 'assets/imagens/imc.png', onTap: () {  },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
