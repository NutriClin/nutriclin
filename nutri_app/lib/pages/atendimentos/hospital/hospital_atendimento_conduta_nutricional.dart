import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_dropdown.dart';
import 'package:nutri_app/components/custom_input.dart';

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

  String? _professorSelecionado;
  List<String> _professores = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuarioLogado();
    _carregarProfessores();
  }

  Future<void> _carregarUsuarioLogado() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuario')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _estagiarioNomeController.text = doc['nome'];
        });
      }
    }
  }

  Future<void> _carregarProfessores() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('tipo_usuario', isEqualTo: 'Professor')
        .get();

    setState(() {
      _professores =
          snapshot.docs.map((doc) => doc['nome'].toString()).toList();
      if (_professores.isNotEmpty) {
        _professorSelecionado = _professores.first;
      }
    });
  }

  void _finalizar() {
    // Salvar conduta ou enviar dados
    // Exemplo:
    // FirebaseFirestore.instance.collection('condutas').add({ ... });
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
                    label: 'Diagnóstico Clínico',
                    controller: _estagiarioNomeController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: espacamentoCards),
                  CustomDropdown(
                    label: 'Professor Supervisor:',
                    value: _professorSelecionado ?? 'Selecione',
                    items: _professores,
                    enabled: true,
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
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
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
