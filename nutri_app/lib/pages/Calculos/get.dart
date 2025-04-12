import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_card.dart';
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

  void calculateGET() {
    final double weight = double.tryParse(weightController.text) ?? 0.0;
    final double height = double.tryParse(heightController.text) ?? 0.0;
    final int age = int.tryParse(ageController.text) ?? 0;

    bool hasError = false;

    // Validação dos campos
    if (weight <= 0) {
      hasError = true;
    }
    if (height <= 0) {
      hasError = true;
    }
    if (age <= 0) {
      hasError = true;
    }
    if (selectedGender == 'Selecione') {
      hasError = true;
    }
    if (selectedActivity == 'Selecione') {
      hasError = true;
    }

    setState(() {
      formError = hasError;
    });

    if (hasError) {
      ToastUtil.showToast(
        context: context,
        message: 'Preencha todos os campos obrigatórios',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      double tmb;
      if (selectedGender == 'Masculino') {
        tmb = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
      } else {
        tmb = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
      }

      double factor = switch (selectedActivity) {
        'Leve' => 1.375,
        'Moderada' => 1.55,
        'Intensa' => 1.725,
        _ => 1.2,
      };

      setState(() {
        result = tmb * factor;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth =
        screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.4;

    return Stack(
      children: [
        Scaffold(
          appBar: const CustomAppBar(title: 'GET - Gasto Energético Total'),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CustomCard(
                  width: cardWidth,
                  child: Column(
                    children: [
                      CustomDropdown(
                        label: 'Sexo:',
                        value: selectedGender,
                        items: ['Selecione', 'Masculino', 'Feminino'],
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        width: 80,
                        obrigatorio: true,
                        error: formError && selectedGender == 'Selecione',
                        errorMessage: formError && selectedGender == 'Selecione'
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomInput(
                        label: 'Idade:',
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        width: 80,
                        obrigatorio: true,
                        error: formError &&
                            (int.tryParse(ageController.text) ?? 0) <= 0,
                        errorMessage: formError &&
                                (int.tryParse(ageController.text) ?? 0) <= 0
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomInput(
                        label: 'Peso (kg):',
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        width: 80,
                        obrigatorio: true,
                        error: formError &&
                            (double.tryParse(weightController.text) ?? 0) <= 0,
                        errorMessage: formError &&
                                (double.tryParse(weightController.text) ?? 0) <=
                                    0
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomInput(
                        label: 'Estatura (cm):',
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        width: 80,
                        obrigatorio: true,
                        error: formError &&
                            (double.tryParse(heightController.text) ?? 0) <= 0,
                        errorMessage: formError &&
                                (double.tryParse(heightController.text) ?? 0) <=
                                    0
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomDropdown(
                        label: 'Atividade Física:',
                        value: selectedActivity,
                        items: ['Selecione', 'Leve', 'Moderada', 'Intensa'],
                        onChanged: (value) {
                          setState(() {
                            selectedActivity = value!;
                          });
                        },
                        width: 80,
                        obrigatorio: true,
                        error: formError && selectedActivity == 'Selecione',
                        errorMessage:
                            formError && selectedActivity == 'Selecione'
                                ? 'Campo obrigatório'
                                : null,
                      ),
                      const SizedBox(height: 20),
                      if (result > 0)
                        Text(
                          'GET: ${result.toStringAsFixed(2)} kcal/dia',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
                          CustomButton(
                            text: 'Calcular',
                            onPressed: calculateGET,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
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
