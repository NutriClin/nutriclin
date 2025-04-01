import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_button.dart';

class GETPage extends StatefulWidget {
  const GETPage({super.key});

  @override
  _GETPageState createState() => _GETPageState();
}

class _GETPageState extends State<GETPage> {
  String? selectedGender;
  String? selectedActivity;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double result = 0.0;

  void calculateGET() {
    final double weight = double.tryParse(weightController.text) ?? 0.0;
    final double height = double.tryParse(heightController.text) ?? 0.0;
    final int age = int.tryParse(ageController.text) ?? 0;

    if (weight > 0 &&
        height > 0 &&
        age > 0 &&
        selectedGender != null &&
        selectedActivity != null) {
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
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(String label, List<String> options,
      String? selectedValue, Function(String) onSelect) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: options.map((option) {
              bool isSelected = selectedValue == option;
              return Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => onSelect(option)),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 18, color: Colors.blue)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(option),
                  const SizedBox(width: 10),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'GET'),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSelectionRow('Sexo:', ['Masculino', 'Feminino'],
                  selectedGender, (value) => selectedGender = value),
              const SizedBox(height: 20),
              _buildTextField('Idade:', ageController),
              const SizedBox(height: 20),
              _buildTextField('Peso (kg):', weightController),
              const SizedBox(height: 20),
              _buildTextField('Estatura (cm):', heightController),
              const SizedBox(height: 20),
              _buildSelectionRow(
                  'Atividade Física:',
                  ['Leve', 'Moderada', 'Intensa'],
                  selectedActivity,
                  (value) => selectedActivity = value),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Calcular',
                    onPressed: calculateGET,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}