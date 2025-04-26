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

  final AtendimentoService _atendimentoService = AtendimentoService();

  String? _professorSelecionado;
  List<String> _professores = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuarioLogado();
    _carregarProfessores();
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
      ToastUtil.showToast(
        context: context,
        message: 'Falha ao carregar dados do usuário',
        isError: true,
      );
    }
  }

  Future<void> _carregarProfessores() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('tipo_usuario', whereIn: ['Professor', 'Coordenador']).get();

      final professores = snapshot.docs.map((doc) {
        return doc['nome'] as String;
      }).toList();

      setState(() {
        _professores = ['Selecione', ...professores];
        _professorSelecionado = 'Selecione';
      });
    } catch (e) {
      print('Erro ao carregar professores: $e');
      ToastUtil.showToast(
        context: context,
        message: 'Falha ao carregar professores',
        isError: true,
      );
    }
  }

  Future<void> _finalizar() async {
    if (_professorSelecionado == null || _professorSelecionado == 'Selecione') {
      ToastUtil.showToast(
        context: context,
        message: 'Selecione um professor supervisor',
        isError: true,
      );
      return;
    }

    try {
      // 1. Salva conduta localmente
      await _atendimentoService.salvarCondutaNutricional(
        estagiario: _estagiarioNomeController.text,
        professor: _professorSelecionado!,
      );

      // 2. Obtém todos os dados consolidados
      final dadosCompletos = await _atendimentoService.obterDadosCompletos();

      // 3. Salva no Firebase
      await _atendimentoService.salvarAtendimentoNoFirebase(dadosCompletos);

      // 4. Limpa dados locais
      await _atendimentoService.limparTodosDados();

      // 5. Feedback e navegação
      ToastUtil.showToast(
        context: context,
        message: 'Atendimento salvo com sucesso!',
        isError: false,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AtendimentoPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao finalizar atendimento!. Tente novamente mais tarde.',
        isError: true,
      );
      print('Erro ao finalizar atendimento ${e.toString()}');
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
        onConfirm: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AtendimentoPage()),
              (route) => false,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double espacamentoCards = 10;

    return BasePage(
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
                    onChanged: (valor) {
                      setState(() {
                        _professorSelecionado = valor!;
                      });
                    },
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
    );
  }
}
