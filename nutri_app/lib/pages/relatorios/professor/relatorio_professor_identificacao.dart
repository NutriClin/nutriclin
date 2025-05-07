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
                              enabled:
                                  podeEditar, // Habilita apenas se podeEditar for true
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
                                  ? (value) =>
                                      setState(() => selectedGender = value!)
                                  : null,
                              obrigatorio: true,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Data Nasc',
                              controller: birthDateController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'DD/MM/AAAA',
                              obrigatorio: true,
                              enabled: podeEditar,
                            ),
                            if (widget.isHospital) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Hospital',
                                controller: hospitalController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Clínica',
                                controller: clinicController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Quarto',
                                controller: roomController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Leito',
                                controller: bedController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Registro',
                                controller: recordController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
                              ),
                            ] else ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Número de Prontuário',
                                controller: prontuarioController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: podeEditar,
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
