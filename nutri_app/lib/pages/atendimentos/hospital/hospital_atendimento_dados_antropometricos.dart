import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_consumo_alimentar.dart';

class HospitalAtendimentoDadosAntropometricosPage extends StatefulWidget {
  const HospitalAtendimentoDadosAntropometricosPage({super.key});

  @override
  _HospitalAtendimentoDadosAntropometricosPageState createState() =>
      _HospitalAtendimentoDadosAntropometricosPageState();
}

class _HospitalAtendimentoDadosAntropometricosPageState
    extends State<HospitalAtendimentoDadosAntropometricosPage> {
  // Controllers para todos os campos
  final TextEditingController _pesoAtualController = TextEditingController();
  final TextEditingController _pesoUsualController = TextEditingController();
  final TextEditingController _estaturaController = TextEditingController();
  final TextEditingController _imcController = TextEditingController();
  final TextEditingController _piController = TextEditingController();
  final TextEditingController _cbController = TextEditingController();
  final TextEditingController _pctController = TextEditingController();
  final TextEditingController _pcbController = TextEditingController();
  final TextEditingController _pcseController = TextEditingController();
  final TextEditingController _pcsiController = TextEditingController();
  final TextEditingController _cmbController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _ajController = TextEditingController();
  final TextEditingController _percentualGorduraController =
      TextEditingController();
  final TextEditingController _perdaPesoController = TextEditingController();
  final TextEditingController _diagnosticoNutricionalController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose de todos os controllers
    _pesoAtualController.dispose();
    _pesoUsualController.dispose();
    _estaturaController.dispose();
    _imcController.dispose();
    _piController.dispose();
    _cbController.dispose();
    _pctController.dispose();
    _pcbController.dispose();
    _pcseController.dispose();
    _pcsiController.dispose();
    _cmbController.dispose();
    _caController.dispose();
    _cpController.dispose();
    _ajController.dispose();
    _percentualGorduraController.dispose();
    _perdaPesoController.dispose();
    _diagnosticoNutricionalController.dispose();
    super.dispose();
  }

  void _proceedToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoConsumoAlimentarPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    return BasePage(
      title: 'Dados Antropométricos',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 6,
                  totalSteps: 9,
                ),
                SizedBox(height: espacamentoCards),
                CustomCard(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomInput(
                          label: 'Peso atual (kg)',
                          controller: _pesoAtualController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Peso usual (kg)',
                          controller: _pesoUsualController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Estatura (cm)',
                          controller: _estaturaController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'IMC',
                          controller: _imcController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PI',
                          controller: _piController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CB (cm)',
                          controller: _cbController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCT (mm)',
                          controller: _pctController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCB (mm)',
                          controller: _pcbController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSE (mm)',
                          controller: _pcseController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSI (mm)',
                          controller: _pcsiController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CMB (cm)',
                          controller: _cmbController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CA (cm)',
                          controller: _caController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CP (cm)',
                          controller: _cpController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'AJ (cm)',
                          controller: _ajController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% de GC',
                          controller: _percentualGorduraController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% perda peso/tempo',
                          controller: _perdaPesoController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Diagnóstico Nutricional',
                          controller: _diagnosticoNutricionalController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Cancelar',
                              onPressed: () {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                              color: Colors.white,
                              textColor: Colors.red,
                              boxShadowColor: Colors.black,
                            ),
                            Row(
                              children: [
                                CustomButton(
                                  text: 'Voltar',
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  boxShadowColor: Colors.black,
                                ),
                                const SizedBox(width: 10),
                                CustomButton(
                                  text: 'Próximo',
                                  onPressed: _proceedToNext,
                                ),
                              ],
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
