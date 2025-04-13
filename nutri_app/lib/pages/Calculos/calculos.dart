import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/pages/calculos/get.dart';
import 'package:nutri_app/pages/calculos/imc.dart';
import 'package:nutri_app/pages/calculos/tmb.dart';

class CalculosPage extends StatelessWidget {
  const CalculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Cálculos',
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

  List<Widget> _buildCards(BuildContext context) {
    List<Widget> cards = [];

    double labelFontSize = 12;
    cards.addAll([
      CustomBox(
        text: 'Taxa metabólica basal',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/tmb-text.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TMBPage()),
        ),
      ),
      const SizedBox(width: 20),
      CustomBox(
        text: 'Gasto energético total',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/get-text.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GETPage()),
        ),
      ),
      const SizedBox(width: 20),
      CustomBox(
        text: 'Índice de massa corporal',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/imc-text.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IMCPage()),
        ),
      ),
    ]);

    return cards;
  }
}
