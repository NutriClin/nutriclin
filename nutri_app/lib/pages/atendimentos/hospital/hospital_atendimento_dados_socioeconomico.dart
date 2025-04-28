import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_antecedentes_pessoais.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoDadosSocioeconomicoPage extends StatefulWidget {
  const HospitalAtendimentoDadosSocioeconomicoPage({super.key});

  @override
  _HospitalAtendimentoDadosSocioeconomicoPageState createState() =>
      _HospitalAtendimentoDadosSocioeconomicoPageState();
}

class _HospitalAtendimentoDadosSocioeconomicoPageState
    extends State<HospitalAtendimentoDadosSocioeconomicoPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();

  bool _aguaEncanada = false;
  bool _esgotoEncanado = false;
  bool _coletaLixo = false;
  bool _luzEletrica = false;
  String selectedHouseType = 'Selecione';

  // Controllers para campos de texto
  final pessoasController = TextEditingController();
  final rendaFamiliarController = TextEditingController();
  final rendaPerCapitaController = TextEditingController();
  final escolaridadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final producaoAlimentosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

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

  Future<void> _carregarDados() async {
    final dados = await _atendimentoService.carregarDadosSocioeconomicos();

    setState(() {
      _aguaEncanada = dados['aguaEncanada'] as bool;
      _esgotoEncanado = dados['esgotoEncanado'] as bool;
      _coletaLixo = dados['coletaLixo'] as bool;
      _luzEletrica = dados['luzEletrica'] as bool;
      selectedHouseType = dados['tipoCasa'] as String;
      pessoasController.text = dados['numPessoas'] as String;
      rendaFamiliarController.text = dados['rendaFamiliar'] as String;
      rendaPerCapitaController.text = dados['rendaPerCapita'] as String;
      escolaridadeController.text = dados['escolaridade'] as String;
      profissaoController.text = dados['profissao'] as String;
      producaoAlimentosController.text = dados['producaoAlimentos'] as String;
    });
  }

  Future<void> _salvarDadosSocioeconomicos() async {
    await _atendimentoService.salvarDadosSocioeconomicos(
      aguaEncanada: _aguaEncanada,
      esgotoEncanado: _esgotoEncanado,
      coletaLixo: _coletaLixo,
      luzEletrica: _luzEletrica,
      tipoCasa: selectedHouseType,
      numPessoas: pessoasController.text,
      rendaFamiliar: rendaFamiliarController.text,
      rendaPerCapita: rendaPerCapitaController.text,
      escolaridade: escolaridadeController.text,
      profissao: profissaoController.text,
      producaoAlimentos: producaoAlimentosController.text,
    );
  }

  void _proceedToNext() async {
    await _salvarDadosSocioeconomicos();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoAntecedentesPessoaisPage()),
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
                        CustomSwitch(
                          label: 'Água encanada',
                          value: _aguaEncanada,
                          onChanged: (value) =>
                              setState(() => _aguaEncanada = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Esgoto encanado',
                          value: _esgotoEncanado,
                          onChanged: (value) =>
                              setState(() => _esgotoEncanado = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Coleta de lixo',
                          value: _coletaLixo,
                          onChanged: (value) =>
                              setState(() => _coletaLixo = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Luz elétrica',
                          value: _luzEletrica,
                          onChanged: (value) =>
                              setState(() => _luzEletrica = value),
                          enabled: true,
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
