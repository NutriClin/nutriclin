import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/toast_util.dart';
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

  // Validação dos campos
  bool _kcalDiaError = false;
  bool _kcalKgError = false;
  bool _choError = false;
  bool _lipError = false;
  bool _ptnPorcentagemError = false;

  // Formatter para campos numéricos
  final FilteringTextInputFormatter _numerosFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));

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

  bool _validarCampos() {
    bool valido = true;

    if (kcalDiaController.text.trim().isEmpty) {
      _kcalDiaError = true;
      valido = false;
    } else {
      _kcalDiaError = false;
    }

    if (kcalKgController.text.trim().isEmpty) {
      _kcalKgError = true;
      valido = false;
    } else {
      _kcalKgError = false;
    }

    if (choController.text.trim().isEmpty) {
      _choError = true;
      valido = false;
    } else {
      _choError = false;
    }

    if (lipController.text.trim().isEmpty) {
      _lipError = true;
      valido = false;
    } else {
      _lipError = false;
    }

    if (ptnPorcentagemController.text.trim().isEmpty) {
      _ptnPorcentagemError = true;
      valido = false;
    } else {
      _ptnPorcentagemError = false;
    }

    setState(() {});
    return valido;
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
      print("Erro ao carregar requerimentos nutricionais: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarRequerimentosNutricionais(
        kcalDia: data['kcal_dia']?.toString() ?? '',
        kcalKg: data['kcal_kg']?.toString() ?? '',
        cho: data['cho']?.toString() ?? '',
        lip: data['lip']?.toString() ?? '',
        ptnPorcentagem: data['Ptn']?.toString() ?? '',
        ptnKg: data['ptn_kg']?.toString() ?? '',
        ptnDia: data['ptn_dia']?.toString() ?? '',
        liquidoKg: data['liquido_kg']?.toString() ?? '',
        liquidoDia: data['liquido_dia']?.toString() ?? '',
        fibras: data['fibras']?.toString() ?? '',
        outros: data['outros_requerimentos_nutricionais']?.toString() ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados =
          await _atendimentoService.carregarRequerimentosNutricionais();
      if (dados.isNotEmpty) {
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
    } catch (e) {
      print("Erro ao carregar dados locais: $e");
    }
  }

  Future<void> _salvarDadosLocais() async {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, preencha os campos obrigatórios!',
        isError: true,
      );
      return;
    }

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
            const Text('Erro ao carregar os requerimentos nutricionais'),
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
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                              error: _kcalDiaError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_kcalDiaError && value.isNotEmpty) {
                                  setState(() => _kcalDiaError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Kcal / kg',
                              controller: kcalKgController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                              error: _kcalKgError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_kcalKgError && value.isNotEmpty) {
                                  setState(() => _kcalKgError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'CHO %',
                              controller: choController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                              error: _choError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_choError && value.isNotEmpty) {
                                  setState(() => _choError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Lip %',
                              controller: lipController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                              error: _lipError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_lipError && value.isNotEmpty) {
                                  setState(() => _lipError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn %',
                              controller: ptnPorcentagemController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                              error: _ptnPorcentagemError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_ptnPorcentagemError && value.isNotEmpty) {
                                  setState(() => _ptnPorcentagemError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / kg',
                              controller: ptnKgController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Ptn g / dia',
                              controller: ptnDiaController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / kg',
                              controller: liquidoKgController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Líquido ml / dia',
                              controller: liquidoDiaController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Fibras g/dia',
                              controller: fibrasController,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [_numerosFormatter],
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
                                        if (podeEditar && !_validarCampos()) {
                                          return;
                                        }
                                        
                                        if (podeEditar) {
                                          await _salvarDadosLocais();
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RelatorioProfessorCondutaNutricionalPage(
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