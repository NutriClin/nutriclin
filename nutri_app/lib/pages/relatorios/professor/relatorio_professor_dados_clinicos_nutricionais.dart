import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_dados_antropometricos.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class RelatorioProfessorDadosClinicosNutricionaisPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorDadosClinicosNutricionaisPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorDadosClinicosNutricionaisPageState createState() =>
      _RelatorioProfessorDadosClinicosNutricionaisPageState();
}

class _RelatorioProfessorDadosClinicosNutricionaisPageState
    extends State<RelatorioProfessorDadosClinicosNutricionaisPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers para campos de texto
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _prescricaoController = TextEditingController();
  final TextEditingController _alimentacaoHabitualController =
      TextEditingController();
  final TextEditingController _doencaAnteriorController =
      TextEditingController();
  final TextEditingController _cirurgiaController = TextEditingController();
  final TextEditingController _quantoPesoController = TextEditingController();
  final TextEditingController _qualDietaController = TextEditingController();
  final TextEditingController _tipoSuplementacaoController =
      TextEditingController();
  final TextEditingController _especificarCondicaoController =
      TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _examesLaboratoriaisController =
      TextEditingController();
  final TextEditingController _exameFisicoController = TextEditingController();

  // Estados para dropdowns
  String selectedAlimentacaoHabitual = 'Selecione';
  String selectedCondicaoFuncional = 'Selecione';
  String selectedAceitacao = 'Selecione';

  // Estados para os switches
  bool _doencaAnterior = false;
  bool _cirurgiaRecente = false;
  bool _febre = false;
  bool _alteracaoPeso = false;
  bool _desconforto = false;
  bool _necessidadeDieta = false;
  bool _suplementacao = false;
  bool _tabagismo = false;
  bool _etilismo = false;

  // Estados de validação
  bool _diagnosticoError = false;
  bool _prescricaoError = false;
  bool _aceitacaoError = false;
  bool _alimentacaoError = false;
  bool _doencaAnteriorError = false;
  bool _cirurgiaError = false;
  bool _quantoPesoError = false;
  bool _qualDietaError = false;
  bool _tipoSuplementacaoError = false;
  bool _especificarCondicaoError = false;

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
    _diagnosticoController.dispose();
    _prescricaoController.dispose();
    _alimentacaoHabitualController.dispose();
    _doencaAnteriorController.dispose();
    _cirurgiaController.dispose();
    _quantoPesoController.dispose();
    _qualDietaController.dispose();
    _tipoSuplementacaoController.dispose();
    _especificarCondicaoController.dispose();
    _medicamentosController.dispose();
    _examesLaboratoriaisController.dispose();
    _exameFisicoController.dispose();
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
          // Text controllers
          _diagnosticoController.text = data['diagnostico_clinico'] ?? '';
          _prescricaoController.text = data['prescricao_dietoterapica'] ?? '';
          _alimentacaoHabitualController.text =
              data['resumo_alimentacao_habitual'] ?? '';
          _doencaAnteriorController.text = data['resumo_doenca_anterior'] ?? '';
          _cirurgiaController.text = data['resumo_cirurgia_recente'] ?? '';
          _quantoPesoController.text =
              data['quantidade_perca_peso_recente'] ?? '';
          _qualDietaController.text =
              data['resumo_necessidade_dieta_hospitalar'] ?? '';
          _tipoSuplementacaoController.text =
              data['resumo_suplemento_nutricional'] ?? '';
          _especificarCondicaoController.text =
              data['resumo_condicao_funcional'] ?? '';
          _medicamentosController.text =
              data['resumo_medicamentos_vitaminas_minerais_prescritos'] ?? '';
          _examesLaboratoriaisController.text =
              data['resumo_exames_laboratoriais'] ?? '';
          _exameFisicoController.text = data['resumo_exame_fisico'] ?? '';

          // Dropdowns
          selectedAceitacao = data['aceitacao'] ?? 'Selecione';
          selectedAlimentacaoHabitual =
              data['alimentacao_habitual'] ?? 'Selecione';
          selectedCondicaoFuncional =
              data['possui_condicao_funcional'] ?? 'Selecione';

          // Switches
          _doencaAnterior = data['possui_doenca_anterior'] ?? false;
          _cirurgiaRecente = data['possui_cirurgia_recente'] ?? false;
          _febre = data['possui_febre'] ?? false;
          _alteracaoPeso = data['possui_alteracao_peso_recente'] ?? false;
          _desconforto =
              data['possui_desconforto_oral_gastrointestinal'] ?? false;
          _necessidadeDieta =
              data['possui_necessidade_dieta_hospitalar'] ?? false;
          _suplementacao = data['possui_suplementacao_nutricional'] ?? false;
          _tabagismo = data['possui_tabagismo'] ?? false;
          _etilismo = data['possui_etilismo'] ?? false;

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
      print("Erro ao carregar dados clínicos/nutricionais: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarDadosClinicosNutricionais(
        diagnostico: data['diagnostico_clinico'] ?? '',
        prescricao: data['prescricao_dietoterapica'] ?? '',
        aceitacao: data['aceitacao'] ?? 'Selecione',
        alimentacaoHabitual: data['alimentacao_habitual'] ?? 'Selecione',
        especificarAlimentacao: data['resumo_alimentacao_habitual'] ?? '',
        doencaAnterior: data['possui_doenca_anterior'] ?? false,
        doencaAnteriorDesc: data['resumo_doenca_anterior'] ?? '',
        cirurgiaRecente: data['possui_cirurgia_recente'] ?? false,
        cirurgiaDesc: data['resumo_cirurgia_recente'] ?? '',
        febre: data['possui_febre'] ?? false,
        alteracaoPeso: data['possui_alteracao_peso_recente'] ?? false,
        quantoPeso: data['quantidade_perca_peso_recente'] ?? '',
        desconfortos: data['possui_desconforto_oral_gastrointestinal'] ?? false,
        necessidadeDieta: data['possui_necessidade_dieta_hospitalar'] ?? false,
        qualDieta: data['resumo_necessidade_dieta_hospitalar'] ?? '',
        suplementacao: data['possui_suplementacao_nutricional'] ?? false,
        tipoSuplementacao: data['resumo_suplemento_nutricional'] ?? '',
        tabagismo: data['possui_tabagismo'] ?? false,
        etilismo: data['possui_etilismo'] ?? false,
        condicaoFuncional: data['possui_condicao_funcional'] ?? 'Selecione',
        especificarCondicao: data['resumo_condicao_funcional'] ?? '',
        medicamentos:
            data['resumo_medicamentos_vitaminas_minerais_prescritos'] ?? '',
        examesLaboratoriais: data['resumo_exames_laboratoriais'] ?? '',
        exameFisico: data['resumo_exame_fisico'] ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados =
          await _atendimentoService.carregarDadosClinicosNutricionais();
      if (dados.isNotEmpty) {
        setState(() {
          // Text controllers
          _diagnosticoController.text =
              dados['diagnostico_clinico'] ?? _diagnosticoController.text;
          _prescricaoController.text =
              dados['prescricao_dietoterapica'] ?? _prescricaoController.text;
          _alimentacaoHabitualController.text =
              dados['resumo_alimentacao_habitual'] ??
                  _alimentacaoHabitualController.text;
          _doencaAnteriorController.text =
              dados['resumo_doenca_anterior'] ?? _doencaAnteriorController.text;
          _cirurgiaController.text =
              dados['resumo_cirurgia_recente'] ?? _cirurgiaController.text;
          _quantoPesoController.text = dados['quantidade_perca_peso_recente'] ??
              _quantoPesoController.text;
          _qualDietaController.text =
              dados['resumo_necessidade_dieta_hospitalar'] ??
                  _qualDietaController.text;
          _tipoSuplementacaoController.text =
              dados['resumo_suplemento_nutricional'] ??
                  _tipoSuplementacaoController.text;
          _especificarCondicaoController.text =
              dados['resumo_condicao_funcional'] ??
                  _especificarCondicaoController.text;
          _medicamentosController.text =
              dados['resumo_medicamentos_vitaminas_minerais_prescritos'] ??
                  _medicamentosController.text;
          _examesLaboratoriaisController.text =
              dados['resumo_exames_laboratoriais'] ??
                  _examesLaboratoriaisController.text;
          _exameFisicoController.text =
              dados['resumo_exame_fisico'] ?? _exameFisicoController.text;

          // Dropdowns
          selectedAceitacao = dados['aceitacao'] ?? selectedAceitacao;
          selectedAlimentacaoHabitual =
              dados['alimentacao_habitual'] ?? selectedAlimentacaoHabitual;
          selectedCondicaoFuncional =
              dados['possui_condicao_funcional'] ?? selectedCondicaoFuncional;

          // Switches
          _doencaAnterior = dados['possui_doenca_anterior'] ?? _doencaAnterior;
          _cirurgiaRecente =
              dados['possui_cirurgia_recente'] ?? _cirurgiaRecente;
          _febre = dados['possui_febre'] ?? _febre;
          _alteracaoPeso =
              dados['possui_alteracao_peso_recente'] ?? _alteracaoPeso;
          _desconforto =
              dados['possui_desconforto_oral_gastrointestinal'] ?? _desconforto;
          _necessidadeDieta =
              dados['possui_necessidade_dieta_hospitalar'] ?? _necessidadeDieta;
          _suplementacao =
              dados['possui_suplementacao_nutricional'] ?? _suplementacao;
          _tabagismo = dados['possui_tabagismo'] ?? _tabagismo;
          _etilismo = dados['possui_etilismo'] ?? _etilismo;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados locais: $e");
    }
  }

  // Função de validação dos campos
  bool _validarCampos() {
    bool valido = true;

    // Campos sempre obrigatórios
    if (_diagnosticoController.text.trim().isEmpty) {
      _diagnosticoError = true;
      valido = false;
    } else {
      _diagnosticoError = false;
    }

    if (_prescricaoController.text.trim().isEmpty) {
      _prescricaoError = true;
      valido = false;
    } else {
      _prescricaoError = false;
    }

    if (selectedAceitacao == 'Selecione') {
      _aceitacaoError = true;
      valido = false;
    } else {
      _aceitacaoError = false;
    }

    // Campos condicionais
    if (selectedAlimentacaoHabitual == 'Inadequada' &&
        _alimentacaoHabitualController.text.trim().isEmpty) {
      _alimentacaoError = true;
      valido = false;
    } else {
      _alimentacaoError = false;
    }

    if (_doencaAnterior && _doencaAnteriorController.text.trim().isEmpty) {
      _doencaAnteriorError = true;
      valido = false;
    } else {
      _doencaAnteriorError = false;
    }

    if (_cirurgiaRecente && _cirurgiaController.text.trim().isEmpty) {
      _cirurgiaError = true;
      valido = false;
    } else {
      _cirurgiaError = false;
    }

    if (_alteracaoPeso && _quantoPesoController.text.trim().isEmpty) {
      _quantoPesoError = true;
      valido = false;
    } else {
      _quantoPesoError = false;
    }

    if (_necessidadeDieta && _qualDietaController.text.trim().isEmpty) {
      _qualDietaError = true;
      valido = false;
    } else {
      _qualDietaError = false;
    }

    if (_suplementacao && _tipoSuplementacaoController.text.trim().isEmpty) {
      _tipoSuplementacaoError = true;
      valido = false;
    } else {
      _tipoSuplementacaoError = false;
    }

    if (selectedCondicaoFuncional == 'Desfavorável' &&
        _especificarCondicaoController.text.trim().isEmpty) {
      _especificarCondicaoError = true;
      valido = false;
    } else {
      _especificarCondicaoError = false;
    }

    setState(() {});
    return valido;
  }

  Future<void> _salvarDadosLocais() async {
    if (!_validarCampos()) {
      return;
    }

    await _atendimentoService.salvarDadosClinicosNutricionais(
      diagnostico: _diagnosticoController.text,
      prescricao: _prescricaoController.text,
      aceitacao: selectedAceitacao,
      alimentacaoHabitual: selectedAlimentacaoHabitual,
      especificarAlimentacao: _alimentacaoHabitualController.text,
      doencaAnterior: _doencaAnterior,
      doencaAnteriorDesc: _doencaAnteriorController.text,
      cirurgiaRecente: _cirurgiaRecente,
      cirurgiaDesc: _cirurgiaController.text,
      febre: _febre,
      alteracaoPeso: _alteracaoPeso,
      quantoPeso: _quantoPesoController.text,
      desconfortos: _desconforto,
      necessidadeDieta: _necessidadeDieta,
      qualDieta: _qualDietaController.text,
      suplementacao: _suplementacao,
      tipoSuplementacao: _tipoSuplementacaoController.text,
      tabagismo: _tabagismo,
      etilismo: _etilismo,
      condicaoFuncional: selectedCondicaoFuncional,
      especificarCondicao: _especificarCondicaoController.text,
      medicamentos: _medicamentosController.text,
      examesLaboratoriais: _examesLaboratoriaisController.text,
      exameFisico: _exameFisicoController.text,
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
              const Text('Erro ao carregar os dados clínicos/nutricionais'),
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
          title: 'Dados Clínicos e Nutricionais',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 5,
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
                              label: 'Diagnóstico Clínico',
                              controller: _diagnosticoController,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _diagnosticoError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_diagnosticoError && value.isNotEmpty) {
                                  setState(() => _diagnosticoError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Prescrição Dietoterápica',
                              controller: _prescricaoController,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _prescricaoError,
                              errorMessage: 'Campo obrigatório',
                              onChanged: (value) {
                                if (_prescricaoError && value.isNotEmpty) {
                                  setState(() => _prescricaoError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomDropdown(
                              label: 'Aceitação',
                              value: selectedAceitacao,
                              items: const [
                                'Selecione',
                                '0%',
                                '25%',
                                '50%',
                                '75%',
                                '100%'
                              ],
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(
                                          () => selectedAceitacao = value!);
                                      if (_aceitacaoError &&
                                          value != 'Selecione') {
                                        setState(() => _aceitacaoError = false);
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                              obrigatorio: true,
                              error: _aceitacaoError,
                              errorMessage: 'Campo obrigatório',
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomDropdown(
                              label: 'Alimentação Habitual',
                              value: selectedAlimentacaoHabitual,
                              items: const [
                                'Selecione',
                                'Alterada',
                                'Inadequada'
                              ],
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() =>
                                          selectedAlimentacaoHabitual = value!);
                                      if (value != 'Inadequada') {
                                        _alimentacaoHabitualController.clear();
                                        _alimentacaoError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (selectedAlimentacaoHabitual ==
                                'Inadequada') ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Especificar',
                                controller: _alimentacaoHabitualController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _alimentacaoError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_alimentacaoError && value.isNotEmpty) {
                                    setState(() => _alimentacaoError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Doença Anterior',
                              value: _doencaAnterior,
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() => _doencaAnterior = value);
                                      if (!value) {
                                        _doencaAnteriorController.clear();
                                        _doencaAnteriorError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_doencaAnterior) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Qual',
                                controller: _doencaAnteriorController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _doencaAnteriorError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_doencaAnteriorError &&
                                      value.isNotEmpty) {
                                    setState(
                                        () => _doencaAnteriorError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Cirurgia Recente',
                              value: _cirurgiaRecente,
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() => _cirurgiaRecente = value);
                                      if (!value) {
                                        _cirurgiaController.clear();
                                        _cirurgiaError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_cirurgiaRecente) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Qual',
                                controller: _cirurgiaController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _cirurgiaError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_cirurgiaError && value.isNotEmpty) {
                                    setState(() => _cirurgiaError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Febre',
                              value: _febre,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _febre = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Alterações de peso recentes',
                              value: _alteracaoPeso,
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() => _alteracaoPeso = value);
                                      if (!value) {
                                        _quantoPesoController.clear();
                                        _quantoPesoError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_alteracaoPeso) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Quanto',
                                controller: _quantoPesoController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _quantoPesoError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_quantoPesoError && value.isNotEmpty) {
                                    setState(() => _quantoPesoError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Desconfortos Orais/Gastrointestinais',
                              value: _desconforto,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _desconforto = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Necessidade de dieta hospitalar',
                              value: _necessidadeDieta,
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() => _necessidadeDieta = value);
                                      if (!value) {
                                        _qualDietaController.clear();
                                        _qualDietaError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_necessidadeDieta) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Qual',
                                controller: _qualDietaController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _qualDietaError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_qualDietaError && value.isNotEmpty) {
                                    setState(() => _qualDietaError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Suplementação Nutricional',
                              value: _suplementacao,
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() => _suplementacao = value);
                                      if (!value) {
                                        _tipoSuplementacaoController.clear();
                                        _tipoSuplementacaoError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (_suplementacao) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Tipo /razão',
                                controller: _tipoSuplementacaoController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _tipoSuplementacaoError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_tipoSuplementacaoError &&
                                      value.isNotEmpty) {
                                    setState(
                                        () => _tipoSuplementacaoError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Tabagismo',
                              value: _tabagismo,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _tabagismo = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Etilismo',
                              value: _etilismo,
                              onChanged: podeEditar
                                  ? (value) => setState(() => _etilismo = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomDropdown(
                              label: 'Condição funcional',
                              value: selectedCondicaoFuncional,
                              items: const [
                                'Selecione',
                                'Favorável',
                                'Desfavorável'
                              ],
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() =>
                                          selectedCondicaoFuncional = value!);
                                      if (value != 'Desfavorável') {
                                        _especificarCondicaoController.clear();
                                        _especificarCondicaoError = false;
                                      }
                                    }
                                  : null,
                              enabled: podeEditar,
                            ),
                            if (selectedCondicaoFuncional ==
                                'Desfavorável') ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Especificar',
                                controller: _especificarCondicaoController,
                                enabled: podeEditar,
                                obrigatorio: true,
                                error: _especificarCondicaoError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_especificarCondicaoError &&
                                      value.isNotEmpty) {
                                    setState(() =>
                                        _especificarCondicaoError = false);
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label:
                                  'Medicamentos/vitaminas/minerais prescritos',
                              controller: _medicamentosController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Exames Laboratoriais',
                              controller: _examesLaboratoriaisController,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Exame Físico',
                              controller: _exameFisicoController,
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
                                                RelatorioProfessorDadosAntropometricosPage(
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
