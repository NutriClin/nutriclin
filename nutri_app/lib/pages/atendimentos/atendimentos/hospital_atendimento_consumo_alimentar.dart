import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicione esta importação
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/atendimentos/hospital_atendimento_requerimentos_nutricionais.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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
  final TextEditingController _ingestaoHidricaController =
      TextEditingController();
  final TextEditingController _evacuacaoController = TextEditingController();
  final TextEditingController _diureseController = TextEditingController();

  // Filtro para aceitar apenas números
  final FilteringTextInputFormatter _numerosFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  // Services
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _habitualController.dispose();
    _atualController.dispose();
    _ingestaoHidricaController.dispose();
    _evacuacaoController.dispose();
    _diureseController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final dados = await _atendimentoService.carregarConsumoAlimentar();

    setState(() {
      _habitualController.text = dados['habitual'] ?? '';
      _atualController.text = dados['atual'] ?? '';
      _ingestaoHidricaController.text = dados['ingestao_hidrica'] ?? '';
      _evacuacaoController.text = dados['evacuacao'] ?? '';
      _diureseController.text = dados['diurese'] ?? '';
    });
  }

  Future<void> _salvarConsumoAlimentar() async {
    await _atendimentoService.salvarConsumoAlimentar(
      habitual: _habitualController.text,
      atual: _atualController.text,
      ingestaoHidrica: _ingestaoHidricaController.text,
      evacuacao: _evacuacaoController.text,
      diurese: _diureseController.text,
    );
  }

  void _proceedToNext() {
    _salvarConsumoAlimentar();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoRequerimentosNutricionaisPage()),
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
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Ingestão hídrica',
                          controller: _ingestaoHidricaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Evacuação',
                          controller: _evacuacaoController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Diurese',
                          controller: _diureseController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: 20),
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
