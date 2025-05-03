import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_antropometricos.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoDadosClinicosNutricionaisPage extends StatefulWidget {
  const HospitalAtendimentoDadosClinicosNutricionaisPage({super.key});

  @override
  _HospitalAtendimentoDadosClinicosNutricionaisPageState createState() =>
      _HospitalAtendimentoDadosClinicosNutricionaisPageState();
}

class _HospitalAtendimentoDadosClinicosNutricionaisPageState
    extends State<HospitalAtendimentoDadosClinicosNutricionaisPage> {
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

  String selectedAlimentacaoHabitual = 'Selecione';
  String selectedCondicaoFuncional = 'Selecione';
  String selectedAceitacao = 'Selecione';

  // Estados para os switches/checkboxes
  bool _doencaAnterior = false;
  bool _cirurgiaRecente = false;
  bool _febre = false;
  bool _alteracaoPeso = false;
  bool _alimentacaoInadequada = false;
  bool _necessidadeDieta = false;
  bool _suplementacao = false;
  bool _desconforto = false;
  bool _tabagismo = false;
  bool _etilismo = false;
  bool _condicaoFuncional = false;

  //Validacao de campos
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

  // Serviço para manipulação de dados
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    // Dispose de todos os controllers
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

  Future<void> _carregarDados() async {
    final dados = await _atendimentoService.carregarDadosClinicosNutricionais();

    setState(() {
      // Controllers de texto
      _diagnosticoController.text = dados['diagnostico_clinico'] ?? '';
      _prescricaoController.text = dados['prescricao_dietoterapica'] ?? '';
      _alimentacaoHabitualController.text =
          dados['resumo_alimentacao_habitual'] ?? '';
      _doencaAnteriorController.text = dados['resumo_doenca_anterior'] ?? '';
      _cirurgiaController.text = dados['cirurgiaDesc'] ?? '';
      _quantoPesoController.text = dados['quantidade_perca_peso_recente'] ?? '';
      _qualDietaController.text =
          dados['resumo_necessidade_dieta_hospitalar'] ?? '';
      _tipoSuplementacaoController.text =
          dados['resumo_suplemento_nutricional'] ?? '';
      _especificarCondicaoController.text =
          dados['resumo_condicao_funcional'] ?? '';
      _medicamentosController.text =
          dados['resumo_medicamentos_vitaminas_minerais_prescritos'] ?? '';
      _examesLaboratoriaisController.text =
          dados['resumo_exames_laboratoriais'] ?? '';
      _exameFisicoController.text = dados['resumo_exame_fisico'] ?? '';

      // Dropdowns
      selectedAlimentacaoHabitual =
          dados['alimentacao_habitual']?.toString() ?? 'Selecione';
      selectedCondicaoFuncional =
          dados['possui_condicao_funcional']?.toString() ?? 'Selecione';
      selectedAceitacao = dados['aceitacao']?.toString() ?? 'Selecione';

      _alimentacaoInadequada = selectedAlimentacaoHabitual == 'Inadequada';
      _condicaoFuncional = selectedCondicaoFuncional == 'Desfavorável';

      // Switches
      _doencaAnterior = dados['possui_doenca_anterior'] ?? false;
      _cirurgiaRecente = dados['possui_cirurgia_recente'] ?? false;
      _febre = dados['possui_febre'] ?? false;
      _alteracaoPeso = dados['possui_alteracao_peso_recente'] ?? false;
      _desconforto = dados['possui_desconforto_oral_gastrointestinal'] ?? false;
      _necessidadeDieta = dados['possui_necessidade_dieta_hospitalar'] ?? false;
      _suplementacao = dados['possui_suplementacao_nutricional'] ?? false;
      _tabagismo = dados['possui_tabagismo'] ?? false;
      _etilismo = dados['possui_etilismo'] ?? false;
    });
  }

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
    if (_alimentacaoInadequada &&
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

    if (_condicaoFuncional &&
        _especificarCondicaoController.text.trim().isEmpty) {
      _especificarCondicaoError = true;
      valido = false;
    } else {
      _especificarCondicaoError = false;
    }

    setState(() {});
    return valido;
  }

  Future<void> _salvarDadosClinicosNutricionais() async {
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

  void _onAlimentacaoHabitualChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedAlimentacaoHabitual = value;
      _alimentacaoInadequada = value == 'Inadequada';
      _alimentacaoError = false; // Reseta o erro ao mudar a seleção

      if (!_alimentacaoInadequada) {
        _alimentacaoHabitualController.clear();
      }
    });
  }

  void _onCondicaoFuncionalChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedCondicaoFuncional = value;
      _condicaoFuncional = value == 'Desfavorável';
      _especificarCondicaoError = false; // Reseta o erro ao mudar a seleção

      if (!_condicaoFuncional) {
        _especificarCondicaoController.clear();
      }
    });
  }

  void _onAceitacaoChanged(String? value) {
    if (value == null) return;
    setState(() {
      selectedAceitacao = value;
      _aceitacaoError = false; // Reseta o erro ao mudar a seleção
    });
  }

  void _proceedToNext() {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }
    _salvarDadosClinicosNutricionais();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoDadosAntropometricosPage()),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: 'Cancelar Atendimento',
        message:
            'Tem certeza que deseja sair? Todo o progresso não salvo será perdido.',
        confirmText: 'Sair',
        cancelText: 'Continuar',
        onConfirm: () async {
          await _atendimentoService.limparTodosDados();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AtendimentoPage()),
              (route) => false,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    double espacamentoCards = 10;

    return BasePage(
      title: 'Dados Clínicos e Nutricionais',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                          keyboardType: TextInputType.text,
                          error: _diagnosticoError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
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
                          keyboardType: TextInputType.text,
                          error: _prescricaoError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
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
                          onChanged: (value) {
                            _onAceitacaoChanged(value);
                            if (_aceitacaoError && value != 'Selecione') {
                              setState(() => _aceitacaoError = false);
                            }
                          },
                          error: _aceitacaoError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Alimentação Habitual',
                          value: selectedAlimentacaoHabitual,
                          items: const ['Selecione', 'Alterada', 'Inadequada'],
                          onChanged: _onAlimentacaoHabitualChanged,
                        ),
                        if (_alimentacaoInadequada) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Especificar',
                            controller: _alimentacaoHabitualController,
                            keyboardType: TextInputType.text,
                            error: _alimentacaoError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
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
                          onChanged: (value) =>
                              setState(() => _doencaAnterior = value),
                          enabled: true,
                        ),
                        if (_doencaAnterior) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Qual',
                            controller: _doencaAnteriorController,
                            keyboardType: TextInputType.text,
                            error: _doencaAnteriorError,
                            obrigatorio: true,
                            errorMessage: 'Campo obrigatório',
                            onChanged: (value) {
                              if (_doencaAnteriorError && value.isNotEmpty) {
                                setState(() => _doencaAnteriorError = false);
                              }
                            },
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Cirurgia Recente',
                          value: _cirurgiaRecente,
                          onChanged: (value) =>
                              setState(() => _cirurgiaRecente = value),
                          enabled: true,
                        ),
                        if (_cirurgiaRecente) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Qual',
                            controller: _cirurgiaController,
                            keyboardType: TextInputType.text,
                            error: _cirurgiaError,
                            obrigatorio: true,
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
                          onChanged: (value) => setState(() => _febre = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Alterações de peso recentes',
                          value: _alteracaoPeso,
                          onChanged: (value) =>
                              setState(() => _alteracaoPeso = value),
                          enabled: true,
                        ),
                        if (_alteracaoPeso) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Quanto',
                            controller: _quantoPesoController,
                            keyboardType: TextInputType.text,
                            error: _quantoPesoError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
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
                          onChanged: (value) =>
                              setState(() => _desconforto = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Necessidade de dieta hospitalar',
                          value: _necessidadeDieta,
                          onChanged: (value) =>
                              setState(() => _necessidadeDieta = value),
                          enabled: true,
                        ),
                        if (_necessidadeDieta) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Qual',
                            controller: _qualDietaController,
                            keyboardType: TextInputType.text,
                            error: _qualDietaError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
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
                          onChanged: (value) =>
                              setState(() => _suplementacao = value),
                          enabled: true,
                        ),
                        if (_suplementacao) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Tipo /razão',
                            controller: _tipoSuplementacaoController,
                            keyboardType: TextInputType.text,
                            error: _tipoSuplementacaoError,
                            obrigatorio: true,
                            errorMessage: 'Campo obrigatório',
                            onChanged: (value) {
                              if (_tipoSuplementacaoError && value.isNotEmpty) {
                                setState(() => _tipoSuplementacaoError = false);
                              }
                            },
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Tabagismo',
                          value: _tabagismo,
                          onChanged: (value) =>
                              setState(() => _tabagismo = value),
                          enabled: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Etilismo',
                          value: _etilismo,
                          onChanged: (value) =>
                              setState(() => _etilismo = value),
                          enabled: true,
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
                          onChanged: _onCondicaoFuncionalChanged,
                        ),
                        if (_condicaoFuncional) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Especificar',
                            controller: _especificarCondicaoController,
                            keyboardType: TextInputType.text,
                            error: _especificarCondicaoError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_especificarCondicaoError &&
                                  value.isNotEmpty) {
                                setState(
                                    () => _especificarCondicaoError = false);
                              }
                            },
                          ),
                        ],
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Medicamentos/vitaminas/minerais prescritos',
                          controller: _medicamentosController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Exames Laboratoriais',
                          controller: _examesLaboratoriaisController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Exame Físico',
                          controller: _exameFisicoController,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Cancelar',
                              onPressed: () => _showCancelConfirmationDialog(),
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
                                  onPressed: _proceedToNext,
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
    );
  }
}
