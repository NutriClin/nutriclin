import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_dados_clinicos_nutricionais.dart';

class RelatorioProfessorAntecedentesFamiliaresPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorAntecedentesFamiliaresPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorAntecedentesFamiliaresPageState createState() =>
      _RelatorioProfessorAntecedentesFamiliaresPageState();
}

class _RelatorioProfessorAntecedentesFamiliaresPageState
    extends State<RelatorioProfessorAntecedentesFamiliaresPage> {
  bool _dislipidemias = false;
  bool _has = false;
  bool _cancer = false;
  bool _excessoPeso = false;
  bool _diabetes = false;
  bool _outros = false;
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
          _dislipidemias = data['dislipidemias'] ?? false;
          _has = data['has'] ?? false;
          _cancer = data['cancer'] ?? false;
          _excessoPeso = data['excesso_peso'] ?? false;
          _diabetes = data['diabetes'] ?? false;
          _outros = data['outros'] ?? false; // Verificar se este campo está correto
          _outrosController.text = data['outros_descricao'] ?? ''; // Verificar se este campo está correto
          
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
      print("Erro ao carregar antecedentes familiares: $e");
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
              const Text('Erro ao carregar os antecedentes familiares'),
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
      title: 'Antecedentes Familiares (1º e 2º grau)',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 4,
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
                        Column(
                          children: [
                            CustomSwitch(
                              label: 'Dislipidemias',
                              value: _dislipidemias,
                              onChanged: null, // Desabilita alteração
                              enabled: false,
                            ),
                            CustomSwitch(
                              label: 'HAS',
                              value: _has,
                              onChanged: null,
                              enabled: false,
                            ),
                            CustomSwitch(
                              label: 'Câncer',
                              value: _cancer,
                              onChanged: null,
                              enabled: false,
                            ),
                            CustomSwitch(
                              label: 'Excesso de peso',
                              value: _excessoPeso,
                              onChanged: null,
                              enabled: false,
                            ),
                            CustomSwitch(
                              label: 'Diabetes mellitus',
                              value: _diabetes,
                              onChanged: null,
                              enabled: false,
                            ),
                            CustomSwitch(
                              label: 'Outros',
                              value: _outros,
                              onChanged: null,
                              enabled: false,
                            ),
                            if (_outros)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: CustomInput(
                                  label: 'Especifique',
                                  controller: _outrosController,
                                  keyboardType: TextInputType.text,
                                  enabled: false, // Campo apenas leitura
                                ),
                              ),
                          ],
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
                                    builder: (context) => RelatorioProfessorDadosClinicosNutricionaisPage(
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