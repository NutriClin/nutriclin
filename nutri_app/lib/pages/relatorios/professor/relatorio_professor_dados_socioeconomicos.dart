import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_switch.dart';

class RelatorioProfessorDadosSocioeconomicosPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorDadosSocioeconomicosPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorDadosSocioeconomicosPageState createState() =>
      _RelatorioProfessorDadosSocioeconomicosPageState();
}

class _RelatorioProfessorDadosSocioeconomicosPageState
    extends State<RelatorioProfessorDadosSocioeconomicosPage> {
  bool _aguaEncanada = false;
  bool _esgotoEncanado = false;
  bool _coletaLixo = false;
  bool _luzEletrica = false;
  String selectedHouseType = 'Selecione';

  // Controllers para campos de texto
  final pessoasController = TextEditingController();
  final rendaFamiliarController = TextEditingController();
  final rendaPerCapitaController = TextEditingController();
  final escolaridadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final producaoAlimentosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    pessoasController.dispose();
    rendaFamiliarController.dispose();
    rendaPerCapitaController.dispose();
    escolaridadeController.dispose();
    profissaoController.dispose();
    producaoAlimentosController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        
        setState(() {
          _aguaEncanada = data['agua_encanada'] ?? false;
          _esgotoEncanado = data['esgoto_encanado'] ?? false;
          _coletaLixo = data['coleta_lixo'] ?? false;
          _luzEletrica = data['luz_eletrica'] ?? false;
          selectedHouseType = data['tipo_casa'] ?? 'Selecione';
          pessoasController.text = data['numero_pessoas_moram_junto']?.toString() ?? '';
          rendaFamiliarController.text = data['renda_familiar']?.toString() ?? '';
          rendaPerCapitaController.text = data['renda_per_capita']?.toString() ?? '';
          escolaridadeController.text = data['escolaridade'] ?? '';
          profissaoController.text = data['profissao'] ?? '';
          producaoAlimentosController.text = data['producao_domestica_alimentos'] ?? '';
          
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
      print("Erro ao carregar dados socioeconômicos: $e");
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
              const Text('Erro ao carregar os dados socioeconômicos'),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return BasePage(
      title: 'Dados Socioeconômicos',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                const CustomStepper(currentStep: 2, totalSteps: 9),
                SizedBox(height: espacamentoCards),
                CustomCard(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSwitch(
                          label: 'Água encanada',
                          value: _aguaEncanada,
                          onChanged: null, // Desabilita alteração
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Esgoto encanado',
                          value: _esgotoEncanado,
                          onChanged: null,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Coleta de lixo',
                          value: _coletaLixo,
                          onChanged: null,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomSwitch(
                          label: 'Luz elétrica',
                          value: _luzEletrica,
                          onChanged: null,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomDropdown(
                          label: 'Tipo de casa',
                          value: selectedHouseType,
                          items: const [
                            'Selecione',
                            'Alvenaria',
                            'Madeira',
                            'Mista',
                            'Outro'
                          ],
                          onChanged: null, // Desabilita alteração
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Nº de pessoas na casa',
                          controller: pessoasController,
                          keyboardType: TextInputType.number,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda familiar',
                          controller: rendaFamiliarController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Renda per capita',
                          controller: rendaPerCapitaController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Escolaridade',
                          controller: escolaridadeController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Profissão/Ocupação',
                          controller: profissaoController,
                          enabled: false,
                        ),
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Produção doméstica de alimentos: Quais?',
                          controller: producaoAlimentosController,
                          enabled: false,
                        ),
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
                                // Navegar para a próxima página
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RelatorioProfessorAntecedentesPessoaisPage(
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
    );
  }
}