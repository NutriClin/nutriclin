import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_identificacao.dart';
import 'package:nutri_app/pages/calculos/tmb.dart';

class AtendimentoPage extends StatelessWidget {
  const AtendimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Atendimento',
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
        text: 'Clínica',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/clinica.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TMBPage()),
        ),
      ),
      const SizedBox(width: 20),
      CustomBox(
        text: 'Hospital',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/doctor.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HospitalAtendimentoIdentificacaoPage()),
        ),
      ),
    ]);

    return cards;
  }
}
