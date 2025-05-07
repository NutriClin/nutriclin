import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_switch.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_antecedentes_pessoais.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/services/atendimento_service.dart';
import 'package:nutri_app/components/toast_util.dart';

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

  // Variáveis para controle de erros
  bool _houseTypeError = false;
  bool _pessoasError = false;
  bool _rendaFamiliarError = false;
  bool _rendaPerCapitaError = false;
  bool _escolaridadeError = false;
  bool _profissaoError = false;
  bool _producaoAlimentosError = false;

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

    // Adiciona listeners para as máscaras
    pessoasController.addListener(_aplicarMascaraNumeroPessoas);
    rendaFamiliarController.addListener(_aplicarMascaraMonetaria);
    rendaPerCapitaController.addListener(_aplicarMascaraMonetaria);
  }

  void _aplicarMascaraNumeroPessoas() {
    final text = pessoasController.text;
    if (text.isNotEmpty) {
      // Remove tudo que não é dígito
      var newText = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Limita a 3 dígitos
      if (newText.length > 3) {
        newText = newText.substring(0, 3);
      }

      if (text != newText) {
        pessoasController.value = pessoasController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  void _aplicarMascaraMonetaria() {
    final controllers = [rendaFamiliarController, rendaPerCapitaController];

    for (final controller in controllers) {
      final text = controller.text;
      if (text.isNotEmpty) {
        // Remove tudo que não é dígito ou vírgula
        var newText = text.replaceAll(RegExp(r'[^0-9,]'), '');

        // Garante que há no máximo uma vírgula
        final commaCount = newText.split(',').length - 1;
        if (commaCount > 1) {
          newText = newText.substring(0, newText.lastIndexOf(','));
        }

        // Limita a 2 dígitos após a vírgula
        if (newText.contains(',')) {
          final parts = newText.split(',');
          if (parts[1].length > 2) {
            newText = '${parts[0]},${parts[1].substring(0, 2)}';
          }
        }

        // Formata como moeda (R$ 1.234,56)
        if (newText.isNotEmpty) {
          // Adiciona R$ no início
          if (!newText.startsWith('R\$ ')) {
            newText = 'R\$ $newText';
          }

          // Formata os milhares
          final parts = newText.split(',');
          if (parts.isNotEmpty) {
            var integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
            if (integerPart.isNotEmpty) {
              // Adiciona pontos como separadores de milhar
              final reversed = integerPart.split('').reversed.join();
              final reversedWithDots = reversed.replaceAllMapped(
                RegExp(r'(\d{3})(?=\d)'),
                (match) => '${match.group(0)}.',
              );
              integerPart = reversedWithDots.split('').reversed.join();

              newText =
                  'R\$ $integerPart${parts.length > 1 ? ',${parts[1]}' : ''}';
            }
          }
        }

        if (text != newText) {
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    pessoasController.removeListener(_aplicarMascaraNumeroPessoas);
    rendaFamiliarController.removeListener(_aplicarMascaraMonetaria);
    rendaPerCapitaController.removeListener(_aplicarMascaraMonetaria);

    pessoasController.dispose();
    rendaFamiliarController.dispose();
    rendaPerCapitaController.dispose();
    escolaridadeController.dispose();
    profissaoController.dispose();
    producaoAlimentosController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    bool valido = true;

    if (selectedHouseType == 'Selecione') {
      _houseTypeError = true;
      valido = false;
    } else {
      _houseTypeError = false;
    }

    if (pessoasController.text.trim().isEmpty) {
      _pessoasError = true;
      valido = false;
    } else {
      _pessoasError = false;
    }

    if (rendaFamiliarController.text.trim().isEmpty) {
      _rendaFamiliarError = true;
      valido = false;
    } else {
      _rendaFamiliarError = false;
    }

    if (rendaPerCapitaController.text.trim().isEmpty) {
      _rendaPerCapitaError = true;
      valido = false;
    } else {
      _rendaPerCapitaError = false;
    }

    if (escolaridadeController.text.trim().isEmpty) {
      _escolaridadeError = true;
      valido = false;
    } else {
      _escolaridadeError = false;
    }

    if (profissaoController.text.trim().isEmpty) {
      _profissaoError = true;
      valido = false;
    } else {
      _profissaoError = false;
    }

    if (producaoAlimentosController.text.trim().isEmpty) {
      _producaoAlimentosError = true;
      valido = false;
    } else {
      _producaoAlimentosError = false;
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
          _aguaEncanada = data['agua_encanada'] ?? false;
          _esgotoEncanado = data['esgoto_encanado'] ?? false;
          _coletaLixo = data['coleta_lixo'] ?? false;
          _luzEletrica = data['luz_eletrica'] ?? false;
          selectedHouseType = data['tipo_casa'] ?? 'Selecione';
          pessoasController.text =
              data['numero_pessoas_moram_junto']?.toString() ?? '';
          rendaFamiliarController.text =
              data['renda_familiar']?.toString() ?? '';
          rendaPerCapitaController.text =
              data['renda_per_capita']?.toString() ?? '';
          escolaridadeController.text = data['escolaridade'] ?? '';
          profissaoController.text = data['profissao'] ?? '';
          producaoAlimentosController.text =
              data['producao_domestica_alimentos'] ?? '';
          statusAtendimento = data['status_atendimento'] ?? '';

          isLoading = false;
        });

        // Aplica as máscaras após carregar os dados
        _aplicarMascaraNumeroPessoas();
        _aplicarMascaraMonetaria();

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
      print("Erro ao carregar dados socioeconômicos: $e");
    }
  }

  Future<void> _salvarDadosFirestoreNoLocal(Map<String, dynamic> data) async {
    try {
      await _atendimentoService.salvarDadosSocioeconomicos(
        aguaEncanada: data['agua_encanada'] ?? false,
        esgotoEncanado: data['esgoto_encanado'] ?? false,
        coletaLixo: data['coleta_lixo'] ?? false,
        luzEletrica: data['luz_eletrica'] ?? false,
        tipoCasa: data['tipo_casa'] ?? 'Selecione',
        numPessoas: data['numero_pessoas_moram_junto']?.toString() ?? '',
        rendaFamiliar: data['renda_familiar']?.toString() ?? '',
        rendaPerCapita: data['renda_per_capita']?.toString() ?? '',
        escolaridade: data['escolaridade'] ?? '',
        profissao: data['profissao'] ?? '',
        producaoAlimentos: data['producao_domestica_alimentos'] ?? '',
      );
    } catch (e) {
      print("Erro ao salvar dados no local: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    try {
      final dados = await _atendimentoService.carregarDadosSocioeconomicos();
      if (dados.isNotEmpty) {
        setState(() {
          _aguaEncanada = dados['agua_encanada'] ?? _aguaEncanada;
          _esgotoEncanado = dados['esgoto_encanado'] ?? _esgotoEncanado;
          _coletaLixo = dados['coleta_lixo'] ?? _coletaLixo;
          _luzEletrica = dados['luz_eletrica'] ?? _luzEletrica;
          selectedHouseType = dados['tipo_casa'] ?? selectedHouseType;
          pessoasController.text =
              dados['numero_pessoas_moram_junto'] ?? pessoasController.text;
          rendaFamiliarController.text =
              dados['renda_familiar'] ?? rendaFamiliarController.text;
          rendaPerCapitaController.text =
              dados['renda_per_capita'] ?? rendaPerCapitaController.text;
          escolaridadeController.text =
              dados['escolaridade'] ?? escolaridadeController.text;
          profissaoController.text =
              dados['profissao'] ?? profissaoController.text;
          producaoAlimentosController.text =
              dados['producao_domestica_alimentos'] ??
                  producaoAlimentosController.text;
        });

        // Aplica as máscaras após carregar os dados locais
        _aplicarMascaraNumeroPessoas();
        _aplicarMascaraMonetaria();
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

    // Remove a formatação antes de salvar
    final rendaFamiliar =
        rendaFamiliarController.text.replaceAll('R\$ ', '').replaceAll('.', '');
    final rendaPerCapita = rendaPerCapitaController.text
        .replaceAll('R\$ ', '')
        .replaceAll('.', '');

    await _atendimentoService.salvarDadosSocioeconomicos(
      aguaEncanada: _aguaEncanada,
      esgotoEncanado: _esgotoEncanado,
      coletaLixo: _coletaLixo,
      luzEletrica: _luzEletrica,
      tipoCasa: selectedHouseType,
      numPessoas: pessoasController.text,
      rendaFamiliar: rendaFamiliar,
      rendaPerCapita: rendaPerCapita,
      escolaridade: escolaridadeController.text,
      profissao: profissaoController.text,
      producaoAlimentos: producaoAlimentosController.text,
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
            const Text('Erro ao carregar os dados socioeconômicos'),
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
          title: 'Dados Socioeconômicos',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 2,
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
                            CustomSwitch(
                              label: 'Água encanada',
                              value: _aguaEncanada,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _aguaEncanada = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Esgoto encanado',
                              value: _esgotoEncanado,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _esgotoEncanado = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Coleta de lixo',
                              value: _coletaLixo,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _coletaLixo = value)
                                  : null,
                              enabled: podeEditar,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomSwitch(
                              label: 'Luz elétrica',
                              value: _luzEletrica,
                              onChanged: podeEditar
                                  ? (value) =>
                                      setState(() => _luzEletrica = value)
                                  : null,
                              enabled: podeEditar,
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
                              onChanged: podeEditar
                                  ? (value) {
                                      setState(() {
                                        selectedHouseType = value!;
                                        if (_houseTypeError && value != 'Selecione') {
                                          _houseTypeError = false;
                                        }
                                      });
                                    }
                                  : null,
                              enabled: podeEditar,
                              error: _houseTypeError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Nº de pessoas na casa',
                              controller: pessoasController,
                              keyboardType: TextInputType.number,
                              enabled: podeEditar,
                              error: _pessoasError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onChanged: (value) {
                                if (_pessoasError && value.isNotEmpty) {
                                  setState(() => _pessoasError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Renda familiar',
                              controller: rendaFamiliarController,
                              enabled: podeEditar,
                              error: _rendaFamiliarError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                if (_rendaFamiliarError && value.isNotEmpty) {
                                  setState(() => _rendaFamiliarError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Renda per capita',
                              controller: rendaPerCapitaController,
                              enabled: podeEditar,
                              error: _rendaPerCapitaError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                if (_rendaPerCapitaError && value.isNotEmpty) {
                                  setState(() => _rendaPerCapitaError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Escolaridade',
                              controller: escolaridadeController,
                              enabled: podeEditar,
                              error: _escolaridadeError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_escolaridadeError && value.isNotEmpty) {
                                  setState(() => _escolaridadeError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Profissão/Ocupação',
                              controller: profissaoController,
                              enabled: podeEditar,
                              error: _profissaoError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_profissaoError && value.isNotEmpty) {
                                  setState(() => _profissaoError = false);
                                }
                              },
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Produção doméstica de alimentos: Quais?',
                              controller: producaoAlimentosController,
                              enabled: podeEditar,
                              error: _producaoAlimentosError,
                              errorMessage: 'Campo obrigatório',
                              obrigatorio: true,
                              onChanged: (value) {
                                if (_producaoAlimentosError && value.isNotEmpty) {
                                  setState(() => _producaoAlimentosError = false);
                                }
                              },
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
                                                RelatorioProfessorAntecedentesPessoaisPage(
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