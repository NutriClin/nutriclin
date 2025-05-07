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
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
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
  bool modoEdicao = false;

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

          // Verifica se o aluno pode editar
          modoEdicao = isAluno && statusAtendimento == 'rejeitado';
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

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Function() onConfirm,
    String cancelText = 'Cancelar',
    Color confirmColor = const Color(0xFF007AFF),
    Color cancelColor = Colors.red,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        onConfirm: onConfirm,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _atualizarStatus(String status) async {
    setState(() => isSaving = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';

      final doc = await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();
      final dadosAtuais = doc.data() ?? {};

      final observacao = await _atendimentoService.carregarObservacao();

      final dadosAtualizados = {
        ...dadosAtuais,
        'status_atendimento': status,
        'data_avaliacao': FieldValue.serverTimestamp(),
        'observacao_geral': observacao ?? '',
      };

      await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .update(dadosAtualizados);

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento $status com sucesso!',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, '/relatorio');
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
      final dadosCompletos = await _atendimentoService.obterDadosCompletos();

      dadosCompletos.remove('id_professor_supervisor');
      dadosCompletos.remove('id_aluno');
      dadosCompletos.remove('nome_professor');
      dadosCompletos.remove('nome_aluno');
      dadosCompletos.remove('status_atendimento');
      dadosCompletos.remove('criado_em');
      dadosCompletos.remove('data');

      if (widget.isHospital) {
        dadosCompletos['proxima_consulta'] = _proximaConsultaController.text;
      }

      dadosCompletos['status_atendimento'] = 'enviado';
      dadosCompletos['observacao_geral'] = '';

      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .update(dadosCompletos);

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento enviado com sucesso para revisão!',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, '/relatorio');
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
                                enabled: modoEdicao,
                              ),
                            ],
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
                                    if (isProfessor &&
                                        statusAtendimento == 'enviado')
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          CustomButton(
                                            text: 'Rejeitar',
                                            onPressed: () =>
                                                _showConfirmationDialog(
                                              title: 'Confirmar Rejeição',
                                              message:
                                                  'Tem certeza que deseja rejeitar este atendimento?',
                                              confirmText: 'Rejeitar',
                                              confirmColor: Colors.red,
                                              onConfirm: () =>
                                                  _atualizarStatus('rejeitado'),
                                            ),
                                            color: Colors.red,
                                            textColor: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          CustomButton(
                                            text: 'Aprovar',
                                            onPressed: () =>
                                                _showConfirmationDialog(
                                              title: 'Confirmar Aprovação',
                                              message:
                                                  'Tem certeza que deseja aprovar este atendimento?',
                                              confirmText: 'Aprovar',
                                              onConfirm: () =>
                                                  _atualizarStatus('aprovado'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (modoEdicao) 
                                    const SizedBox(width: 10),
                                    if (modoEdicao)
                                      CustomButton(
                                        text: 'Enviar para Revisão',
                                        onPressed: () =>
                                            _showConfirmationDialog(
                                          title: 'Confirmar Envio',
                                          message:
                                              'Tem certeza que deseja enviar este atendimento para revisão?',
                                          confirmText: 'Enviar',
                                          onConfirm: _enviarAtendimento,
                                        ),
                                        color: Colors.blue,
                                        textColor: Colors.white,
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
            modoLeitura: modoEdicao,
            atendimentoId: widget.atendimentoId,
            isHospital: widget.isHospital,
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
