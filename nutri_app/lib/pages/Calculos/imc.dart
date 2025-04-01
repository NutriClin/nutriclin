import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_button.dart';

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

  void calculateIMC() {
    setState(() {
      double weight = double.tryParse(weightController.text) ?? 0;
      double height = double.tryParse(heightController.text) ?? 0;

      if (weight > 0 && height > 0) {
        double heightInMeters = height / 100;
        result = weight / (heightInMeters * heightInMeters);
        _setClassification(result);
      } else {
        result = 0.0;
        classification = '';
      }
    });
  }

  void _setClassification(double imc) {
    if (imc < 18.5) {
      classification = 'Abaixo do peso';
    } else if (imc < 25) {
      classification = 'Peso normal';
    } else if (imc < 30) {
      classification = 'Sobrepeso';
    } else if (imc < 35) {
      classification = 'Obesidade Grau I';
    } else if (imc < 40) {
      classification = 'Obesidade Grau II';
    } else {
      classification = 'Obesidade Grau III';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cálculo IMC',
      ),
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
              Row(
                children: [
                  const Text(
                    'Peso corporal(kg):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              Row(
                children: [
                  const Text(
                    'Estatura(cm):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              Row(
                children: [
                  const Text(
                    'IMC:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300, 
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result == 0.0 ? '' : result.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 16,
                          color: result == 0.0 ? Colors.grey.shade600 : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              Row(
                children: [
                  const Text(
                    'Classificação:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        classification.isEmpty ? '' : classification,
                        style: TextStyle(
                          fontSize: 16,
                          color: classification.isEmpty ? Colors.grey.shade600 : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              
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
                    onPressed: calculateIMC,
                    color: const Color(0xFF007AFF),
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