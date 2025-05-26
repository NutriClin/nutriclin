import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_card.dart';
import 'package:nutri_app/components/custom_input.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/observacao_relatorio.dart';
import 'package:nutri_app/components/custom_stepper.dart';
import 'package:nutri_app/components/custom_confirmation_dialog.dart';
import 'package:nutri_app/services/atendimento_service.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'dart:convert';

class RelatorioProfessorCondutaNutricionalPage extends StatefulWidget {
  final String atendimentoId;
  final bool isHospital;

  const RelatorioProfessorCondutaNutricionalPage({
    super.key,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _RelatorioProfessorCondutaNutricionalPageState createState() =>
      _RelatorioProfessorCondutaNutricionalPageState();
}

class _RelatorioProfessorCondutaNutricionalPageState
    extends State<RelatorioProfessorCondutaNutricionalPage> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _estagiarioNomeController =
      TextEditingController();
  final TextEditingController _proximaConsultaController =
      TextEditingController();
  final TextEditingController _professorController = TextEditingController();

  bool _proximaConsultaError = false;
  bool isLoading = true;
  bool hasError = false;
  bool isSaving = false;
  bool isProfessor = false;
  bool isAluno = false;
  String statusAtendimento = '';
  bool modoEdicao = false;

  @override
  void initState() {
    super.initState();
    _checkUserType().then((_) {
      _carregarDadosAtendimento();
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

        setState(() {
          _estagiarioNomeController.text = data['nome_aluno'] ?? '';
          _professorController.text = data['nome_professor'] ?? '';
          if (widget.isHospital) {
            _proximaConsultaController.text = data['proxima_consulta'] ?? '';
          }
          statusAtendimento = data['status_atendimento'] ?? '';
          modoEdicao = isAluno && statusAtendimento == 'rejeitado';
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

  bool _validarCampos() {
    bool valido = true;
    if (widget.isHospital && _proximaConsultaController.text.trim().isEmpty) {
      _proximaConsultaError = true;
      valido = false;
    } else {
      _proximaConsultaError = false;
    }
    setState(() {});
    return valido;
  }

  bool get podeEditar {
    return isAluno && statusAtendimento == 'rejeitado';
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Function() onConfirm,
    String cancelText = 'Cancelar',
    Color confirmColor = const Color(0xFF007AFF),
    Color cancelColor = Colors.red,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        onConfirm: onConfirm,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _atualizarStatus(String status) async {
    setState(() => isSaving = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      final doc = await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();
      final dadosAtuais = doc.data() ?? {};

      final observacao = await _atendimentoService.carregarObservacao();

      final dadosAtualizados = {
        ...dadosAtuais,
        'status_atendimento': status,
        'data_avaliacao': FieldValue.serverTimestamp(),
        'observacao_geral': observacao ?? '',
      };

      await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .update(dadosAtualizados);

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento $status com sucesso!',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, '/relatorio');
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao atualizar status: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _enviarAtendimento() async {
    if (!_validarCampos()) {
      ToastUtil.showToast(
        context: context,
        message: 'Por favor, preencha todos os campos obrigatórios!',
        isError: true,
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      final dadosCompletos = await _atendimentoService.obterDadosCompletos();

      dadosCompletos.remove('id_professor_supervisor');
      dadosCompletos.remove('id_aluno');
      dadosCompletos.remove('nome_professor');
      dadosCompletos.remove('nome_aluno');
      dadosCompletos.remove('status_atendimento');
      dadosCompletos.remove('criado_em');
      dadosCompletos.remove('data');

      if (widget.isHospital) {
        dadosCompletos['proxima_consulta'] = _proximaConsultaController.text;
      }

      dadosCompletos['status_atendimento'] = 'enviado';
      dadosCompletos['observacao_geral'] = '';

      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .update(dadosCompletos);

      ToastUtil.showToast(
        context: context,
        message: 'Atendimento enviado com sucesso para revisão!',
        isError: false,
      );
      Navigator.pushReplacementNamed(context, '/relatorio');
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao enviar atendimento: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      final docSnapshot = await _firestore
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();

      if (!docSnapshot.exists) {
        ToastUtil.showToast(
          context: context,
          message: 'Documento não encontrado',
          isError: true,
        );
        return;
      }

      final dadosCompletos = docSnapshot.data() as Map<String, dynamic>;

      // Criar Excel
      final excel = Excel.createExcel();
      final sheet = excel['Atendimento'];

      // Função para formatar valores
      String formatValue(dynamic value) {
        if (value == null) return '';
        if (value is Timestamp) return value.toDate().toString();
        if (value is Map) return jsonEncode(value);
        return value.toString();
      }

      // Adicionar cabeçalhos
      sheet.appendRow([
         TextCellValue('Campo'),
         TextCellValue('Valor'),
      ]);

      // Adicionar todos os campos organizados
      final sections = {
        'Identificação': ['nome', 'sexo', 'data_nascimento', 'hospital', 'clinica', 'quarto', 'leito', 'registro', 'prontuario'],
        'Dados Socioeconômicos': ['agua_encanada', 'esgoto_encanado', 'coleta_lixo', 'luz_eletrica', 'tipo_casa', 'numero_pessoas_moram_junto', 'renda_familiar', 'renda_per_capita', 'escolaridade', 'profissao', 'producao_domestica_alimentos'],
        'Antecedentes Pessoais': ['dislipidemias_pessoais', 'has_pessoais', 'cancer_pessoais', 'excesso_peso_pessoais', 'diabetes_pessoais', 'outros_antecedentes_pessoais', 'outros_antecedentes_pessoais_descricao'],
        'Antecedentes Familiares': ['dislipidemias_familiares', 'has_familiares', 'cancer_familiares', 'excesso_peso_familiares', 'diabetes_familiares', 'outros_antecedentes_familiares', 'outros_antecedentes_familiares_descricao'],
        'Dados Clínicos': ['diagnostico_clinico', 'prescricao_dietoterapica', 'aceitacao', 'alimentacao_habitual', 'resumo_alimentacao_habitual', 'possui_doenca_anterior', 'resumo_doenca_anterior', 'possui_cirurgia_recente', 'resumo_cirurgia_recente', 'possui_febre', 'possui_alteracao_peso_recente', 'quantidade_perca_peso_recente', 'possui_desconforto_oral_gastrointestinal', 'possui_necessidade_dieta_hospitalar', 'resumo_necessidade_dieta_hospitalar', 'possui_suplementacao_nutricional', 'resumo_suplemento_nutricional', 'possui_tabagismo', 'possui_etilismo', 'possui_condicao_funcional', 'resumo_condicao_funcional', 'resumo_medicamentos_vitaminas_minerais_prescritos', 'resumo_exames_laboratoriais', 'resumo_exame_fisico'],
        'Dados Antropométricos': ['peso_atual', 'peso_usual', 'estatura', 'imc', 'pi', 'cb', 'pct', 'pcb', 'pcse', 'pcsi', 'cmb', 'ca', 'cp', 'aj', 'porcentagem_gc', 'porcentagem_perca_peso_por_tempo', 'diagnostico_nutricional'],
        'Consumo Alimentar': ['habitual', 'atual', 'ingestao_hidrica', 'evacuacao', 'diurese'],
        'Requerimentos Nutricionais': ['kcal_dia', 'kcal_kg', 'cho', 'lip', 'Ptn', 'ptn_kg', 'ptn_dia', 'liquido_kg', 'liquido_dia', 'fibras', 'outros_requerimentos_nutricionais'],
        'Conduta Nutricional': ['estagiario', 'professor', 'proxima_consulta'],
        'Metadados': ['status_atendimento', 'criado_em', 'data']
      };

      sections.forEach((sectionName, fields) {
        sheet.appendRow([TextCellValue('--- $sectionName ---')]);
        fields.forEach((field) {
          if (dadosCompletos.containsKey(field)) {
            sheet.appendRow([
              TextCellValue(_formatFieldName(field)),
              TextCellValue(formatValue(dadosCompletos[field])),
            ]);
          }
        });
      });

      // Gerar e baixar arquivo
      final excelBytes = excel.encode()!;
      final base64 = base64Encode(excelBytes);
      final anchor = AnchorElement(
        href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64',
      );
      anchor.setAttribute('download', 'atendimento_${widget.atendimentoId}.xlsx');
      anchor.click();

      ToastUtil.showToast(
        context: context,
        message: 'Arquivo Excel gerado com sucesso!',
        isError: false,
      );
    } catch (e) {
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao gerar Excel: $e',
        isError: true,
      );
    }
  }

  String _formatFieldName(String field) {
    return field.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  void dispose() {
    _estagiarioNomeController.dispose();
    _proximaConsultaController.dispose();
    _professorController.dispose();
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
          title: 'Conduta Nutricional',
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    const CustomStepper(
                      currentStep: 9,
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
                              label: 'Aluno Responsável',
                              controller: _estagiarioNomeController,
                              enabled: false,
                            ),
                            SizedBox(height: espacamentoCards),
                            CustomInput(
                              label: 'Professor Supervisor',
                              controller: _professorController,
                              enabled: false,
                            ),
                            if (widget.isHospital) ...[
                              SizedBox(height: espacamentoCards),
                              CustomInput(
                                label: 'Programação próxima consulta',
                                controller: _proximaConsultaController,
                                enabled: modoEdicao,
                                obrigatorio: true,
                                error: _proximaConsultaError,
                                errorMessage: 'Campo obrigatório',
                                onChanged: (value) {
                                  if (_proximaConsultaError && value.isNotEmpty) {
                                    setState(() => _proximaConsultaError = false);
                                  }
                                },
                              ),
                            ],
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
                                    if (isProfessor) 
                                      CustomButton(
                                        text: 'Exportar Excel',
                                        onPressed: _exportToExcel,
                                        color: Colors.green,
                                        textColor: Colors.white,
                                      ),
                                    const SizedBox(width: 10),
                                    CustomButton(
                                      text: 'Voltar',
                                      onPressed: () => Navigator.pop(context),
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      boxShadowColor: Colors.black,
                                    ),
                                    if (isProfessor &&
                                        statusAtendimento == 'enviado')
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          CustomButton(
                                            text: 'Rejeitar',
                                            onPressed: () =>
                                                _showConfirmationDialog(
                                              title: 'Confirmar Rejeição',
                                              message:
                                                  'Tem certeza que deseja rejeitar este atendimento?',
                                              confirmText: 'Rejeitar',
                                              confirmColor: Colors.red,
                                              onConfirm: () =>
                                                  _atualizarStatus('rejeitado'),
                                            ),
                                            color: Colors.red,
                                            textColor: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          CustomButton(
                                            text: 'Aprovar',
                                            onPressed: () =>
                                                _showConfirmationDialog(
                                              title: 'Confirmar Aprovação',
                                              message:
                                                  'Tem certeza que deseja aprovar este atendimento?',
                                              confirmText: 'Aprovar',
                                              onConfirm: () =>
                                                  _atualizarStatus('aprovado'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (modoEdicao) 
                                    const SizedBox(width: 10),
                                    if (modoEdicao)
                                      CustomButton(
                                        text: 'Enviar para Revisão',
                                        onPressed: () =>
                                            _showConfirmationDialog(
                                          title: 'Confirmar Envio',
                                          message:
                                              'Tem certeza que deseja enviar este atendimento para revisão?',
                                          confirmText: 'Enviar',
                                          onConfirm: _enviarAtendimento,
                                        ),
                                        color: Colors.blue,
                                        textColor: Colors.white,
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
            modoLeitura: modoEdicao,
            atendimentoId: widget.atendimentoId,
            isHospital: widget.isHospital,
          ),
        if (isSaving)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isSaving)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}