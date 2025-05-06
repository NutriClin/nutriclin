import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class RelatorioProfessorCondutaNutricionalPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorCondutaNutricionalPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorCondutaNutricionalPageState createState() =>
      _RelatorioProfessorCondutaNutricionalPageState();
}

class _RelatorioProfessorCondutaNutricionalPageState
    extends State<RelatorioProfessorCondutaNutricionalPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _estagiarioNomeController =
      TextEditingController();
  final TextEditingController _proximaConsultaController =
      TextEditingController();
  final TextEditingController _professorController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isSaving = false;
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
          _estagiarioNomeController.text = data['nome_aluno'] ?? '';
          _professorController.text = data['nome_professor'] ?? '';
          if (widget.isHospital) {
            _proximaConsultaController.text = data['proxima_consulta'] ?? '';
          }
          statusAtendimento = data['status_atendimento'] ?? '';
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
      print("Erro ao carregar dados: $e");
    }
  }

  Future<void> _atualizarStatus(String status) async {
    setState(() => isSaving = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await _firestore.collection(collection).doc(widget.atendimentoId).update({
        'status_atendimento': status,
        'data_avaliacao': FieldValue.serverTimestamp(),
      });

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento $status com sucesso!',
        isError: false,
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao atualizar status: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _enviarAtendimento() async {
    setState(() => isSaving = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await _firestore.collection(collection).doc(widget.atendimentoId).update({
        'status_atendimento': 'enviado',
      });

      await _atendimentoService.limparTodosDados();

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento enviado com sucesso!',
        isError: false,
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao enviar atendimento: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _estagiarioNomeController.dispose();
    _proximaConsultaController.dispose();
    _professorController.dispose();
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
          ),
        ),
      );
    }

    return Stack(
      children: [
        BasePage(
          title: 'Conduta Nutricional',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 9,
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
                              label: 'Aluno Responsável',
                              controller: _estagiarioNomeController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Professor Supervisor',
                              controller: _professorController,
                              enabled: false,
                            ),
                            if (widget.isHospital) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Programação próxima consulta',
                                controller: _proximaConsultaController,
                                enabled: false,
                              ),
                            ],
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
                                if (isProfessor)
                                  Row(
                                    children: [
                                      CustomButton(
                                        text: 'Rejeitar',
                                        onPressed: () =>
                                            _atualizarStatus('reprovado'),
                                        color: Colors.red,
                                        textColor: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      if (statusAtendimento == 'reprovado' ||
                                          statusAtendimento == 'rejeitado')
                                        CustomButton(
                                          text: 'Finalizar',
                                          onPressed: () =>
                                              _atualizarStatus('aprovado'),
                                        ),
                                    ],
                                  ),
                                if (isAluno && statusAtendimento == 'rejeitado')
                                  CustomButton(
                                    text: 'Enviar',
                                    onPressed: _enviarAtendimento,
                                    color: Colors.blue,
                                    textColor: Colors.white,
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
          modoLeitura: !(isProfessor && statusAtendimento == 'enviado'),
        ),
        if (isSaving)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isSaving)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
