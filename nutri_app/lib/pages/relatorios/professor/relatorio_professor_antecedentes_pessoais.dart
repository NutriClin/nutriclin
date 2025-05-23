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
import 'package:nutri_app/components/toast_util.dart';
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
  bool _outrosError = false;
  final TextEditingController _outrosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isProfessor = false;
  bool isAluno = false;
  String statusAtendimento = '';

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDadosAtendimento().then((_) {
        if (podeEditar) {
          _carregarDadosLocais();
        }
      });
    });
  }

  @override
  void dispose() {
    _outrosController.dispose();
    super.dispose();
  }

  Future<void> _checkUserType() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          isProfessor = userDoc.data()?['tipo_usuario'] == 'Professor';
          isAluno = userDoc.data()?['tipo_usuario'] == 'Aluno';
        });
      }
    }
  }

  Future<void> _carregarDadosAtendimento() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      final doc = await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          _dislipidemias = data['dislipidemias_pessoais'] ?? false;
          _has = data['has_pessoais'] ?? false;
          _cancer = data['cancer_pessoais'] ?? false;
          _excessoPeso = data['excesso_peso_pessoais'] ?? false;
          _diabetes = data['diabetes_pessoais'] ?? false;
          _outros = data['outros_antecedentes_pessoais'] ?? false;
          _outrosController.text =
              data['outros_antecedentes_pessoais_descricao'] ?? '';
          statusAtendimento = data['status_atendimento'] ?? '';

          isLoading = false;
        });

        if (isAluno && statusAtendimento == 'rejeitado') {
          await _salvarDadosFirestoreNoLocal(data);
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

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarAntecedentesPessoais(
        dislipidemias: data['dislipidemias_pessoais'] ?? false,
        has: data['has_pessoais'] ?? false,
        cancer: data['cancer_pessoais'] ?? false,
        excessoPeso: data['excesso_peso_pessoais'] ?? false,
        diabetes: data['diabetes_pessoais'] ?? false,
        outros: data['outros_antecedentes_pessoais'] ?? false,
        outrosDescricao: data['outros_antecedentes_pessoais_descricao'] ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados = await _atendimentoService.carregarAntecedentesPessoais();
      if (dados.isNotEmpty) {
        setState(() {
          _dislipidemias = dados['dislipidemias_pessoais'] ?? _dislipidemias;
          _has = dados['has_pessoais'] ?? _has;
          _cancer = dados['cancer_pessoais'] ?? _cancer;
          _excessoPeso = dados['excesso_peso_pessoais'] ?? _excessoPeso;
          _diabetes = dados['diabetes_pessoais'] ?? _diabetes;
          _outros = dados['outros_antecedentes_pessoais'] ?? _outros;
          _outrosController.text =
              dados['outros_antecedentes_pessoais_descricao'] ??
                  _outrosController.text;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados locais: $e");
    }
  }

  // Função de validação dos campos (adicionada)
  bool _validarCampos() {
    bool valido = true;

    if (_outros && _outrosController.text.trim().isEmpty) {
      setState(() => _outrosError = true);
      valido = false;
    } else {
      setState(() => _outrosError = false);
    }

    return valido;
  }

  Future<void> _salvarDadosLocais() async {
    if (!_validarCampos()) {
      return;
    }

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

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
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
            const Text('Erro ao carregar os antecedentes pessoais'),
            ElevatedButton(
              onPressed: _carregarDadosAtendimento,
              child: const Text('Tentar novamente'),
            ),
          ],
        )),
      );
    }

    return Stack(
      children: [
        BasePage(
          title: 'Antecedentes Pessoais',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 3,
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
                            CustomSwitch(
                              label: 'Dislipidemias',
                              value: _dislipidemias,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _dislipidemias = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'HAS',
                              value: _has,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _has = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Câncer',
                              value: _cancer,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _cancer = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Excesso de peso',
                              value: _excessoPeso,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _excessoPeso = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Diabetes mellitus',
                              value: _diabetes,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _diabetes = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Outros',
                              value: _outros,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _outros = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_outros)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: CustomInput(
                                  label: 'Especifique',
                                  controller: _outrosController,
                                  keyboardType: TextInputType.text,
                                  enabled: podeEditar,
                                  obrigatorio: true,
                                  error: _outrosError,
                                  errorMessage: 'Campo obrigatório',
                                  onChanged: (value) {
                                    if (_outrosError && value.isNotEmpty) {
                                      setState(() => _outrosError = false);
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  text: 'Sair',
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/relatorio'),
                                  color: Colors.white,
                                  textColor: Colors.red,
                                  boxShadowColor: Colors.black,
                                ),
                                Row(
                                  children: [
                                    CustomButton(
                                      text: 'Voltar',
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      boxShadowColor: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    CustomButton(
                                      text: 'Próximo',
                                      onPressed: () async {
                                        if (podeEditar) {
                                          if (!_validarCampos()) {
                                            ToastUtil.showToast(
                                              context: context,
                                              message:
                                                  'Por favor, verifique o formulário!',
                                              isError: true,
                                            );
                                            return;
                                          }
                                          await _salvarDadosLocais();
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RelatorioProfessorAntecedentesFamiliaresPage(
                                              atendimentoId:
                                                  widget.atendimentoId,
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
        if ((isAluno && statusAtendimento == 'rejeitado') ||
            (isProfessor && statusAtendimento == 'enviado'))
          ObservacaoRelatorio(
            modoLeitura: podeEditar,
            atendimentoId: widget.atendimentoId,
            isHospital: widget.isHospital,
          ),
      ],
    );
  }
}
