import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/toast_util.dart';

class HarrisBenedictPage extends StatefulWidget {
  const HarrisBenedictPage({super.key});

  @override
  _HarrisBenedictPageState createState() => _HarrisBenedictPageState();
}

class _HarrisBenedictPageState extends State<HarrisBenedictPage> {
  String selectedGender = 'Selecione';
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double result = 0.0;
  bool isLoading = false;
  bool formError = false;

  // Filtros
  final ageFilter = FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}$'));
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

  void calculateHarrisBenedict() {
    final double weight = double.tryParse(weightController.text) ?? 0.0;
    final double height = double.tryParse(heightController.text) ?? 0.0;
    final int age = int.tryParse(ageController.text) ?? 0;

    bool hasError =
        weight <= 0 || height <= 0 || age <= 0 || selectedGender == 'Selecione';

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

    // Cálculo da TMB usando a fórmula revisada de Mifflin-St Jeor
    Future.delayed(const Duration(milliseconds: 500), () {
      double tmb;
      if (selectedGender == 'Masculino') {
        tmb = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        tmb = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }
      setState(() {
        result = tmb;
        isLoading = false;
      });
    });
  }

  void clearFields() {
    setState(() {
      selectedGender = 'Selecione';
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
        BasePage(
          title: 'Harris-Benedict',
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
                          items: const ['Selecione', 'Masculino', 'Feminino'],
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
                        if (result > 0)
                          CustomInput(
                            label: 'Taxa Metabólica Basal',
                            controller: TextEditingController(
                              text: '${result.toStringAsFixed(2)} kcal/dia',
                            ),
                            enabled: false,
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
                                  onPressed: calculateHarrisBenedict,
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
