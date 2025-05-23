import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/toast_util.dart';
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
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController habitualController = TextEditingController();
  final TextEditingController atualController = TextEditingController();
  final TextEditingController ingestaoHidricaController =
      TextEditingController();
  final TextEditingController evacuacaoController = TextEditingController();
  final TextEditingController diureseController = TextEditingController();

  // Estados de validação
  bool _habitualError = false;
  bool _atualError = false;
  bool _ingestaoHidricaError = false;
  bool _evacuacaoError = false;
  bool _diureseError = false;

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
          habitualController.text = data['habitual'] ?? '';
          atualController.text = data['atual'] ?? '';
          ingestaoHidricaController.text =
              data['ingestao_hidrica']?.toString() ?? '';
          evacuacaoController.text = data['evacuacao']?.toString() ?? '';
          diureseController.text = data['diurese']?.toString() ?? '';
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
      print("Erro ao carregar consumo alimentar: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarConsumoAlimentar(
        habitual: data['habitual'] ?? '',
        atual: data['atual'] ?? '',
        ingestaoHidrica: data['ingestao_hidrica']?.toString() ?? '',
        evacuacao: data['evacuacao']?.toString() ?? '',
        diurese: data['diurese']?.toString() ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados = await _atendimentoService.carregarConsumoAlimentar();
      if (dados.isNotEmpty) {
        setState(() {
          habitualController.text =
              dados['habitual'] ?? habitualController.text;
          atualController.text = dados['atual'] ?? atualController.text;
          ingestaoHidricaController.text =
              dados['ingestao_hidrica'] ?? ingestaoHidricaController.text;
          evacuacaoController.text =
              dados['evacuacao'] ?? evacuacaoController.text;
          diureseController.text = dados['diurese'] ?? diureseController.text;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados locais: $e");
    }
  }

  // Função de validação dos campos
  bool _validarCampos() {
    bool valido = true;

    if (habitualController.text.trim().isEmpty) {
      _habitualError = true;
      valido = false;
    } else {
      _habitualError = false;
    }

    if (atualController.text.trim().isEmpty) {
      _atualError = true;
      valido = false;
    } else {
      _atualError = false;
    }

    if (ingestaoHidricaController.text.trim().isEmpty) {
      _ingestaoHidricaError = true;
      valido = false;
    } else {
      _ingestaoHidricaError = false;
    }

    if (evacuacaoController.text.trim().isEmpty) {
      _evacuacaoError = true;
      valido = false;
    } else {
      _evacuacaoError = false;
    }

    if (diureseController.text.trim().isEmpty) {
      _diureseError = true;
      valido = false;
    } else {
      _diureseError = false;
    }

    setState(() {});
    return valido;
  }

  Future<void> _salvarDadosLocais() async {
    if (!_validarCampos()) {
      return;
    }

    await _atendimentoService.salvarConsumoAlimentar(
      habitual: habitualController.text,
      atual: atualController.text,
      ingestaoHidrica: ingestaoHidricaController.text,
      evacuacao: evacuacaoController.text,
      diurese: diureseController.text,
    );
  }

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
  }

  @override
  void dispose() {
    habitualController.dispose();
    atualController.dispose();
    ingestaoHidricaController.dispose();
    evacuacaoController.dispose();
    diureseController.dispose();
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
            const Text('Erro ao carregar o consumo alimentar'),
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
          title: 'Consumo Alimentar',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 7,
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
                              label: 'Dia alimentar habitual',
                              controller: habitualController,
                              keyboardType: TextInputType.multiline,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _habitualError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_habitualError && value.isNotEmpty) {
                                  setState(() => _habitualError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Dia alimentar atual (Rec 24h)',
                              controller: atualController,
                              keyboardType: TextInputType.multiline,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _atualError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_atualError && value.isNotEmpty) {
                                  setState(() => _atualError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ingestão hídrica',
                              controller: ingestaoHidricaController,
                              keyboardType: TextInputType.text,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _ingestaoHidricaError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_ingestaoHidricaError && value.isNotEmpty) {
                                  setState(() => _ingestaoHidricaError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Evacuação',
                              controller: evacuacaoController,
                              keyboardType: TextInputType.text,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _evacuacaoError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_evacuacaoError && value.isNotEmpty) {
                                  setState(() => _evacuacaoError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Diurese',
                              controller: diureseController,
                              keyboardType: TextInputType.text,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _diureseError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_diureseError && value.isNotEmpty) {
                                  setState(() => _diureseError = false);
                                }
                              },
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
                                                RelatorioProfessorRequerimentosNutricionaisPage(
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
