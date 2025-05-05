import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_antecedentes_pessoais.dart';
import 'package:nutri_app/services/atendimento_service.dart';

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
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _aguaEncanada = false;
  bool _esgotoEncanado = false;
  bool _coletaLixo = false;
  bool _luzEletrica = false;
  String selectedHouseType = 'Selecione';

  final pessoasController = TextEditingController();
  final rendaFamiliarController = TextEditingController();
  final rendaPerCapitaController = TextEditingController();
  final escolaridadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final producaoAlimentosController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  bool isProfessor = false;
  bool isAluno = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDados();
    });
  }

  Future<void> _checkUserType() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          isProfessor = userDoc.data()?['tipo_usuario'] == 'Professor';
          isAluno = userDoc.data()?['tipo_usuario'] == 'Aluno';
        });
      }
    }
  }

  Future<void> _carregarDados() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      final doc = await _firestore
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

        if (isAluno) {
          await _carregarDadosLocais();
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
      print("Erro ao carregar dados socioeconômicos: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    final dados = await _atendimentoService.carregarDadosSocioeconomicos();
    setState(() {
      _aguaEncanada = dados['agua_encanada'] ?? _aguaEncanada;
      _esgotoEncanado = dados['esgoto_encanado'] ?? _esgotoEncanado;
      _coletaLixo = dados['coleta_lixo'] ?? _coletaLixo;
      _luzEletrica = dados['luz_eletrica'] ?? _luzEletrica;
      selectedHouseType = dados['tipo_casa'] ?? selectedHouseType;
      pessoasController.text = dados['numero_pessoas_moram_junto'] ?? pessoasController.text;
      rendaFamiliarController.text = dados['renda_familiar'] ?? rendaFamiliarController.text;
      rendaPerCapitaController.text = dados['renda_per_capita'] ?? rendaPerCapitaController.text;
      escolaridadeController.text = dados['escolaridade'] ?? escolaridadeController.text;
      profissaoController.text = dados['profissao'] ?? profissaoController.text;
      producaoAlimentosController.text = dados['producao_domestica_alimentos'] ?? producaoAlimentosController.text;
    });
  }

  Future<void> _salvarDadosLocais() async {
    await _atendimentoService.salvarDadosSocioeconomicos(
      aguaEncanada: _aguaEncanada,
      esgotoEncanado: _esgotoEncanado,
      coletaLixo: _coletaLixo,
      luzEletrica: _luzEletrica,
      tipoCasa: selectedHouseType,
      numPessoas: pessoasController.text,
      rendaFamiliar: rendaFamiliarController.text,
      rendaPerCapita: rendaPerCapitaController.text,
      escolaridade: escolaridadeController.text,
      profissao: profissaoController.text,
      producaoAlimentos: producaoAlimentosController.text,
    );
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        _salvarDadosLocais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double espacamentoCards = 10;
    final bool camposEditaveis = isAluno && isEditing;
    final bool mostrarBotaoEditar = isAluno;

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

    return Stack(
      children: [
        BasePage(
          title: 'Dados Socioeconômicos',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(currentStep: 2, totalSteps: 9),
                    if (mostrarBotaoEditar) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: _toggleEditing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditing ? Colors.green : Colors.blue,
                            ),
                            child: Text(
                              isEditing ? 'Salvar' : 'Editar',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
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
                              onChanged: camposEditaveis 
                                  ? (value) => setState(() => _aguaEncanada = value)
                                  : null,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Esgoto encanado',
                              value: _esgotoEncanado,
                              onChanged: camposEditaveis
                                  ? (value) => setState(() => _esgotoEncanado = value)
                                  : null,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Coleta de lixo',
                              value: _coletaLixo,
                              onChanged: camposEditaveis
                                  ? (value) => setState(() => _coletaLixo = value)
                                  : null,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Luz elétrica',
                              value: _luzEletrica,
                              onChanged: camposEditaveis
                                  ? (value) => setState(() => _luzEletrica = value)
                                  : null,
                              enabled: camposEditaveis,
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
                              onChanged: camposEditaveis
                                  ? (value) => setState(() => selectedHouseType = value!)
                                  : null,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Nº de pessoas na casa',
                              controller: pessoasController,
                              keyboardType: TextInputType.number,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Renda familiar',
                              controller: rendaFamiliarController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Renda per capita',
                              controller: rendaPerCapitaController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Escolaridade',
                              controller: escolaridadeController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Profissão/Ocupação',
                              controller: profissaoController,
                              enabled: camposEditaveis,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Produção doméstica de alimentos: Quais?',
                              controller: producaoAlimentosController,
                              enabled: camposEditaveis,
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
                                    if (isAluno && isEditing) {
                                      _salvarDadosLocais();
                                    }
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
        ),
        ObservacaoRelatorio(
          pageKey: 'dados_socioeconomicos',
          atendimentoId: widget.atendimentoId,
          isHospital: widget.isHospital,
          isFinalPage: false,
          modoLeitura: isAluno,
        ),
      ],
    );
  }
}