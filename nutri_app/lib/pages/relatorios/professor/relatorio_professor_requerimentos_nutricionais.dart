import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_conduta_nutricional.dart';

class RelatorioProfessorRequerimentosNutricionaisPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorRequerimentosNutricionaisPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorRequerimentosNutricionaisPageState createState() =>
      _RelatorioProfessorRequerimentosNutricionaisPageState();
}

class _RelatorioProfessorRequerimentosNutricionaisPageState
    extends State<RelatorioProfessorRequerimentosNutricionaisPage> {
  final TextEditingController _kcalDiaController = TextEditingController();
  final TextEditingController _kcalKgController = TextEditingController();
  final TextEditingController _choController = TextEditingController();
  final TextEditingController _lipController = TextEditingController();
  final TextEditingController _ptnPorcentagemController = TextEditingController();
  final TextEditingController _ptnKgController = TextEditingController();
  final TextEditingController _ptnDiaController = TextEditingController();
  final TextEditingController _liquidoKgController = TextEditingController();
  final TextEditingController _liquidoDiaController = TextEditingController();
  final TextEditingController _fibrasController = TextEditingController();
  final TextEditingController _outrosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _kcalDiaController.dispose();
    _kcalKgController.dispose();
    _choController.dispose();
    _lipController.dispose();
    _ptnPorcentagemController.dispose();
    _ptnKgController.dispose();
    _ptnDiaController.dispose();
    _liquidoKgController.dispose();
    _liquidoDiaController.dispose();
    _fibrasController.dispose();
    _outrosController.dispose();
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
          _kcalDiaController.text = data['kcal_dia']?.toString() ?? '';
          _kcalKgController.text = data['kcal_kg']?.toString() ?? '';
          _choController.text = data['cho']?.toString() ?? '';
          _lipController.text = data['lip']?.toString() ?? '';
          _ptnPorcentagemController.text = data['Ptn']?.toString() ?? '';
          _ptnKgController.text = data['ptn_kg']?.toString() ?? '';
          _ptnDiaController.text = data['ptn_dia']?.toString() ?? '';
          _liquidoKgController.text = data['liquido_kg']?.toString() ?? '';
          _liquidoDiaController.text = data['liquido_dia']?.toString() ?? '';
          _fibrasController.text = data['fibras']?.toString() ?? '';
          _outrosController.text = data['outros']?.toString() ?? '';
          
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
      print("Erro ao carregar requerimentos nutricionais: $e");
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
              const Text('Erro ao carregar os requerimentos nutricionais'),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        BasePage(
          title: 'Requerimentos Nutricionais',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 8,
                      totalSteps: 9,
                    ),
                    const SizedBox(height: 10),
                    CustomCard(
                      width: cardWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInput(
                              label: 'Kcal / dia',
                              controller: _kcalDiaController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Kcal / kg',
                              controller: _kcalKgController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CHO %',
                              controller: _choController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Lip %',
                              controller: _lipController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn %',
                              controller: _ptnPorcentagemController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / kg',
                              controller: _ptnKgController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / dia',
                              controller: _ptnDiaController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / kg',
                              controller: _liquidoKgController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / dia',
                              controller: _liquidoDiaController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Fibras g/dia',
                              controller: _fibrasController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Outros',
                              controller: _outrosController,
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
                                  textColor: Colors.red,
                                  boxShadowColor: Colors.black,
                                ),
                                CustomButton(
                                  text: 'Próximo',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RelatorioProfessorCondutaNutricionalPage(
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
        ),
        // Adiciona o componente de observações
        ObservacaoRelatorio(
          pageKey: 'requerimentos_nutricionais',
          atendimentoId: widget.atendimentoId,
          isHospital: widget.isHospital,
          isFinalPage: false,
        ),
      ],
    );
  }
}