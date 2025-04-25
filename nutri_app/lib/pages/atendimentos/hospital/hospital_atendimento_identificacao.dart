import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_socioeconomico.dart';

class HospitalAtendimentoIdentificacaoPage extends StatefulWidget {
  const HospitalAtendimentoIdentificacaoPage({super.key});

  @override
  _HospitalAtendimentoIdentificacaoPageState createState() =>
      _HospitalAtendimentoIdentificacaoPageState();
}

class _HospitalAtendimentoIdentificacaoPageState
    extends State<HospitalAtendimentoIdentificacaoPage> {
  String selectedGender = 'Selecione';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController recordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    hospitalController.dispose();
    clinicController.dispose();
    roomController.dispose();
    bedController.dispose();
    recordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        birthDateController.text = formattedDate;
      });
    }
  }

  void proceedToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoDadosSocioeconomicoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    return BasePage(
      title: 'Identificação',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 1,
                  totalSteps: 9,
                ),
                SizedBox(height: espacamentoCards),
                CustomCard(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Nome',
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          obrigatorio: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Sexo',
                          value: selectedGender,
                          items: const ['Selecione', 'Masculino', 'Feminino'],
                          onChanged: (value) =>
                              setState(() => selectedGender = value!),
                          obrigatorio: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomInput(
                              label: 'Data Nasc',
                              controller: birthDateController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'DD/MM/AAAA',
                              obrigatorio: true,
                            ),
                          ),
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Hospital',
                          controller: hospitalController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Clínica',
                          controller: clinicController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Quarto',
                          controller: roomController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Leito',
                          controller: bedController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Registro',
                          controller: bedController,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Cancelar',
                              onPressed: () => Navigator.pop(context),
                              color: Colors.white,
                              textColor: Colors.red,
                              boxShadowColor: Colors.black,
                            ),
                            CustomButton(
                              text: 'Próximo',
                              onPressed: proceedToNext,
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
