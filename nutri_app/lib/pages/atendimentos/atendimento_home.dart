import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_box.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/pages/atendimentos/atendimentos/hospital_atendimento_identificacao.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_app/services/atendimento_service.dart';

class AtendimentoPage extends StatelessWidget {
  AtendimentoPage({super.key});
  final AtendimentoService _atendimentoService = AtendimentoService();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Atendimento',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildCards(context),
          ),
        ),
      ),
    );
  }

  Future<void> _verificarDadosExistente(
    BuildContext context,
    String prefKey,
    Widget nextPage,
    String tipoAtendimento,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();
    final dadosExistentes = keys.where((key) => key.startsWith(prefKey));

    final tipoAtendimentoSalvo =
        await _atendimentoService.obterTipoAtendimento();

    if (dadosExistentes.isNotEmpty || tipoAtendimentoSalvo != null) {
      _mostrarModalConfirmacao(context, prefKey, nextPage, tipoAtendimento);
    } else {
      await _atendimentoService.salvarTipoAtendimento(tipoAtendimento);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  void _mostrarModalConfirmacao(
    BuildContext context,
    String prefKey,
    Widget nextPage,
    String tipoAtendimento,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: 'Atendimento existente',
        message:
            'Já existe um atendimento em andamento. Deseja continuar com os dados existentes?',
        confirmText: 'Continuar',
        cancelText: 'Criar novo',
        onConfirm: () {
          Navigator.of(context, rootNavigator: true).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => nextPage),
            );
          });
        },
        onCancel: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          await _atendimentoService.limparTodosDados();
          await _atendimentoService.salvarTipoAtendimento(tipoAtendimento);

          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => nextPage),
            );
          });
        },
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    List<Widget> cards = [];

    double labelFontSize = 12;
    cards.addAll([
      CustomBox(
        text: 'Clínica',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/clinica.svg',
        onTap: () => _verificarDadosExistente(
          context,
          'clinica_atendimento',
          const HospitalAtendimentoIdentificacaoPage(),
          'clínica',
        ),
      ),
      const SizedBox(width: 20),
      CustomBox(
        text: 'Hospital',
        labelFontSize: labelFontSize,
        imagePath: 'assets/imagens/doctor.svg',
        onTap: () => _verificarDadosExistente(
          context,
          'hospital_atendimento',
          const HospitalAtendimentoIdentificacaoPage(),
          'hospital',
        ),
      ),
    ]);

    return cards;
  }
}
