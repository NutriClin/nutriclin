import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
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
  final TextEditingController _estagiarioNomeController = TextEditingController();
  final TextEditingController _proximaConsultaController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isSaving = false;
  bool isProfessor = false;
  bool isAluno = false;

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
          _estagiarioNomeController.text = data['estagiario_nome'] ?? '';
          _professorController.text = data['professor_nome'] ?? '';
          if (widget.isHospital) {
            _proximaConsultaController.text = data['proxima_consulta'] ?? '';
          }
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
      print("Erro ao carregar conduta nutricional: $e");
    }
  }

  Future<void> _atualizarStatus(String status) async {
    setState(() => isSaving = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .update({
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
      // Carrega todos os dados salvos localmente
      final dadosCompletos = await _atendimentoService.obterDadosCompletos();
      
      // Atualiza o documento no Firestore
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .update(dadosCompletos);
      
      // Limpa os dados locais
      await _atendimentoService.limparTodosDados();
      
      // Atualiza o status para 'enviado'
      await _atualizarStatus('enviado');
      
      ToastUtil.showToast(
        context: context,
        message: 'Atendimento enviado com sucesso!',
        isError: false,
      );
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
  Widget build(BuildContext context) {
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
              const Text('Erro ao carregar a conduta nutricional'),
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
          title: 'Conduta Nutricional',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomCard(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                if (isProfessor)
                                  Row(
                                    children: [
                                      CustomButton(
                                        text: 'Reprovado',
                                        onPressed: () => _atualizarStatus('reprovado'),
                                        color: Colors.red,
                                        textColor: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      CustomButton(
                                        text: 'Aprovado',
                                        onPressed: () => _atualizarStatus('aprovado'),
                                      ),
                                    ],
                                  ),
                                if (isAluno)
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
          pageKey: 'conduta_nutricional',
          atendimentoId: widget.atendimentoId,
          isHospital: widget.isHospital,
          isFinalPage: true,
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