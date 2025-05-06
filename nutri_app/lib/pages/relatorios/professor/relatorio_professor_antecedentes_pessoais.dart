import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_antecedentes_familiares.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class RelatorioProfessorAntecedentesPessoaisPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorAntecedentesPessoaisPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorAntecedentesPessoaisPageState createState() =>
      _RelatorioProfessorAntecedentesPessoaisPageState();
}

class _RelatorioProfessorAntecedentesPessoaisPageState
    extends State<RelatorioProfessorAntecedentesPessoaisPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _dislipidemias = false;
  bool _has = false;
  bool _cancer = false;
  bool _excessoPeso = false;
  bool _diabetes = false;
  bool _outros = false;
  final TextEditingController _outrosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isProfessor = false;
  bool isAluno = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDados();
    });
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
          _dislipidemias = data['dislipidemias'] ?? false;
          _has = data['has'] ?? false;
          _cancer = data['cancer'] ?? false;
          _excessoPeso = data['excesso_peso'] ?? false;
          _diabetes = data['diabetes'] ?? false;
          _outros = data['outros_antecedentes_pessoais'] ?? false;
          _outrosController.text = data['outros_antecedentes_pessoais_descricao'] ?? '';
          
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
      print("Erro ao carregar antecedentes pessoais: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    final dados = await _atendimentoService.carregarAntecedentesPessoais();
    setState(() {
      _dislipidemias = dados['dislipidemias'] ?? _dislipidemias;
      _has = dados['has'] ?? _has;
      _cancer = dados['cancer'] ?? _cancer;
      _excessoPeso = dados['excesso_peso'] ?? _excessoPeso;
      _diabetes = dados['diabetes'] ?? _diabetes;
      _outros = dados['outros_antecedentes_pessoais'] ?? _outros;
      _outrosController.text = dados['outros_antecedentes_pessoais_descricao'] ?? _outrosController.text;
    });
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarAntecedentesPessoais(
      dislipidemias: _dislipidemias,
      has: _has,
      cancer: _cancer,
      excessoPeso: _excessoPeso,
      diabetes: _diabetes,
      outros: _outros,
      outrosDescricao: _outrosController.text,
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
              const Text('Erro ao carregar os antecedentes pessoais'),
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
          title: 'Antecedentes Pessoais',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 3,
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
                            Column(
                              children: [
                                CustomSwitch(
                                  label: 'Dislipidemias',
                                  value: _dislipidemias,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _dislipidemias = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                CustomSwitch(
                                  label: 'HAS',
                                  value: _has,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _has = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                CustomSwitch(
                                  label: 'Câncer',
                                  value: _cancer,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _cancer = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                CustomSwitch(
                                  label: 'Excesso de peso',
                                  value: _excessoPeso,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _excessoPeso = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                CustomSwitch(
                                  label: 'Diabetes mellitus',
                                  value: _diabetes,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _diabetes = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                CustomSwitch(
                                  label: 'Outros',
                                  value: _outros,
                                  onChanged: camposEditaveis
                                      ? (value) => setState(() => _outros = value)
                                      : null,
                                  enabled: camposEditaveis,
                                ),
                                if (_outros)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: CustomInput(
                                      label: 'Especifique',
                                      controller: _outrosController,
                                      keyboardType: TextInputType.text,
                                      enabled: camposEditaveis,
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
                                    if (isAluno && isEditing) {
                                      _salvarDadosLocais();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RelatorioProfessorAntecedentesFamiliaresPage(
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