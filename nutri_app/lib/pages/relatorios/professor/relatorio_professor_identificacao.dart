import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_dados_socioeconomicos.dart';

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
  String selectedGender = 'Selecione';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController recordController = TextEditingController();
  final TextEditingController prontuarioController = TextEditingController();

  bool isHospital = true;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosAtendimento();
  }

  Future<void> _carregarDadosAtendimento() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      final doc = await FirebaseFirestore.instance
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

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    hospitalController.dispose();
    clinicController.dispose();
    roomController.dispose();
    bedController.dispose();
    recordController.dispose();
    prontuarioController.dispose();
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
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomDropdown(
                              label: 'Sexo',
                              value: selectedGender,
                              items: const ['Selecione', 'Masculino', 'Feminino'],
                              onChanged: null,
                              obrigatorio: true,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Data Nasc',
                              controller: birthDateController,
                              keyboardType: TextInputType.datetime,
                              hintText: 'DD/MM/AAAA',
                              obrigatorio: true,
                              enabled: false,
                            ),

                            if (isHospital) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Hospital',
                                controller: hospitalController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: false,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Clínica',
                                controller: clinicController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: false,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Quarto',
                                controller: roomController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: false,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Leito',
                                controller: bedController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: false,
                              ),
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Registro',
                                controller: recordController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
                                enabled: false,
                              ),
                            ] else ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Número de Prontuário',
                                controller: prontuarioController,
                                keyboardType: TextInputType.text,
                                obrigatorio: true,
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
                                  textColor: Colors.red,
                                  boxShadowColor: Colors.black,
                                ),
                                CustomButton(
                                  text: 'Próximo',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RelatorioProfessorDadosSocioeconomicosPage(
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
        ObservacaoRelatorio(
          pageKey: 'identificacao',
          atendimentoId: widget.atendimentoId,
          isHospital: widget.isHospital,
          isFinalPage: false,
        ),
      ],
    );
  }
}