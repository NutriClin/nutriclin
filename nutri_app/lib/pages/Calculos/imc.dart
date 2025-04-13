import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_drawer.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/toast_util.dart';

class IMCPage extends StatefulWidget {
  const IMCPage({super.key});

  @override
  _IMCPageState createState() => _IMCPageState();
}

class _IMCPageState extends State<IMCPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double result = 0.0;
  String classification = '';
  bool isLoading = false;
  bool formError = false;

  // Filtros
  final heightFilter = FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}$'));

  final decimalFilter = TextInputFormatter.withFunction((oldValue, newValue) {
    final newText = newValue.text.replaceAll(',', '.');
    if (newText.isEmpty) return newValue.copyWith(text: '');
    final regex = RegExp(r'^\d{0,3}(\.\d{0,3})?$');
    if (!regex.hasMatch(newText)) return oldValue;
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  });

  @override
  void initState() {
    super.initState();
    weightController.addListener(_replaceCommaWithDot);
    heightController.addListener(_replaceCommaWithDot);
  }

  @override
  void dispose() {
    weightController.removeListener(_replaceCommaWithDot);
    heightController.removeListener(_replaceCommaWithDot);
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _replaceCommaWithDot() {
    final textWeight = weightController.text;
    final textHeight = heightController.text;

    if (textWeight.contains(',')) {
      weightController.text = textWeight.replaceAll(',', '.');
      weightController.selection = TextSelection.fromPosition(
        TextPosition(offset: weightController.text.length),
      );
    }

    if (textHeight.contains(',')) {
      heightController.text = textHeight.replaceAll(',', '.');
      heightController.selection = TextSelection.fromPosition(
        TextPosition(offset: heightController.text.length),
      );
    }
  }

  void calculateIMC() {
    final double weight = double.tryParse(weightController.text) ?? 0.0;
    final double height = double.tryParse(heightController.text) ?? 0.0;

    // Validações
    bool hasError = weight <= 0 || height <= 0;

    setState(() => formError = hasError);

    if (hasError) {
      ToastUtil.showToast(
        context: context,
        message: 'Preencha todos os campos obrigatórios',
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    // Cálculo do IMC
    Future.delayed(const Duration(milliseconds: 500), () {
      double heightInMeters = height / 100;
      double imcResult = weight / (heightInMeters * heightInMeters);

      String imcClassification = _getClassification(imcResult);

      setState(() {
        result = imcResult;
        classification = imcClassification;
        isLoading = false;
      });
    });
  }

  String _getClassification(double imc) {
    if (imc < 18.5) return 'Abaixo do peso';
    if (imc < 25) return 'Peso normal';
    if (imc < 30) return 'Sobrepeso';
    if (imc < 35) return 'Obesidade Grau I';
    if (imc < 40) return 'Obesidade Grau II';
    return 'Obesidade Grau III';
  }

  void clearFields() {
    setState(() {
      weightController.clear();
      heightController.clear();
      result = 0.0;
      classification = '';
      formError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(title: 'IMC - Índice de Massa Corporal'),
          drawer: const CustomDrawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: CustomCard(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Peso (kg):',
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          obrigatorio: true,
                          error: formError &&
                              (double.tryParse(weightController.text) ?? 0) <=
                                  0,
                          errorMessage: formError &&
                                  (double.tryParse(weightController.text) ??
                                          0) <=
                                      0
                              ? 'Campo obrigatório'
                              : null,
                          inputFormatters: [decimalFilter],
                        ),
                        const SizedBox(height: 15), // Alterado de 20 para 15
                        CustomInput(
                          label: 'Altura (cm):',
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          obrigatorio: true,
                          error: formError &&
                              (double.tryParse(heightController.text) ?? 0) <=
                                  0,
                          errorMessage: formError &&
                                  (double.tryParse(heightController.text) ??
                                          0) <=
                                      0
                              ? 'Campo obrigatório'
                              : null,
                          inputFormatters: [heightFilter],
                        ),
                        const SizedBox(height: 20),
                        if (result > 0) ...[
                          CustomInput(
                            label: 'IMC:',
                            controller: TextEditingController(
                              text: result.toStringAsFixed(2),
                            ),
                            enabled: false,
                          ),
                          const SizedBox(height: 15), // Alterado de 20 para 15
                          CustomInput(
                            label: 'Classificação:',
                            controller: TextEditingController(
                              text: classification,
                            ),
                            enabled: false,
                          ),
                          const SizedBox(height: 20),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  16.0), // Adicionado padding horizontal
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                text: 'Voltar',
                                onPressed: () => Navigator.pop(context),
                                color: Colors.white,
                                textColor: Colors.black,
                                boxShadowColor: Colors.black,
                              ),
                              Row(
                                children: [
                                  CustomButton(
                                    text: 'Limpar',
                                    onPressed: clearFields,
                                    color: Colors.white,
                                    textColor: Colors.red,
                                    boxShadowColor: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  CustomButton(
                                    text: 'Calcular',
                                    onPressed: calculateIMC,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
