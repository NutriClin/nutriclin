import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_clinicos_nutricionais.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoAntecedentesFamiliaresPage extends StatefulWidget {
  const HospitalAtendimentoAntecedentesFamiliaresPage({super.key});

  @override
  _HospitalAtendimentoAntecedentesFamiliaresPageState createState() =>
      _HospitalAtendimentoAntecedentesFamiliaresPageState();
}

class _HospitalAtendimentoAntecedentesFamiliaresPageState
    extends State<HospitalAtendimentoAntecedentesFamiliaresPage> {
  bool _dislipidemias = false;
  bool _has = false;
  bool _cancer = false;
  bool _excessoPeso = false;
  bool _diabetes = false;
  bool _outros = false;
  final TextEditingController _outrosController = TextEditingController();
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _outrosController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final dados = await _atendimentoService.carregarAntecedentesFamiliares();

    setState(() {
      _dislipidemias = dados['dislipidemias'] as bool;
      _has = dados['has'] as bool;
      _cancer = dados['cancer'] as bool;
      _excessoPeso = dados['excessoPeso'] as bool;
      _diabetes = dados['diabetes'] as bool;
      _outros = dados['outros'] as bool;
      _outrosController.text = dados['outrosDescricao'] as String;
    });
  }

  Future<void> _salvarAntecedentesFamiliares() async {
    await _atendimentoService.salvarAntecedentesFamiliares(
      dislipidemias: _dislipidemias,
      has: _has,
      cancer: _cancer,
      excessoPeso: _excessoPeso,
      diabetes: _diabetes,
      outros: _outros,
      outrosDescricao: _outrosController.text,
    );
  }

  void _proceedToNext() {
    _salvarAntecedentesFamiliares();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoDadosClinicosNutricionaisPage()),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: 'Cancelar Atendimento',
        message:
            'Tem certeza que deseja sair? Todo o progresso não salvo será perdido.',
        confirmText: 'Sair',
        cancelText: 'Continuar',
        onConfirm: () async {
          await _atendimentoService.limparTodosDados();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AtendimentoPage()),
              (route) => false,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    return BasePage(
      title: 'Antecedentes Familiares (1º e 2º grau)',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 4,
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
                        Column(
                          children: [
                            CustomSwitch(
                              label: 'Dislipidemias',
                              value: _dislipidemias,
                              onChanged: (value) =>
                                  setState(() => _dislipidemias = value),
                              enabled: true,
                            ),
                            CustomSwitch(
                              label: 'HAS',
                              value: _has,
                              onChanged: (value) =>
                                  setState(() => _has = value),
                              enabled: true,
                            ),
                            CustomSwitch(
                              label: 'Câncer',
                              value: _cancer,
                              onChanged: (value) =>
                                  setState(() => _cancer = value),
                              enabled: true,
                            ),
                            CustomSwitch(
                              label: 'Excesso de peso',
                              value: _excessoPeso,
                              onChanged: (value) =>
                                  setState(() => _excessoPeso = value),
                              enabled: true,
                            ),
                            CustomSwitch(
                              label: 'Diabetes mellitus',
                              value: _diabetes,
                              onChanged: (value) =>
                                  setState(() => _diabetes = value),
                              enabled: true,
                            ),
                            CustomSwitch(
                              label: 'Outros',
                              value: _outros,
                              onChanged: (value) =>
                                  setState(() => _outros = value),
                              enabled: true,
                            ),
                            if (_outros)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: CustomInput(
                                  label: 'Especifique outros',
                                  controller: _outrosController,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Cancelar',
                              onPressed: () => _showCancelConfirmationDialog(),
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
