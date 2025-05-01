import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_socioeconomico.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoIdentificacaoPage extends StatefulWidget {
  const HospitalAtendimentoIdentificacaoPage({super.key});

  @override
  _HospitalAtendimentoIdentificacaoPageState createState() =>
      _HospitalAtendimentoIdentificacaoPageState();
}

class _HospitalAtendimentoIdentificacaoPageState
    extends State<HospitalAtendimentoIdentificacaoPage> {
  String selectedGender = 'Selecione';
  String? tipoAtendimento;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController recordController = TextEditingController();

  final AtendimentoService _atendimentoService = AtendimentoService();

  bool carregando = true;
  bool isHospital = true;

  // Variáveis para controle de erros
  bool _nameError = false;
  bool _genderError = false;
  bool _birthDateError = false;
  bool _hospitalError = false;
  bool _clinicError = false;
  bool _roomError = false;
  bool _bedError = false;
  bool _recordError = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    hospitalController.dispose();
    clinicController.dispose();
    roomController.dispose();
    bedController.dispose();
    recordController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _atendimentoService.carregarDadosIdentificacao();
      tipoAtendimento = await _atendimentoService.obterTipoAtendimento();

      print("Tipo de atendimento: $tipoAtendimento");

      // Determina se é atendimento hospitalar
      setState(() {
        isHospital = tipoAtendimento == 'hospital';
      });

      // Formata a data se existir
      String formattedDate = '';
      if (dados['data_nascimento'] != null) {
        final date = dados['data_nascimento'] as Timestamp;
        formattedDate = "${date.toDate().day.toString().padLeft(2, '0')}/"
            "${date.toDate().month.toString().padLeft(2, '0')}/"
            "${date.toDate().year}";
      }

      setState(() {
        nameController.text = dados['nome'] ?? '';
        selectedGender = dados['sexo'] ?? 'Selecione';
        birthDateController.text = formattedDate;
        hospitalController.text = dados['hospital'] ?? '';
        clinicController.text = dados['clinica'] ?? '';
        roomController.text = dados['quarto'] ?? '';
        bedController.text = dados['leito'] ?? '';
        recordController.text = dados['registro'] ?? '';
        carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar dados: $e");
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        birthDateController.text = formattedDate;
        _birthDateError = false;
      });
    }
  }

  bool _validarCampos() {
    bool valido = true;

    // Validações comuns a ambos os tipos
    if (nameController.text.trim().isEmpty) {
      _nameError = true;
      valido = false;
    } else {
      _nameError = false;
    }

    if (selectedGender == 'Selecione') {
      _genderError = true;
      valido = false;
    } else {
      _genderError = false;
    }

    if (birthDateController.text.trim().isEmpty) {
      _birthDateError = true;
      valido = false;
    } else {
      _birthDateError = false;
    }

    // Validações específicas para hospital
    if (isHospital) {
      if (hospitalController.text.trim().isEmpty) {
        _hospitalError = true;
        valido = false;
      } else {
        _hospitalError = false;
      }

      if (clinicController.text.trim().isEmpty) {
        _clinicError = true;
        valido = false;
      } else {
        _clinicError = false;
      }

      if (roomController.text.trim().isEmpty) {
        _roomError = true;
        valido = false;
      } else {
        _roomError = false;
      }

      if (bedController.text.trim().isEmpty) {
        _bedError = true;
        valido = false;
      } else {
        _bedError = false;
      }

      if (recordController.text.trim().isEmpty) {
        _recordError = true;
        valido = false;
      } else {
        _recordError = false;
      }
    }

    setState(() {});
    return valido;
  }

  Future<void> _salvarDadosIdentificacao() async {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }

    // Converte a string "DD/MM/AAAA" para DateTime
    DateTime parsedDate;
    try {
      final dateParts = birthDateController.text.split('/');
      parsedDate = DateTime(
        int.parse(dateParts[2]), // Ano
        int.parse(dateParts[1]), // Mês
        int.parse(dateParts[0]), // Dia
      );
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Data de nascimento inválida!',
        isError: true,
      );
      return;
    }

    // Call the method with named parameters
    await _atendimentoService.salvarDadosIdentificacao(
      nome: nameController.text,
      sexo: selectedGender,
      data_nascimento: Timestamp.fromDate(parsedDate),
      hospital: isHospital ? hospitalController.text : null,
      clinica: isHospital ? clinicController.text : null,
      quarto: isHospital ? roomController.text : null,
      leito: isHospital ? bedController.text : null,
      registro: isHospital ? recordController.text : null,
    );
  }

  void _proceedToNext() async {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }

    await _salvarDadosIdentificacao();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const HospitalAtendimentoDadosSocioeconomicoPage()),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
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

    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BasePage(
      title: 'Identificação',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(
                  currentStep: 1,
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
                          label: 'Nome',
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          error: _nameError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                          onChanged: (value) {
                            if (_nameError && value.isNotEmpty) {
                              setState(() => _nameError = false);
                            }
                          },
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Sexo',
                          value: selectedGender,
                          items: const ['Selecione', 'Masculino', 'Feminino'],
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                              if (_genderError && value != 'Selecione') {
                                _genderError = false;
                              }
                            });
                          },
                          error: _genderError,
                          errorMessage: 'Campo obrigatório',
                          obrigatorio: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomInput(
                              label: 'Data Nasc',
                              controller: birthDateController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'DD/MM/AAAA',
                              error: _birthDateError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_birthDateError && value.isNotEmpty) {
                                  setState(() => _birthDateError = false);
                                }
                              },
                            ),
                          ),
                        ),

                        // Campos específicos para hospital (renderizados condicionalmente)
                        if (isHospital) ...[
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Hospital',
                            controller: hospitalController,
                            keyboardType: TextInputType.text,
                            error: _hospitalError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_hospitalError && value.isNotEmpty) {
                                setState(() => _hospitalError = false);
                              }
                            },
                          ),
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Clínica',
                            controller: clinicController,
                            keyboardType: TextInputType.text,
                            error: _clinicError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_clinicError && value.isNotEmpty) {
                                setState(() => _clinicError = false);
                              }
                            },
                          ),
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Quarto',
                            controller: roomController,
                            keyboardType: TextInputType.text,
                            error: _roomError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_roomError && value.isNotEmpty) {
                                setState(() => _roomError = false);
                              }
                            },
                          ),
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Leito',
                            controller: bedController,
                            keyboardType: TextInputType.text,
                            error: _bedError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_bedError && value.isNotEmpty) {
                                setState(() => _bedError = false);
                              }
                            },
                          ),
                          SizedBox(height: espacamentoCards),
                          CustomInput(
                            label: 'Registro',
                            controller: recordController,
                            keyboardType: TextInputType.text,
                            error: _recordError,
                            errorMessage: 'Campo obrigatório',
                            obrigatorio: true,
                            onChanged: (value) {
                              if (_recordError && value.isNotEmpty) {
                                setState(() => _recordError = false);
                              }
                            },
                          ),
                        ],

                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Cancelar',
                              onPressed: () =>
                                  _showCancelConfirmationDialog(context),
                              color: Colors.white,
                              textColor: Colors.red,
                              boxShadowColor: Colors.black,
                            ),
                            CustomButton(
                              text: 'Próximo',
                              onPressed: _proceedToNext,
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
