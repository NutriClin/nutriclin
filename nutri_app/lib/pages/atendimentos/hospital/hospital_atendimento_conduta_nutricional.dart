import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/services/atendimento_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HospitalAtendimentoCondutaNutricionalPage extends StatefulWidget {
  const HospitalAtendimentoCondutaNutricionalPage({super.key});

  @override
  State<HospitalAtendimentoCondutaNutricionalPage> createState() =>
      _HospitalAtendimentoCondutaNutricionalPageState();
}

class _HospitalAtendimentoCondutaNutricionalPageState
    extends State<HospitalAtendimentoCondutaNutricionalPage> {
  final TextEditingController _estagiarioNomeController =
      TextEditingController();
  final TextEditingController _proximaConsultaController =
      TextEditingController(); // Novo controller

  final AtendimentoService _atendimentoService = AtendimentoService();

  String? _professorSelecionado;
  List<String> _professores = [];
  bool isLoading = false;
  bool _professorSelecionadoError = false;
  String? _errorMessage = '';
  bool _isHospital = true; // Variável para controlar o tipo de atendimento

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarProfessores();
    _verificarTipoAtendimento();
  }

  Future<void> _verificarTipoAtendimento() async {
    final tipo = await _atendimentoService.obterTipoAtendimento();
    setState(() {
      _isHospital = tipo == 'hospital';
    });
  }

  Future<void> _carregarDados() async {
    setState(() => isLoading = true);
    try {
      final dadosCache = await _obterDadosDoCache();
      if (dadosCache != null) {
        _instanciarDadosCache(dadosCache);
        return;
      }

      await _carregarUsuarioLogado();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      ToastUtil.showToast(
        context: context,
        message: 'Falha ao carregar dados',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _obterDadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final estagiario =
          prefs.getString('hospital_atendimento_conduta.estagiario');
      final professor =
          prefs.getString('hospital_atendimento_conduta.professor');
      final proximaConsulta =
          prefs.getString('hospital_atendimento_conduta.proxima_consulta');

      if (estagiario != null || professor != null || proximaConsulta != null) {
        return {
          'estagiarioNome': estagiario,
          'professorNome': professor,
          'proximaConsulta': proximaConsulta,
        };
      }
      return null;
    } catch (e) {
      print('Erro ao carregar do cache: $e');
      return null;
    }
  }

  void _instanciarDadosCache(Map<String, dynamic> dados) {
    setState(() {
      _estagiarioNomeController.text = dados['estagiarioNome'] ?? '';
      _professorSelecionado = dados['professorNome'] ?? 'Selecione';
      _proximaConsultaController.text = dados['proximaConsulta'] ?? '';
    });
  }

  Future<void> _carregarUsuarioLogado() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _estagiarioNomeController.text = doc['nome'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar usuário logado: $e');
    }
  }

  Future<void> _carregarProfessores() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('tipo_usuario', whereIn: ['Professor', 'Coordenador']).get();

      final professorSalvo =
          await _atendimentoService.carregarProfessorSelecionado();
      final professores =
          snapshot.docs.map((doc) => doc['nome'] as String).toList();

      if (mounted) {
        setState(() {
          _professores = ['Selecione', ...professores];
          _professorSelecionado = professorSalvo ?? 'Selecione';
        });
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Falha ao carregar lista de professores',
        isError: true,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _finalizar() async {
    if (_professorSelecionado == null || _professorSelecionado == 'Selecione') {
      setState(() => _professorSelecionadoError = true);
      setState(() => _errorMessage = 'Selecione um professor supervisor');
      ToastUtil.showToast(
        context: context,
        message: 'Selecione um professor supervisor',
        isError: true,
      );
      return;
    }

    _professorSelecionadoError = false;
    _errorMessage = null;

    setState(() => isLoading = true);
    try {
      // 1. Buscar IDs do estagiário e professor
      final estagiarioId =
          await _buscarIdUsuarioPorNome(_estagiarioNomeController.text);
      final professorId = await _buscarIdUsuarioPorNome(_professorSelecionado!);

      if (estagiarioId == null || professorId == null) {
        throw Exception('Não foi possível encontrar os IDs necessários');
      }

      // 2. Salva o professor selecionado
      await _atendimentoService
          .salvarProfessorSelecionado(_professorSelecionado!);

      // 3. Salva conduta localmente com os IDs
      await _atendimentoService.salvarCondutaNutricional(
        estagiario: _estagiarioNomeController.text,
        professor: _professorSelecionado!,
        idEstagiario: estagiarioId,
        idProfessor: professorId,
        proximaConsulta: _isHospital ? _proximaConsultaController.text : null,
      );

      // 4. Obtém todos os dados consolidados localmente
      final dadosCompletos = await _atendimentoService.obterDadosCompletos();

      // 5. Salva os dados completos no Firebase
      await _atendimentoService.salvarAtendimentoNoFirebase(dadosCompletos);

      // 6. Limpa dados locais (incluindo o professor selecionado)
      await _atendimentoService.limparTodosDados();

      // 7. Feedback e navegação
      ToastUtil.showToast(
        context: context,
        message: 'Atendimento salvo com sucesso!',
        isError: false,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao finalizar atendimento! Tente novamente mais tarde.',
        isError: true,
      );
      print('Erro ao finalizar atendimento ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<String?> _buscarIdUsuarioPorNome(String nome) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar ID do usuário: $e');
      return null;
    }
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
          setState(() => isLoading = true);
          try {
            await _atendimentoService.limparTodosDados();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AtendimentoPage()),
                (route) => false,
              );
            }
          } catch (e) {
            ToastUtil.showToast(
              context: context,
              message: 'Erro ao cancelar atendimento',
              isError: true,
            );
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double espacamentoCards = 10;

    return Stack(
      children: [
        BasePage(
          title: 'Conduta Nutricional',
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: CustomCard(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInput(
                        label: 'Aluno Responsável',
                        controller: _estagiarioNomeController,
                        keyboardType: TextInputType.text,
                        enabled: false,
                      ),
                      SizedBox(height: espacamentoCards),
                      CustomDropdown(
                        label: 'Professor Supervisor',
                        value: _professorSelecionado ?? 'Selecione',
                        items: _professores,
                        enabled: true,
                        obrigatorio: true,
                        error: _professorSelecionadoError,
                        errorMessage: _errorMessage,
                        onChanged: (valor) {
                          setState(() {
                            _professorSelecionado = valor!;
                          });
                        },
                      ),

                      // Campo condicional para hospital
                      if (_isHospital) ...[
                        SizedBox(height: espacamentoCards),
                        CustomInput(
                          label: 'Programação próxima consulta',
                          controller: _proximaConsultaController,
                          keyboardType: TextInputType.text,
                        ),
                      ],

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
                                text: 'Finalizar',
                                onPressed: _finalizar,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
