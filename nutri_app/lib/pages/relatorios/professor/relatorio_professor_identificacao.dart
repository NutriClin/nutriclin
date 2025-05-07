import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_dados_socioeconomicos.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class RelatorioProfessorIdentificacaoPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorIdentificacaoPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorIdentificacaoPageState createState() =>
      _RelatorioProfessorIdentificacaoPageState();
}

class _RelatorioProfessorIdentificacaoPageState
    extends State<RelatorioProfessorIdentificacaoPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedGender = 'Selecione';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController recordController = TextEditingController();
  final TextEditingController prontuarioController = TextEditingController();

  // Variáveis para controle de erros
  bool _nameError = false;
  bool _genderError = false;
  bool _birthDateError = false;
  bool _hospitalError = false;
  bool _clinicError = false;
  bool _roomError = false;
  bool _bedError = false;
  bool _recordError = false;
  bool _prontuarioError = false;

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
    if (widget.isHospital) {
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
    } else {
      // Validação específica para clínica
      if (prontuarioController.text.trim().isEmpty) {
        _prontuarioError = true;
        valido = false;
      } else {
        _prontuarioError = false;
      }
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

        String formattedDate = '';
        if (data['data_nascimento'] != null) {
          final date = (data['data_nascimento'] as Timestamp).toDate();
          formattedDate = "${date.day.toString().padLeft(2, '0')}/"
              "${date.month.toString().padLeft(2, '0')}/"
              "${date.year}";
        }

        setState(() {
          nameController.text = data['nome'] ?? '';
          selectedGender = data['sexo'] ?? 'Selecione';
          birthDateController.text = formattedDate;
          statusAtendimento = data['status_atendimento'] ?? '';

          if (widget.isHospital) {
            hospitalController.text = data['hospital'] ?? '';
            clinicController.text = data['clinica'] ?? '';
            roomController.text = data['quarto'] ?? '';
            bedController.text = data['leito'] ?? '';
            recordController.text = data['registro'] ?? '';
          } else {
            prontuarioController.text = data['prontuario'] ?? '';
          }

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
      print("Erro ao carregar dados: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarDadosIdentificacao(
        nome: data['nome'] ?? '',
        sexo: data['sexo'] ?? 'Selecione',
        data_nascimento: data['data_nascimento'] as Timestamp,
        hospital: data['hospital'] ?? '',
        clinica: data['clinica'] ?? '',
        quarto: data['quarto'] ?? '',
        leito: data['leito'] ?? '',
        registro: data['registro'] ?? '',
        prontuario: data['prontuario'] ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados = await _atendimentoService.carregarDadosIdentificacao();
      if (dados.isNotEmpty) {
        setState(() {
          nameController.text = dados['nome'] ?? nameController.text;
          selectedGender = dados['sexo'] ?? selectedGender;
          if (dados['data_nascimento'] != null) {
            final date = (dados['data_nascimento'] as Timestamp).toDate();
            birthDateController.text = "${date.day.toString().padLeft(2, '0')}/"
                "${date.month.toString().padLeft(2, '0')}/"
                "${date.year}";
          }
          hospitalController.text =
              dados['hospital'] ?? hospitalController.text;
          clinicController.text = dados['clinica'] ?? clinicController.text;
          roomController.text = dados['quarto'] ?? roomController.text;
          bedController.text = dados['leito'] ?? bedController.text;
          recordController.text = dados['registro'] ?? recordController.text;
          prontuarioController.text =
              dados['prontuario'] ?? prontuarioController.text;
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
        message: 'Por favor, verifique o formulário!',
        isError: true,
      );
      return;
    }

    try {
      final dateParts = birthDateController.text.split('/');
      final date = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      await _atendimentoService.salvarDadosIdentificacao(
        nome: nameController.text,
        sexo: selectedGender,
        data_nascimento: Timestamp.fromDate(date),
        hospital: hospitalController.text,
        clinica: clinicController.text,
        quarto: roomController.text,
        leito: bedController.text,
        registro: recordController.text,
        prontuario: prontuarioController.text,
      );
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Data de nascimento inválida!',
        isError: true,
      );
      return;
    }
  }

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
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
                              obrigatorio: true,
                              enabled: podeEditar,
                              error: _nameError,
                              errorMessage: 'Campo obrigatório',
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
                              items: const [
                                'Selecione',
                                'Masculino',
                                'Feminino'
                              ],
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() {
                                        selectedGender = value!;
                                        if (_genderError && value != 'Selecione') {
                                          _genderError = false;
                                        }
                                      });
                                    }
                                  : null,
                              obrigatorio: true,
                              enabled: podeEditar,
                              error: _genderError,
                              errorMessage: 'Campo obrigatório',
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
                                  enabled: podeEditar,
                                  onChanged: (value) {
                                    if (_birthDateError && value.isNotEmpty) {
                                      setState(() => _birthDateError = false);
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (widget.isHospital) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Hospital',
                                controller: hospitalController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _hospitalError,
                                errorMessage: 'Campo obrigatório',
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
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _clinicError,
                                errorMessage: 'Campo obrigatório',
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
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _roomError,
                                errorMessage: 'Campo obrigatório',
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
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _bedError,
                                errorMessage: 'Campo obrigatório',
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
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _recordError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_recordError && value.isNotEmpty) {
                                    setState(() => _recordError = false);
                                  }
                                },
                              ),
                            ] else ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Número de Prontuário',
                                controller: prontuarioController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                                error: _prontuarioError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_prontuarioError && value.isNotEmpty) {
                                    setState(() => _prontuarioError = false);
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  text: 'Sair',
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.white,
                                  textColor: Colors.red,
                                  boxShadowColor: Colors.black,
                                ),
                                CustomButton(
                                  text: 'Próximo',
                                  onPressed: () async {
                                    if (podeEditar && !_validarCampos()) {
                                      ToastUtil.showToast(
                                        context: context,
                                        message: 'Por favor, verifique o formulário!',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    
                                    if (podeEditar) {
                                      await _salvarDadosLocais();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RelatorioProfessorDadosSocioeconomicosPage(
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