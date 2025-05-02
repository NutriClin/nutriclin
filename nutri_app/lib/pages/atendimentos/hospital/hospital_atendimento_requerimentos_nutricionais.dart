import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_conduta_nutricional.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoRequerimentosNutricionaisPage extends StatefulWidget {
  const HospitalAtendimentoRequerimentosNutricionaisPage({super.key});

  @override
  State<HospitalAtendimentoRequerimentosNutricionaisPage> createState() =>
      _HospitalAtendimentoRequerimentosNutricionaisPageState();
}

class _HospitalAtendimentoRequerimentosNutricionaisPageState
    extends State<HospitalAtendimentoRequerimentosNutricionaisPage> {
  final TextEditingController _kcalDiaController = TextEditingController();
  final TextEditingController _kcalKgController = TextEditingController();
  final TextEditingController _choController = TextEditingController();
  final TextEditingController _lipController = TextEditingController();
  final TextEditingController _ptnPorcentagemController =
      TextEditingController();
  final TextEditingController _ptnKgController = TextEditingController();
  final TextEditingController _ptnDiaController = TextEditingController();
  final TextEditingController _liquidoKgController = TextEditingController();
  final TextEditingController _liquidoDiaController = TextEditingController();
  final TextEditingController _fibrasController = TextEditingController();
  final TextEditingController _outrosController = TextEditingController();

  // Services
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _kcalDiaController.dispose();
    _kcalKgController.dispose();
    _choController.dispose();
    _lipController.dispose();
    _ptnPorcentagemController.dispose();
    _ptnKgController.dispose();
    _ptnDiaController.dispose();
    _liquidoKgController.dispose();
    _liquidoDiaController.dispose();
    _fibrasController.dispose();
    _outrosController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final dados =
          await _atendimentoService.carregarRequerimentosNutricionais();
      if (mounted) {
        setState(() {
          _kcalDiaController.text = dados['kcal_dia'] ?? '';
          _kcalKgController.text = dados['kcal_kg'] ?? '';
          _choController.text = dados['cho'] ?? '';
          _lipController.text = dados['lip'] ?? '';
          _ptnPorcentagemController.text = dados['Ptn'] ?? '';
          _ptnKgController.text = dados['ptn_kg'] ?? '';
          _ptnDiaController.text = dados['ptn_dia'] ?? '';
          _liquidoKgController.text = dados['liquido_kg'] ?? '';
          _liquidoDiaController.text = dados['liquido_dia'] ?? '';
          _fibrasController.text = dados['fibras'] ?? '';
          _outrosController.text = dados['outros'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar requerimentos nutricionais: $e');
    }
  }

  Future<void> _salvarDados() async {
    try {
      await _atendimentoService.salvarRequerimentosNutricionais(
        kcalDia: _kcalDiaController.text,
        kcalKg: _kcalKgController.text,
        cho: _choController.text,
        lip: _lipController.text,
        ptnPorcentagem: _ptnPorcentagemController.text,
        ptnKg: _ptnKgController.text,
        ptnDia: _ptnDiaController.text,
        liquidoKg: _liquidoKgController.text,
        liquidoDia: _liquidoDiaController.text,
        fibras: _fibrasController.text,
        outros: _outrosController.text,
      );
    } catch (e) {
      debugPrint('Erro ao salvar requerimentos nutricionais: $e');
    }
  }

  void _proceedToNext() {
    _salvarDados();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoCondutaNutricionalPage()),
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
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => AtendimentoPage()),
                (route) => false,
              );
            });
          }
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
      title: 'Requerimentos Nutricionais',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 8,
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
                            label: 'Kcal / dia',
                            controller: _kcalDiaController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Kcal / kg', controller: _kcalKgController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'CHO %', controller: _choController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Lip %', controller: _lipController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Ptn %',
                            controller: _ptnPorcentagemController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Ptn g / kg', controller: _ptnKgController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Ptn g / dia',
                            controller: _ptnDiaController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Líquido ml / kg',
                            controller: _liquidoKgController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Líquido ml / dia',
                            controller: _liquidoDiaController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                            label: 'Fibras g/dia',
                            controller: _fibrasController),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Outros',
                          controller: _outrosController,
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
