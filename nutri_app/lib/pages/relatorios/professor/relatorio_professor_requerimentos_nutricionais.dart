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
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController kcalDiaController = TextEditingController();
  final TextEditingController kcalKgController = TextEditingController();
  final TextEditingController choController = TextEditingController();
  final TextEditingController lipController = TextEditingController();
  final TextEditingController ptnPorcentagemController =
      TextEditingController();
  final TextEditingController ptnKgController = TextEditingController();
  final TextEditingController ptnDiaController = TextEditingController();
  final TextEditingController liquidoKgController = TextEditingController();
  final TextEditingController liquidoDiaController = TextEditingController();
  final TextEditingController fibrasController = TextEditingController();
  final TextEditingController outrosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isProfessor = false;
  bool isAluno = false;
  String statusAtendimento = '';

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDadosAtendimento();
    });
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
          kcalDiaController.text = data['kcal_dia']?.toString() ?? '';
          kcalKgController.text = data['kcal_kg']?.toString() ?? '';
          choController.text = data['cho']?.toString() ?? '';
          lipController.text = data['lip']?.toString() ?? '';
          ptnPorcentagemController.text = data['Ptn']?.toString() ?? '';
          ptnKgController.text = data['ptn_kg']?.toString() ?? '';
          ptnDiaController.text = data['ptn_dia']?.toString() ?? '';
          liquidoKgController.text = data['liquido_kg']?.toString() ?? '';
          liquidoDiaController.text = data['liquido_dia']?.toString() ?? '';
          fibrasController.text = data['fibras']?.toString() ?? '';
          outrosController.text =
              data['outros_requerimentos_nutricionais']?.toString() ?? '';
          statusAtendimento = data['status_atendimento'] ?? '';

          isLoading = false;
        });

        if (isAluno && statusAtendimento == 'rejeitado') {
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
      print("Erro ao carregar dados: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    final dados = await _atendimentoService.carregarRequerimentosNutricionais();
    setState(() {
      kcalDiaController.text = dados['kcal_dia'] ?? kcalDiaController.text;
      kcalKgController.text = dados['kcal_kg'] ?? kcalKgController.text;
      choController.text = dados['cho'] ?? choController.text;
      lipController.text = dados['lip'] ?? lipController.text;
      ptnPorcentagemController.text =
          dados['Ptn'] ?? ptnPorcentagemController.text;
      ptnKgController.text = dados['ptn_kg'] ?? ptnKgController.text;
      ptnDiaController.text = dados['ptn_dia'] ?? ptnDiaController.text;
      liquidoKgController.text =
          dados['liquido_kg'] ?? liquidoKgController.text;
      liquidoDiaController.text =
          dados['liquido_dia'] ?? liquidoDiaController.text;
      fibrasController.text = dados['fibras'] ?? fibrasController.text;
      outrosController.text = dados['outros'] ?? outrosController.text;
    });
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarRequerimentosNutricionais(
      kcalDia: kcalDiaController.text,
      kcalKg: kcalKgController.text,
      cho: choController.text,
      lip: lipController.text,
      ptnPorcentagem: ptnPorcentagemController.text,
      ptnKg: ptnKgController.text,
      ptnDia: ptnDiaController.text,
      liquidoKg: liquidoKgController.text,
      liquidoDia: liquidoDiaController.text,
      fibras: fibrasController.text,
      outros: outrosController.text,
    );
  }

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
  }

  @override
  void dispose() {
    kcalDiaController.dispose();
    kcalKgController.dispose();
    choController.dispose();
    lipController.dispose();
    ptnPorcentagemController.dispose();
    ptnKgController.dispose();
    ptnDiaController.dispose();
    liquidoKgController.dispose();
    liquidoDiaController.dispose();
    fibrasController.dispose();
    outrosController.dispose();
    super.dispose();
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
            const Text('Erro ao carregar o atendimento'),
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
          title: 'Requerimentos Nutricionais',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 8,
                      totalSteps: 9,
                    ),
                    SizedBox(height: espacamentoCards),
                    CustomCard(
                      width: cardWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Kcal / dia',
                              controller: kcalDiaController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Kcal / kg',
                              controller: kcalKgController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CHO %',
                              controller: choController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Lip %',
                              controller: lipController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn %',
                              controller: ptnPorcentagemController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / kg',
                              controller: ptnKgController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / dia',
                              controller: ptnDiaController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / kg',
                              controller: liquidoKgController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / dia',
                              controller: liquidoDiaController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Fibras g/dia',
                              controller: fibrasController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Outros',
                              controller: outrosController,
                              keyboardType: TextInputType.text,
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
                                            RelatorioProfessorCondutaNutricionalPage(
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
