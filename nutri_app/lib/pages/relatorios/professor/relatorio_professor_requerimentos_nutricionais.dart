import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_conduta_nutricional.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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
  bool isProfessor = false;
  bool isAluno = false;
  bool isEditing = false;

  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDados();
    });
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

  Future<void> _checkUserType() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          isProfessor = userDoc.data()?['tipo_usuario'] == 'Professor';
          isAluno = userDoc.data()?['tipo_usuario'] == 'Aluno';
        });
      }
    }
  }

  Future<void> _carregarDados() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      final doc = await _firestore
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
          _outrosController.text = data['outros_requerimentos_nutricionais']?.toString() ?? '';
          
          isLoading = false;
        });

        if (isAluno) {
          await _carregarDadosLocais();
        }
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

  Future<void> _carregarDadosLocais() async {
    final dados = await _atendimentoService.carregarRequerimentosNutricionais();
    setState(() {
      _kcalDiaController.text = dados['kcal_dia'] ?? _kcalDiaController.text;
      _kcalKgController.text = dados['kcal_kg'] ?? _kcalKgController.text;
      _choController.text = dados['cho'] ?? _choController.text;
      _lipController.text = dados['lip'] ?? _lipController.text;
      _ptnPorcentagemController.text = dados['Ptn'] ?? _ptnPorcentagemController.text;
      _ptnKgController.text = dados['ptn_kg'] ?? _ptnKgController.text;
      _ptnDiaController.text = dados['ptn_dia'] ?? _ptnDiaController.text;
      _liquidoKgController.text = dados['liquido_kg'] ?? _liquidoKgController.text;
      _liquidoDiaController.text = dados['liquido_dia'] ?? _liquidoDiaController.text;
      _fibrasController.text = dados['fibras'] ?? _fibrasController.text;
      _outrosController.text = dados['outros'] ?? _outrosController.text;
    });
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarRequerimentosNutricionais(
      kcalDia: _kcalDiaController.text,
      kcalKg: _kcalKgController.text,
      cho: _choController.text,
      lip: _lipController.text,
      ptnPorcentagem: _ptnPorcentagemController.text,
      ptnKg: _ptnKgController.text,
      ptnDia: _ptnDiaController.text,
      liquidoKg: _liquidoKgController.text,
      liquidoDia: _liquidoDiaController.text,
      fibras: _fibrasController.text,
      outros: _outrosController.text,
    );
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        _salvarDadosLocais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;
    final bool camposEditaveis = isAluno && isEditing;
    final bool mostrarBotaoEditar = isAluno;

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
                    if (mostrarBotaoEditar) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: _toggleEditing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditing ? Colors.green : Colors.blue,
                            ),
                            child: Text(
                              isEditing ? 'Salvar' : 'Editar',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(height: espacamentoCards),
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
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Kcal / kg',
                              controller: _kcalKgController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CHO %',
                              controller: _choController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Lip %',
                              controller: _lipController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn %',
                              controller: _ptnPorcentagemController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / kg',
                              controller: _ptnKgController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / dia',
                              controller: _ptnDiaController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / kg',
                              controller: _liquidoKgController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / dia',
                              controller: _liquidoDiaController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Fibras g/dia',
                              controller: _fibrasController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Outros',
                              controller: _outrosController,
                              enabled: camposEditaveis,
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
                                    if (isAluno && isEditing) {
                                      _salvarDadosLocais();
                                    }
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
        ObservacaoRelatorio(
          pageKey: 'requerimentos_nutricionais',
          atendimentoId: widget.atendimentoId,
          isHospital: widget.isHospital,
          isFinalPage: false,
          modoLeitura: isAluno,
        ),
      ],
    );
  }
}