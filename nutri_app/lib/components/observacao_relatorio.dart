import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObservacaoRelatorio extends StatefulWidget {
  final String pageKey;
  final bool isFinalPage;
  final String atendimentoId;
  final bool isHospital;
  final bool modoLeitura; // Novo parâmetro

  const ObservacaoRelatorio({
    super.key,
    required this.pageKey,
    required this.atendimentoId,
    required this.isHospital,
    this.isFinalPage = false,
    this.modoLeitura = false, // Valor padrão false
  });

  @override
  _ObservacaoRelatorioState createState() => _ObservacaoRelatorioState();
}

class _ObservacaoRelatorioState extends State<ObservacaoRelatorio> {
  final TextEditingController _observacaoController = TextEditingController();
  bool _showDialog = false;
  bool _isLoading = false;
  bool _isLoadingObservacao = false;

  @override
  void initState() {
    super.initState();
    if (widget.modoLeitura) {
      _carregarObservacaoFirestore();
    } else {
      _loadObservacao();
    }
  }

  Future<void> _carregarObservacaoFirestore() async {
    setState(() => _isLoadingObservacao = true);
    try {
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .get();

      if (doc.exists) {
        final observacoes = doc.data()?['observacao'] as Map<String, dynamic>?;
        final observacao = observacoes?[widget.pageKey] as String?;
        _observacaoController.text = observacao ?? '';
      }
    } catch (e) {
      print("Erro ao carregar observação: $e");
    } finally {
      setState(() => _isLoadingObservacao = false);
    }
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
      
      final collection = widget.isHospital ? 'atendimento' : 'clinica';
      
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.atendimentoId)
          .update({
            'observacao': todasObservacoes,
          });
      
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
            tooltip: widget.modoLeitura 
                ? 'Visualizar observações' 
                : 'Adicionar observações',
          ),
        ),
        if (_showDialog)
          AlertDialog(
            title: Text(widget.modoLeitura
                ? 'Observações do Professor'
                : 'Observações para Correção'),
            content: SingleChildScrollView(
              child: _isLoadingObservacao
                  ? const Center(child: CircularProgressIndicator())
                  : TextField(
                      controller: _observacaoController,
                      maxLines: 10,
                      readOnly: widget.modoLeitura, // Campo somente leitura
                      decoration: InputDecoration(
                        hintText: widget.modoLeitura
                            ? 'Nenhuma observação cadastrada'
                            : 'Digite as observações para correção...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => setState(() => _showDialog = false),
                child: const Text('Fechar'),
              ),
              if (!widget.modoLeitura) // Mostra apenas se não for modo leitura
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