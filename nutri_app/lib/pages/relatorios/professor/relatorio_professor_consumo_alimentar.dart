import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_requerimentos_nutricionais.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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
    _habitualController.dispose();
    _atualController.dispose();
    _ingestaoHidricaController.dispose();
    _evacuacaoController.dispose();
    _diureseController.dispose();
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
          _habitualController.text = data['dia_alimentar_habitual'] ?? '';
          _atualController.text = data['dia_alimentar_atual'] ?? '';
          _ingestaoHidricaController.text = data['ingestao_hidrica']?.toString() ?? '';
          _evacuacaoController.text = data['evacuacao']?.toString() ?? '';
          _diureseController.text = data['diurese']?.toString() ?? '';
          
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
      print("Erro ao carregar dados de consumo alimentar: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    final dados = await _atendimentoService.carregarConsumoAlimentar();
    setState(() {
      _habitualController.text = dados['habitual'] ?? _habitualController.text;
      _atualController.text = dados['atual'] ?? _atualController.text;
      _ingestaoHidricaController.text = dados['ingestao_hidrica'] ?? _ingestaoHidricaController.text;
      _evacuacaoController.text = dados['evacuacao'] ?? _evacuacaoController.text;
      _diureseController.text = dados['diurese'] ?? _diureseController.text;
    });
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarConsumoAlimentar(
      habitual: _habitualController.text,
      atual: _atualController.text,
      ingestaoHidrica: _ingestaoHidricaController.text,
      evacuacao: _evacuacaoController.text,
      diurese: _diureseController.text,
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

    return Stack(
      children: [
        BasePage(
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
                              label: 'Dia alimentar habitual:',
                              controller: _habitualController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Dia alimentar atual (Rec 24h):',
                              controller: _atualController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ingestão hídrica',
                              controller: _ingestaoHidricaController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Evacuação',
                              controller: _evacuacaoController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Diurese',
                              controller: _diureseController,
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
        ),
        ObservacaoRelatorio(
          modoLeitura: isAluno,
        ),
      ],
    );
  }
}