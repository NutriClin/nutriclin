import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_drawer.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/toast_util.dart';

class GETPage extends StatefulWidget {
  const GETPage({super.key});

  @override
  _GETPageState createState() => _GETPageState();
}

class _GETPageState extends State<GETPage> {
  String selectedGender = 'Selecione';
  String selectedActivity = 'Selecione';
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double result = 0.0;
  bool isLoading = false;
  bool formError = false;

  // Filtros:
  final ageFilter = FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}$'));
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
  }

  @override
  void dispose() {
    weightController.removeListener(_replaceCommaWithDot);
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _replaceCommaWithDot() {
    final textWeight = weightController.text;
    if (textWeight.contains(',')) {
      weightController.text = textWeight.replaceAll(',', '.');
      weightController.selection = TextSelection.fromPosition(
        TextPosition(offset: weightController.text.length),
      );
    }
  }

  void calculateGET() {
    final double weight = double.tryParse(weightController.text) ?? 0.0;
    final int heightCm = int.tryParse(heightController.text) ?? 0;
    final double heightM = heightCm / 100;
    final int age = int.tryParse(ageController.text) ?? 0;

    // Validações
    bool hasError = weight <= 0 ||
        heightCm <= 0 ||
        age <= 0 ||
        selectedGender == 'Selecione' ||
        selectedActivity == 'Selecione';

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

    // Cálculo da TMB (DRI 2002)
    double tmb;
    if (selectedGender == 'Masculino') {
      tmb = 293 - (3.8 * age) + (456.4 * heightM) + (10.12 * weight);
    } else {
      tmb = 247 - (2.47 * age) + (401.5 * heightM) + (8.6 * weight);
    }

    // Fator de Atividade (FAO/OMS 1985)
    double factor = switch (selectedActivity) {
      'Sedentário' => 1.2,
      'Leve' => 1.55,
      'Moderada' => (selectedGender == 'Masculino') ? 1.80 : 1.65,
      'Intensa' => (selectedGender == 'Masculino') ? 2.10 : 1.80,
      _ => 1.2,
    };

    setState(() {
      result = tmb * factor;
      isLoading = false;
    });
  }

  void clearFields() {
    setState(() {
      selectedGender = 'Selecione';
      selectedActivity = 'Selecione';
      ageController.clear();
      weightController.clear();
      heightController.clear();
      result = 0.0;
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
          appBar: const CustomAppBar(title: 'GET - Gasto Energético Total'),
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
                        CustomDropdown(
                          label: 'Sexo',
                          value: selectedGender,
                          items: ['Selecione', 'Masculino', 'Feminino'],
                          onChanged: (value) =>
                              setState(() => selectedGender = value!),
                          obrigatorio: true,
                          error: formError && selectedGender == 'Selecione',
                          errorMessage:
                              formError && selectedGender == 'Selecione'
                                  ? 'Campo obrigatório'
                                  : null,
                        ),
                        const SizedBox(height: 15),
                        CustomInput(
                          label: 'Idade',
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          obrigatorio: true,
                          error: formError &&
                              (int.tryParse(ageController.text) ?? 0) <= 0,
                          errorMessage: formError &&
                                  (int.tryParse(ageController.text) ?? 0) <= 0
                              ? 'Campo obrigatório'
                              : null,
                          inputFormatters: [ageFilter],
                        ),
                        const SizedBox(height: 15),
                        CustomInput(
                          label: 'Peso (kg)',
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
                        const SizedBox(height: 15),
                        CustomInput(
                          label: 'Altura (cm)',
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          obrigatorio: true,
                          error: formError &&
                              (int.tryParse(heightController.text) ?? 0) <= 0,
                          errorMessage: formError &&
                                  (int.tryParse(heightController.text) ?? 0) <=
                                      0
                              ? 'Campo obrigatório'
                              : null,
                          inputFormatters: [ageFilter],
                        ),
                        const SizedBox(height: 15),
                        CustomDropdown(
                          label: 'Atividade física',
                          value: selectedActivity,
                          items: const [
                            'Selecione',
                            'Sedentário',
                            'Leve',
                            'Moderada',
                            'Intensa'
                          ],
                          onChanged: (value) =>
                              setState(() => selectedActivity = value!),
                          obrigatorio: true,
                          error: formError && selectedActivity == 'Selecione',
                          errorMessage:
                              formError && selectedActivity == 'Selecione'
                                  ? 'Campo obrigatório'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        if (result > 0)
                          CustomInput(
                            label: 'Resultado',
                            controller: TextEditingController(
                              text: '${result.toStringAsFixed(2)} kcal/dia',
                            ),
                            enabled: false,
                            keyboardType: TextInputType.none,
                          ),
                        const SizedBox(height: 20),
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
                                  onPressed: calculateGET,
                                ),
                              ],
                            ),
                          ],
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
