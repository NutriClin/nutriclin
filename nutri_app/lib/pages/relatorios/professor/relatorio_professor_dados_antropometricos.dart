import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_consumo_alimentar.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          _percentualGorduraController.text =
              data['porcentagem_gc']?.toString() ?? '';
          _perdaPesoController.text =
              data['porcentagem_perca_peso_por_tempo']?.toString() ?? '';
          _diagnosticoNutricionalController.text =
              data['diagnostico_nutricional']?.toString() ?? '';

          statusAtendimento = data['status_atendimento'] ?? '';
          isLoading = false;
        });

        // Se for aluno e status rejeitado, salva os dados no armazenamento local
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
      print("Erro ao carregar dados antropométricos: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarDadosAntropometricos(
          pesoAtual: data['peso_atual']?.toString() ?? '',
          pesoUsual: data['peso_usual']?.toString() ?? '',
          estatura: data['estatura']?.toString() ?? '',
          imc: data['imc']?.toString() ?? '',
          pi: data['pi']?.toString() ?? '',
          cb: data['cb']?.toString() ?? '',
          pct: data['pct']?.toString() ?? '',
          pcb: data['pcb']?.toString() ?? '',
          pcse: data['pcse']?.toString() ?? '',
          pcsi: data['pcsi']?.toString() ?? '',
          cmb: data['cmb']?.toString() ?? '',
          ca: data['ca']?.toString() ?? '',
          cp: data['cp']?.toString() ?? '',
          aj: data['aj']?.toString() ?? '',
          percentualGordura: data['porcentagem_gc']?.toString() ?? '',
          perdaPeso: data['porcentagem_perca_peso_por_tempo']?.toString() ?? '',
          diagnosticoNutricional:
              data['diagnostico_nutricional']?.toString() ?? '');
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados = await _atendimentoService.carregarDadosAntropometricos();
      if (dados.isNotEmpty) {
        setState(() {
          _pesoAtualController.text =
              dados['peso_atual'] ?? _pesoAtualController.text;
          _pesoUsualController.text =
              dados['peso_usual'] ?? _pesoUsualController.text;
          _estaturaController.text =
              dados['estatura'] ?? _estaturaController.text;
          _imcController.text = dados['imc'] ?? _imcController.text;
          _piController.text = dados['pi'] ?? _piController.text;
          _cbController.text = dados['cb'] ?? _cbController.text;
          _pctController.text = dados['pct'] ?? _pctController.text;
          _pcbController.text = dados['pcb'] ?? _pcbController.text;
          _pcseController.text = dados['pcse'] ?? _pcseController.text;
          _pcsiController.text = dados['pcsi'] ?? _pcsiController.text;
          _cmbController.text = dados['cmb'] ?? _cmbController.text;
          _caController.text = dados['ca'] ?? _caController.text;
          _cpController.text = dados['cp'] ?? _cpController.text;
          _ajController.text = dados['aj'] ?? _ajController.text;
          _percentualGorduraController.text =
              dados['porcentagem_gc'] ?? _percentualGorduraController.text;
          _perdaPesoController.text =
              dados['porcentagem_perca_peso_por_tempo'] ??
                  _perdaPesoController.text;
          _diagnosticoNutricionalController.text =
              dados['diagnostico_nutricional'] ??
                  _diagnosticoNutricionalController.text;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados locais: $e");
    }
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarDadosAntropometricos(
      pesoAtual: _pesoAtualController.text,
      pesoUsual: _pesoUsualController.text,
      estatura: _estaturaController.text,
      imc: _imcController.text,
      pi: _piController.text,
      cb: _cbController.text,
      pct: _pctController.text,
      pcb: _pcbController.text,
      pcse: _pcseController.text,
      pcsi: _pcsiController.text,
      cmb: _cmbController.text,
      ca: _caController.text,
      cp: _cpController.text,
      aj: _ajController.text,
      percentualGordura: _percentualGorduraController.text,
      perdaPeso: _perdaPesoController.text,
      diagnosticoNutricional: _diagnosticoNutricionalController.text,
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
              const Text('Erro ao carregar os dados antropométricos'),
              ElevatedButton(
                onPressed: _carregarDadosAtendimento,
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
          title: 'Dados Antropométricos',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
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
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Peso usual (kg)',
                              controller: _pesoUsualController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Estatura (cm)',
                              controller: _estaturaController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'IMC',
                              controller: _imcController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'PI',
                              controller: _piController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CB (cm)',
                              controller: _cbController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'PCT (mm)',
                              controller: _pctController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'PCB (mm)',
                              controller: _pcbController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'PCSE (mm)',
                              controller: _pcseController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'PCSI (mm)',
                              controller: _pcsiController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CMB (cm)',
                              controller: _cmbController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CA (cm)',
                              controller: _caController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CP (cm)',
                              controller: _cpController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'AJ (cm)',
                              controller: _ajController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: '% de GC',
                              controller: _percentualGorduraController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: '% perda peso/tempo',
                              controller: _perdaPesoController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Diagnóstico Nutricional',
                              controller: _diagnosticoNutricionalController,
                              enabled: podeEditar,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  text: 'Voltar',
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  boxShadowColor: Colors.black,
                                ),
                                CustomButton(
                                  text: 'Próximo',
                                  onPressed: () async {
                                    if (podeEditar) {
                                      await _salvarDadosLocais();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RelatorioProfessorConsumoAlimentarPage(
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
