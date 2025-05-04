import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_requerimentos_nutricionais.dart';

class RelatorioProfessorConsumoAlimentarPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorConsumoAlimentarPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorConsumoAlimentarPageState createState() =>
      _RelatorioProfessorConsumoAlimentarPageState();
}

class _RelatorioProfessorConsumoAlimentarPageState
    extends State<RelatorioProfessorConsumoAlimentarPage> {
  final TextEditingController _habitualController = TextEditingController();
  final TextEditingController _atualController = TextEditingController();
  final TextEditingController _ingestaoHidricaController = TextEditingController();
  final TextEditingController _evacuacaoController = TextEditingController();
  final TextEditingController _diureseController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _habitualController.dispose();
    _atualController.dispose();
    _ingestaoHidricaController.dispose();
    _evacuacaoController.dispose();
    _diureseController.dispose();
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
          _habitualController.text = data['dia_alimentar_habitual'] ?? '';
          _atualController.text = data['dia_alimentar_atual'] ?? '';
          _ingestaoHidricaController.text = data['ingestao_hidrica']?.toString() ?? '';
          _evacuacaoController.text = data['evacuacao']?.toString() ?? '';
          _diureseController.text = data['diurese']?.toString() ?? '';
          
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
      print("Erro ao carregar dados de consumo alimentar: $e");
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
              const Text('Erro ao carregar os dados de consumo alimentar'),
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
      title: 'Consumo Alimentar',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 7,
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
                          label: 'Dia alimentar habitual:',
                          controller: _habitualController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Dia alimentar atual (Rec 24h):',
                          controller: _atualController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Ingestão hídrica',
                          controller: _ingestaoHidricaController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Evacuação',
                          controller: _evacuacaoController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Diurese',
                          controller: _diureseController,
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
                                    builder: (context) => RelatorioProfessorRequerimentosNutricionaisPage(
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