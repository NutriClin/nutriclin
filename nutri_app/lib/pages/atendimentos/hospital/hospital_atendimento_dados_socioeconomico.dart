import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // Adiciona listeners para as máscaras
    pessoasController.addListener(_aplicarMascaraNumeroPessoas);
    rendaFamiliarController.addListener(_aplicarMascaraMonetaria);
    rendaPerCapitaController.addListener(_aplicarMascaraMonetaria);
  }

  void _aplicarMascaraNumeroPessoas() {
    final text = pessoasController.text;
    if (text.isNotEmpty) {
      // Remove tudo que não é dígito
      var newText = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Limita a 3 dígitos
      if (newText.length > 3) {
        newText = newText.substring(0, 3);
      }

      if (text != newText) {
        pessoasController.value = pessoasController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  void _aplicarMascaraMonetaria() {
    final controllers = [rendaFamiliarController, rendaPerCapitaController];

    for (final controller in controllers) {
      final text = controller.text;
      if (text.isNotEmpty) {
        // Remove tudo que não é dígito ou vírgula
        var newText = text.replaceAll(RegExp(r'[^0-9,]'), '');

        // Garante que há no máximo uma vírgula
        final commaCount = newText.split(',').length - 1;
        if (commaCount > 1) {
          newText = newText.substring(0, newText.lastIndexOf(','));
        }

        // Limita a 2 dígitos após a vírgula
        if (newText.contains(',')) {
          final parts = newText.split(',');
          if (parts[1].length > 2) {
            newText = '${parts[0]},${parts[1].substring(0, 2)}';
          }
        }

        // Formata como moeda (R$ 1.234,56)
        if (newText.isNotEmpty) {
          // Adiciona R$ no início
          if (!newText.startsWith('R\$ ')) {
            newText = 'R\$ $newText';
          }

          // Formata os milhares
          final parts = newText.split(',');
          if (parts.isNotEmpty) {
            var integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
            if (integerPart.isNotEmpty) {
              // Adiciona pontos como separadores de milhar
              final reversed = integerPart.split('').reversed.join();
              final reversedWithDots = reversed.replaceAllMapped(
                RegExp(r'(\d{3})(?=\d)'),
                (match) => '${match.group(0)}.',
              );
              integerPart = reversedWithDots.split('').reversed.join();

              newText =
                  'R\$ $integerPart${parts.length > 1 ? ',${parts[1]}' : ''}';
            }
          }
        }

        if (text != newText) {
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    pessoasController.removeListener(_aplicarMascaraNumeroPessoas);
    rendaFamiliarController.removeListener(_aplicarMascaraMonetaria);
    rendaPerCapitaController.removeListener(_aplicarMascaraMonetaria);

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
      _aguaEncanada = dados['agua_encanada'] ?? false;
      _esgotoEncanado = dados['esgoto_encanado'] ?? false;
      _coletaLixo = dados['coleta_lixo'] ?? false;
      _luzEletrica = dados['luz_eletrica'] ?? false;
      selectedHouseType = dados['tipo_casa'] ?? 'Selecione';
      pessoasController.text =
          dados['numero_pessoas_moram_junto']?.toString() ?? '';
      rendaFamiliarController.text = dados['renda_familiar']?.toString() ?? '';
      rendaPerCapitaController.text =
          dados['renda_per_capita']?.toString() ?? '';
      escolaridadeController.text = dados['escolaridade'] ?? '';
      profissaoController.text = dados['profissao'] ?? '';
      producaoAlimentosController.text =
          dados['producao_domestica_alimentos'] ?? '';
    });

    // Aplica as máscaras após carregar os dados
    _aplicarMascaraNumeroPessoas();
    _aplicarMascaraMonetaria();
  }

  Future<void> _salvarDadosSocioeconomicos() async {
    // Remove a formatação antes de salvar
    final rendaFamiliar =
        rendaFamiliarController.text.replaceAll('R\$ ', '').replaceAll('.', '');
    final rendaPerCapita = rendaPerCapitaController.text
        .replaceAll('R\$ ', '')
        .replaceAll('.', '');

    await _atendimentoService.salvarDadosSocioeconomicos(
      aguaEncanada: _aguaEncanada,
      esgotoEncanado: _esgotoEncanado,
      coletaLixo: _coletaLixo,
      luzEletrica: _luzEletrica,
      tipoCasa: selectedHouseType,
      numPessoas: pessoasController.text,
      rendaFamiliar: rendaFamiliar,
      rendaPerCapita: rendaPerCapita,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda familiar',
                          controller: rendaFamiliarController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda per capita',
                          controller: rendaPerCapitaController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
