import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importação necessária para TextInputFormatter
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_consumo_alimentar.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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

  // Validação dos campos
  bool _pesoAtualError = false;
  bool _pesoUsualError = false;
  bool _estaturaError = false;

  final FilteringTextInputFormatter _numerosFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));

  // Serviço para manipulação de dados
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

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

  Future<void> _carregarDados() async {
    final dados = await _atendimentoService.carregarDadosAntropometricos();

    setState(() {
      _pesoAtualController.text = dados['peso_atual'] ?? '';
      _pesoUsualController.text = dados['peso_usual'] ?? '';
      _estaturaController.text = dados['estatura'] ?? '';
      _imcController.text = dados['imc'] ?? '';
      _piController.text = dados['pi'] ?? '';
      _cbController.text = dados['cb'] ?? '';
      _pctController.text = dados['pct'] ?? '';
      _pcbController.text = dados['pcb'] ?? '';
      _pcseController.text = dados['pcse'] ?? '';
      _pcsiController.text = dados['pcsi'] ?? '';
      _cmbController.text = dados['cmb'] ?? '';
      _caController.text = dados['ca'] ?? '';
      _cpController.text = dados['cp'] ?? '';
      _ajController.text = dados['aj'] ?? '';
      _percentualGorduraController.text = dados['porcentagem_gc'] ?? '';
      _perdaPesoController.text =
          dados['porcentagem_perca_peso_por_tempo'] ?? '';
      _diagnosticoNutricionalController.text =
          dados['diagnostico_nutricional'] ?? '';
    });
  }

  bool _validarCampos() {
    bool valido = true;

    if (_pesoAtualController.text.trim().isEmpty) {
      _pesoAtualError = true;
      valido = false;
    } else {
      _pesoAtualError = false;
    }

    if (_pesoUsualController.text.trim().isEmpty) {
      _pesoUsualError = true;
      valido = false;
    } else {
      _pesoUsualError = false;
    }

    if (_estaturaController.text.trim().isEmpty) {
      _estaturaError = true;
      valido = false;
    } else {
      _estaturaError = false;
    }

    setState(() {});
    return valido;
  }

  Future<void> _salvarDadosAntropometricos() async {
    await _atendimentoService.salvarDadosAntropometricos(
      pesoAtual: _pesoAtualController.text,
      pesoUsual: _pesoUsualController.text,
      estatura: _estaturaController.text,
      imc: _imcController.text,
      pi: _piController.text,
      cb: _cbController.text,
      pct: _pctController.text,
      pcb: _pcbController.text,
      pcse: _pcseController.text,
      pcsi: _pcsiController.text,
      cmb: _cmbController.text,
      ca: _caController.text,
      cp: _cpController.text,
      aj: _ajController.text,
      percentualGordura: _percentualGorduraController.text,
      perdaPeso: _perdaPesoController.text,
      diagnosticoNutricional: _diagnosticoNutricionalController.text,
    );
  }

  void _proceedToNext() {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }
    _salvarDadosAntropometricos();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoConsumoAlimentarPage()),
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
                        // Todos os campos numéricos com máscara
                        CustomInput(
                          label: 'Peso atual (kg)',
                          controller: _pesoAtualController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                          error: _pesoAtualError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_pesoAtualError && value.isNotEmpty) {
                              setState(() => _pesoAtualError = false);
                            }
                          },
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Peso usual (kg)',
                          controller: _pesoUsualController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                          error: _pesoUsualError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_pesoUsualError && value.isNotEmpty) {
                              setState(() => _pesoUsualError = false);
                            }
                          },
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Estatura (cm)',
                          controller: _estaturaController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                          error: _estaturaError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_estaturaError && value.isNotEmpty) {
                              setState(() => _estaturaError = false);
                            }
                          },
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'IMC',
                          controller: _imcController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PI',
                          controller: _piController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CB (cm)',
                          controller: _cbController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCT (mm)',
                          controller: _pctController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCB (mm)',
                          controller: _pcbController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSE (mm)',
                          controller: _pcseController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSI (mm)',
                          controller: _pcsiController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CMB (cm)',
                          controller: _cmbController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CA (cm)',
                          controller: _caController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CP (cm)',
                          controller: _cpController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'AJ (cm)',
                          controller: _ajController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% de GC',
                          controller: _percentualGorduraController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% perda peso/tempo',
                          controller: _perdaPesoController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_numerosFormatter],
                        ),
                        SizedBox(height: espacamentoCards),
                        // Único campo que não tem máscara numérica
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
