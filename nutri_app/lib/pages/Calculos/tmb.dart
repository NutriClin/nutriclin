import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_button.dart';

class TMBPage extends StatefulWidget {
  const TMBPage({super.key});

  @override
  _TMBPageState createState() => _TMBPageState();
}

class _TMBPageState extends State<TMBPage> {
  String? selectedGender;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String result = '';

  void calculateTMB() {
    setState(() {
      int age = int.tryParse(ageController.text) ?? 0;
      double weight = double.tryParse(weightController.text) ?? 0;
      double height = double.tryParse(heightController.text) ?? 0;

      if (selectedGender != null && age > 0 && weight > 0 && height > 0) {
        if (selectedGender == 'masculino') {
          double tmb = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
          result = '${tmb.toStringAsFixed(2)} kcal';
        } else {
          double tmb = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
          result = '${tmb.toStringAsFixed(2)} kcal';
        }
      } else {
        result = 'Preencha todos os campos';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cálculo TMB',
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
                    'Sexo:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedGender = 'feminino';
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedGender == 'feminino' 
                                  ? Colors.blue 
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: selectedGender == 'feminino'
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('feminino'),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedGender = 'masculino';
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedGender == 'masculino' 
                                  ? Colors.blue 
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: selectedGender == 'masculino'
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('masculino'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              Row(
                children: [
                  const Text(
                    'Idade:',
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
                        controller: ageController,
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
                    'Resultado:',
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
                        result.isEmpty ? '' : result,
                        style: TextStyle(
                          fontSize: 16,
                          color: result.isEmpty ? Colors.grey.shade600 : Colors.black,
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
                    onPressed: calculateTMB,
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