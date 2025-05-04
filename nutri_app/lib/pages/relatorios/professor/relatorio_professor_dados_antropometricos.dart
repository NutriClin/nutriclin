import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_consumo_alimentar.dart';

class RelatorioProfessorDadosAntropometricosPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorDadosAntropometricosPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorDadosAntropometricosPageState createState() =>
      _RelatorioProfessorDadosAntropometricosPageState();
}

class _RelatorioProfessorDadosAntropometricosPageState
    extends State<RelatorioProfessorDadosAntropometricosPage> {
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

  bool isLoading = true;
  bool hasError = false;

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
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        
        setState(() {
          _pesoAtualController.text = data['peso_atual']?.toString() ?? '';
          _pesoUsualController.text = data['peso_usual']?.toString() ?? '';
          _estaturaController.text = data['estatura']?.toString() ?? '';
          _imcController.text = data['imc']?.toString() ?? '';
          _piController.text = data['pi']?.toString() ?? '';
          _cbController.text = data['cb']?.toString() ?? '';
          _pctController.text = data['pct']?.toString() ?? '';
          _pcbController.text = data['pcb']?.toString() ?? '';
          _pcseController.text = data['pcse']?.toString() ?? '';
          _pcsiController.text = data['pcsi']?.toString() ?? '';
          _cmbController.text = data['cmb']?.toString() ?? '';
          _caController.text = data['ca']?.toString() ?? '';
          _cpController.text = data['cp']?.toString() ?? '';
          _ajController.text = data['aj']?.toString() ?? '';
          _percentualGorduraController.text = data['porcentagem_gc']?.toString() ?? '';
          _perdaPesoController.text = data['porcentagem_perca_peso_por_tempo']?.toString() ?? '';
          _diagnosticoNutricionalController.text = data['diagnostico_nutricional']?.toString() ?? '';
          
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Erro ao carregar dados antropométricos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erro ao carregar os dados antropométricos'),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

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
                        CustomInput(
                          label: 'Peso atual (kg)',
                          controller: _pesoAtualController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Peso usual (kg)',
                          controller: _pesoUsualController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Estatura (cm)',
                          controller: _estaturaController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'IMC',
                          controller: _imcController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PI',
                          controller: _piController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CB (cm)',
                          controller: _cbController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCT (mm)',
                          controller: _pctController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCB (mm)',
                          controller: _pcbController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSE (mm)',
                          controller: _pcseController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'PCSI (mm)',
                          controller: _pcsiController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CMB (cm)',
                          controller: _cmbController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CA (cm)',
                          controller: _caController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'CP (cm)',
                          controller: _cpController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'AJ (cm)',
                          controller: _ajController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% de GC',
                          controller: _percentualGorduraController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: '% perda peso/tempo',
                          controller: _perdaPesoController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Diagnóstico Nutricional',
                          controller: _diagnosticoNutricionalController,
                          enabled: false,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Voltar',
                              onPressed: () => Navigator.pop(context),
                              color: Colors.white,
                              textColor: Colors.red,
                              boxShadowColor: Colors.black,
                            ),
                            CustomButton(
                              text: 'Próximo',
                              onPressed: () {
                                // Navegar para a próxima página
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RelatorioProfessorConsumoAlimentarPage(
                                      atendimentoId: widget.atendimentoId,
                                      isHospital: widget.isHospital,
                                    ),
                                  ),
                                );
                              },
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