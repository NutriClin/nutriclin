import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_checkbox.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_antecedentes_pessoais.dart';

class HospitalAtendimentoDadosSocioeconomicoPage extends StatefulWidget {
  const HospitalAtendimentoDadosSocioeconomicoPage({super.key});

  @override
  _HospitalAtendimentoDadosSocioeconomicoPageState createState() =>
      _HospitalAtendimentoDadosSocioeconomicoPageState();
}

class _HospitalAtendimentoDadosSocioeconomicoPageState
    extends State<HospitalAtendimentoDadosSocioeconomicoPage> {
  // Variáveis de estado simplificadas
  bool? aguaEncanada;
  bool? esgotoEncanado;
  bool? coletaLixo;
  bool? luzEletrica;
  String selectedHouseType = 'Selecione';

  // Controllers para campos de texto
  final pessoasController = TextEditingController();
  final rendaFamiliarController = TextEditingController();
  final rendaPerCapitaController = TextEditingController();
  final escolaridadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final producaoAlimentosController = TextEditingController();

  @override
  void dispose() {
    pessoasController.dispose();
    rendaFamiliarController.dispose();
    rendaPerCapitaController.dispose();
    escolaridadeController.dispose();
    profissaoController.dispose();
    producaoAlimentosController.dispose();
    super.dispose();
  }

  void proceedToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoAntecedentesPessoaisPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double espacamentoCards = 10;

    return BasePage(
      title: 'Dados Socioeconômicos',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(currentStep: 2, totalSteps: 9),
                SizedBox(height: espacamentoCards),
                CustomCard(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCheckbox(
                          label: 'Água encanada:',
                          value: aguaEncanada,
                          onChanged: (value) =>
                              setState(() => aguaEncanada = value),
                        ),
                        CustomCheckbox(
                          label: 'Esgoto encanado:',
                          value: esgotoEncanado,
                          onChanged: (value) =>
                              setState(() => esgotoEncanado = value),
                        ),
                        CustomCheckbox(
                          label: 'Coleta de lixo:',
                          value: coletaLixo,
                          onChanged: (value) =>
                              setState(() => coletaLixo = value),
                        ),
                        CustomCheckbox(
                          label: 'Luz elétrica:',
                          value: luzEletrica,
                          onChanged: (value) =>
                              setState(() => luzEletrica = value),
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Tipo de casa',
                          value: selectedHouseType,
                          items: const [
                            'Selecione',
                            'Alvenaria',
                            'Madeira',
                            'Mista',
                            'Não possui',
                            'Outro'
                          ],
                          onChanged: (value) =>
                              setState(() => selectedHouseType = value!),
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Nº de pessoas na casa',
                          controller: pessoasController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda familiar',
                          controller: rendaFamiliarController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda per capita',
                          controller: rendaPerCapitaController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Escolaridade',
                          controller: escolaridadeController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Profissão/Ocupação',
                          controller: profissaoController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Produção doméstica de alimentos: Quais?',
                          controller: producaoAlimentosController,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 15),
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
                              onPressed: proceedToNext,
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
