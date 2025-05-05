import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObservacaoRelatorio extends StatefulWidget {
  final String pageKey;
  final bool isFinalPage;
  final String atendimentoId;
  final bool isHospital;

  const ObservacaoRelatorio({
    super.key,
    required this.pageKey,
    required this.atendimentoId,
    required this.isHospital,
    this.isFinalPage = false,
  });

  @override
  _ObservacaoRelatorioState createState() => _ObservacaoRelatorioState();
}

class _ObservacaoRelatorioState extends State<ObservacaoRelatorio> {
  final TextEditingController _observacaoController = TextEditingController();
  bool _showDialog = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadObservacao();
  }

  Future<void> _loadObservacao() async {
    final prefs = await SharedPreferences.getInstance();
    final observacao = prefs.getString('observacao_${widget.pageKey}');
    if (observacao != null) {
      _observacaoController.text = observacao;
    }
  }

  Future<void> _saveObservacaoLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'observacao_${widget.pageKey}',
      _observacaoController.text,
    );
  }

  Future<void> _saveObservacaoToFirestore() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final todasObservacoes = <String, String>{};
      
      // Coletar todas as observações salvas localmente
      final keys = [
        'identificacao',
        'dados_socioeconomicos',
        'antecedentes_pessoais',
        'antecedentes_familiares',
        'dados_clinicos_nutricionais',
        'dados_antropometricos',
        'consumo_alimentar',
        'requerimentos_nutricionais',
        'conduta_nutricional',
      ];
      
      for (final key in keys) {
        final observacao = prefs.getString('observacao_$key');
        if (observacao != null && observacao.isNotEmpty) {
          todasObservacoes[key] = observacao;
        }
      }
      
      // Determinar a coleção correta (hospital ou clínica)
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      // Salvar as observações no documento do atendimento
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .update({
            'observacao': todasObservacoes,
          });
      
      // Limpar todas as observações locais
      for (final key in keys) {
        await prefs.remove('observacao_$key');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Observações enviadas para correção!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar observações: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      if (mounted) {
        setState(() => _showDialog = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => setState(() => _showDialog = true),
            child: const Icon(Icons.edit_note),
            tooltip: 'Adicionar observações',
          ),
        ),
        if (_showDialog)
          AlertDialog(
            title: const Text('Observações para Correção'),
            content: SingleChildScrollView(
              child: TextField(
                controller: _observacaoController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Digite as observações para correção...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setState(() => _showDialog = false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (widget.isFinalPage) {
                    await _saveObservacaoToFirestore();
                  } else {
                    await _saveObservacaoLocally();
                    if (mounted) {
                      setState(() => _showDialog = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Observação salva!')),
                      );
                    }
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.isFinalPage ? 'Enviar Correções' : 'Salvar'),
              ),
            ],
          ),
      ],
    );
  }
}