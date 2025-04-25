import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_antropometricos.dart';

class HospitalAtendimentoDadosClinicosNutricionaisPage extends StatefulWidget {
  const HospitalAtendimentoDadosClinicosNutricionaisPage({super.key});

  @override
  _HospitalAtendimentoDadosClinicosNutricionaisPageState createState() =>
      _HospitalAtendimentoDadosClinicosNutricionaisPageState();
}

class _HospitalAtendimentoDadosClinicosNutricionaisPageState
    extends State<HospitalAtendimentoDadosClinicosNutricionaisPage> {
  // Controllers para campos de texto
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _prescricaoController = TextEditingController();
  final TextEditingController _acetaceboController = TextEditingController();
  final TextEditingController _alimentacaoHabitualController =
      TextEditingController();
  final TextEditingController _especificarAlimentacaoController =
      TextEditingController();
  final TextEditingController _doencaAnteriorController =
      TextEditingController();
  final TextEditingController _cirurgiaController = TextEditingController();
  final TextEditingController _alteracaoPesoController =
      TextEditingController();
  final TextEditingController _quantoPesoController = TextEditingController();
  final TextEditingController _desconfortosController = TextEditingController();
  final TextEditingController _dietaHospitalarController =
      TextEditingController();
  final TextEditingController _qualDietaController = TextEditingController();
  final TextEditingController _suplementacaoController =
      TextEditingController();
  final TextEditingController _tipoSuplementacaoController =
      TextEditingController();
  final TextEditingController _condicaoFuncionalController =
      TextEditingController();
  final TextEditingController _especificarCondicaoController =
      TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _examesLaboratoriaisController =
      TextEditingController();
  final TextEditingController _exameFisicoController = TextEditingController();

  String selectedAlimentacaoHabitual = 'Selecione';
  String selectedCondicaoFuncional = 'Selecione';

  // Estados para os switches/checkboxes
  bool _doencaAnterior = false;
  bool _cirurgiaRecente = false;
  bool _febre = false;
  bool _alteracaoPeso = false;
  bool _alimentacaoInadequada = false;
  bool _necessidadeDieta = false;
  bool _suplementacao = false;
  bool _desconforto = false;
  bool _tabagismo = false;
  bool _etilismo = false;
  bool _condicaoFuncional = false;

  @override
  void dispose() {
    // Dispose de todos os controllers
    _diagnosticoController.dispose();
    _prescricaoController.dispose();
    _acetaceboController.dispose(); // Novo dispose
    _alimentacaoHabitualController.dispose();
    _especificarAlimentacaoController.dispose();
    _doencaAnteriorController.dispose();
    _cirurgiaController.dispose();
    _alteracaoPesoController.dispose();
    _quantoPesoController.dispose();
    _desconfortosController.dispose();
    _dietaHospitalarController.dispose();
    _qualDietaController.dispose();
    _suplementacaoController.dispose();
    _tipoSuplementacaoController.dispose();
    _condicaoFuncionalController.dispose();
    _especificarCondicaoController.dispose();
    _medicamentosController.dispose();
    _examesLaboratoriaisController.dispose();
    _exameFisicoController.dispose();
    super.dispose();
  }

  void _proceedToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoDadosAntropometricosPage()),
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
        onConfirm: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AtendimentoPage()),
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
      title: 'Dados Clínicos e Nutricionais',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 5,
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
                        Text(
                          'Dados Clínicos e Nutricionais',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomInput(
                          label: 'Diagnóstico Clínico',
                          controller: _diagnosticoController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Prescrição Dietoterápica',
                          controller: _prescricaoController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Aceitação:',
                          controller: _acetaceboController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Alimentação Habitual',
                          value: selectedAlimentacaoHabitual,
                          items: const ['Selecione', 'Alterada', 'Inadequada'],
                          onChanged: (value) => setState(() =>
                              value == 'Inadequada'
                                  ? _alimentacaoInadequada = true
                                  : _alimentacaoInadequada = false),
                        ),
                        if (_alimentacaoInadequada) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Especificar',
                            controller: _alimentacaoHabitualController,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Doença Anterior',
                          value: _doencaAnterior,
                          onChanged: (value) =>
                              setState(() => _doencaAnterior = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Cirurgia Recente',
                          value: _cirurgiaRecente,
                          onChanged: (value) =>
                              setState(() => _cirurgiaRecente = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Febre',
                          value: _febre,
                          onChanged: (value) => setState(() => _febre = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Alterações de peso recentes',
                          value: _alteracaoPeso,
                          onChanged: (value) =>
                              setState(() => _alteracaoPeso = value),
                          enabled: true,
                        ),
                        if (_alteracaoPeso) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Quanto',
                            controller: _quantoPesoController,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Desconfortos Orais/Gastrointestinais',
                          value: _desconforto,
                          onChanged: (value) =>
                              setState(() => _desconforto = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Necessidade de dieta hospitalar',
                          value: _necessidadeDieta,
                          onChanged: (value) =>
                              setState(() => _necessidadeDieta = value),
                          enabled: true,
                        ),
                        if (_necessidadeDieta) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Qual',
                            controller: _qualDietaController,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Suplementação Nutricional',
                          value: _suplementacao,
                          onChanged: (value) =>
                              setState(() => _suplementacao = value),
                          enabled: true,
                        ),
                        if (_suplementacao) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Tipo /razão',
                            controller: _tipoSuplementacaoController,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Tabagismo',
                          value: _tabagismo,
                          onChanged: (value) =>
                              setState(() => _tabagismo = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Etilismo',
                          value: _etilismo,
                          onChanged: (value) =>
                              setState(() => _etilismo = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Condição funcional',
                          value: selectedCondicaoFuncional,
                          items: const [
                            'Selecione',
                            'Favorável',
                            'Desfavorável'
                          ],
                          onChanged: (value) => setState(() =>
                              value == 'Desfavorável'
                                  ? _condicaoFuncional = true
                                  : _condicaoFuncional = false),
                        ),
                        if (_condicaoFuncional) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Especificar',
                            controller: _especificarCondicaoController,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Medicamentos/vitaminas/minerais prescritos',
                          controller: _medicamentosController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Exames Laboratoriais',
                          controller: _examesLaboratoriaisController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Exame Físico',
                          controller: _exameFisicoController,
                          keyboardType: TextInputType.text,
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
