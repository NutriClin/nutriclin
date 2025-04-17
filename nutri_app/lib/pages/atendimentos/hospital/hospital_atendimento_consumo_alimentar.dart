import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_requerimentos_nutricionais.dart';

class HospitalAtendimentoConsumoAlimentarPage extends StatefulWidget {
  const HospitalAtendimentoConsumoAlimentarPage({super.key});

  @override
  State<HospitalAtendimentoConsumoAlimentarPage> createState() =>
      _HospitalAtendimentoConsumoAlimentarPageState();
}

class _HospitalAtendimentoConsumoAlimentarPageState
    extends State<HospitalAtendimentoConsumoAlimentarPage> {
  final TextEditingController _habitualController = TextEditingController();
  final TextEditingController _atualController = TextEditingController();

  @override
  void dispose() {
    _habitualController.dispose();
    _atualController.dispose();
    super.dispose();
  }

  void _proceedToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoRequerimentosNutricionaisPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    return BasePage(
      title: 'Consumo Alimentar',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 7,
                  totalSteps: 9,
                ),
                const SizedBox(height: 10),
                CustomCard(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomInput(
                          label: 'Dia alimentar habitual:',
                          controller: _habitualController,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Dia alimentar atual (Rec 24h):',
                          controller: _atualController,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Voltar',
                              onPressed: () => Navigator.pop(context),
                              color: Colors.white,
                              textColor: Colors.black,
                              boxShadowColor: Colors.black,
                            ),
                            CustomButton(
                              text: 'Próximo',
                              onPressed: _proceedToNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
