import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/atendimentos/hospital/hospital_atendimento_dados_socioeconomico.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class HospitalAtendimentoIdentificacaoPage extends StatefulWidget {
  final String? idAtendimento;

  const HospitalAtendimentoIdentificacaoPage({super.key, this.idAtendimento});

  @override
  _HospitalAtendimentoIdentificacaoPageState createState() =>
      _HospitalAtendimentoIdentificacaoPageState();
}

class _HospitalAtendimentoIdentificacaoPageState
    extends State<HospitalAtendimentoIdentificacaoPage> {
  String selectedGender = 'Selecione';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController recordController = TextEditingController();

  final AtendimentoService _atendimentoService = AtendimentoService();

  bool carregando = true;

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
    if (widget.idAtendimento != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('atendimento')
            .doc(widget.idAtendimento)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final birthDate = data['data_nascimento'] as Timestamp?;
          final formattedDate = birthDate != null
              ? "${birthDate.toDate().day.toString().padLeft(2, '0')}/${birthDate.toDate().month.toString().padLeft(2, '0')}/${birthDate.toDate().year}"
              : '';

          setState(() {
            nameController.text = data['nome'] ?? '';
            selectedGender = data['sexo'] ?? 'Selecione';
            birthDateController.text = formattedDate;
            hospitalController.text = data['hospital'] ?? '';
            clinicController.text = data['clinica'] ?? '';
            roomController.text = data['quarto'] ?? '';
            bedController.text = data['leito'] ?? '';
            recordController.text = data['registro'] ?? '';
            carregando = false;
          });
          return;
        }
      } catch (e) {
        print("Erro ao buscar atendimento: $e");
      }
    }

    try {
      final dados = await _atendimentoService.carregarDadosIdentificacao();
      setState(() {
        nameController.text = dados['nome'] ?? '';
        selectedGender = dados['gender'] ?? 'Selecione';
        birthDateController.text = dados['birthDate'] ?? '';
        hospitalController.text = dados['hospital'] ?? '';
        clinicController.text = dados['clinic'] ?? '';
        roomController.text = dados['room'] ?? '';
        bedController.text = dados['bed'] ?? '';
        recordController.text = dados['record'] ?? '';
        carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar dados do cache: $e");
      setState(() {
        nameController.text = '';
        selectedGender = 'Selecione';
        birthDateController.text = '';
        hospitalController.text = '';
        clinicController.text = '';
        roomController.text = '';
        bedController.text = '';
        recordController.text = '';
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
      });
    }
  }

  Future<void> _salvarDadosIdentificacao() async {
    // Converte a string "DD/MM/AAAA" para DateTime
    final dateParts = birthDateController.text.split('/');
    final parsedDate = DateTime(
      int.parse(dateParts[2]), // Ano
      int.parse(dateParts[1]), // Mês
      int.parse(dateParts[0]), // Dia
    );

    final timestamp = Timestamp.fromDate(parsedDate);

    await _atendimentoService.salvarDadosIdentificacao(
      nome: nameController.text,
      sexo: selectedGender,
      data_nascimento: timestamp,
      hospital: hospitalController.text,
      clinica: clinicController.text,
      quarto: roomController.text,
      leito: bedController.text,
      registro: recordController.text,
    );
  }

  void _proceedToNext() async {
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
                          obrigatorio: true,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Sexo',
                          value: selectedGender,
                          items: const ['Selecione', 'Masculino', 'Feminino'],
                          onChanged: (value) =>
                              setState(() => selectedGender = value!),
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
                              obrigatorio: true,
                            ),
                          ),
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Hospital',
                          controller: hospitalController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Clínica',
                          controller: clinicController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Quarto',
                          controller: roomController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Leito',
                          controller: bedController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Registro',
                          controller: recordController,
                          keyboardType: TextInputType.text,
                        ),
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
