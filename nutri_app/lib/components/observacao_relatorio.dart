import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/services/atendimento_service.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';

class ObservacaoRelatorio extends StatefulWidget {
  final bool modoLeitura;
  final String atendimentoId;
  final bool isHospital; // Adicione este parâmetro para determinar a coleção

  const ObservacaoRelatorio({
    super.key,
    this.modoLeitura = false,
    required this.atendimentoId,
    required this.isHospital,
  });

  @override
  _ObservacaoRelatorioState createState() => _ObservacaoRelatorioState();
}

class _ObservacaoRelatorioState extends State<ObservacaoRelatorio> {
  final AtendimentoService _atendimentoService = AtendimentoService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _observacaoController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingObservacao = false;

  @override
  void initState() {
    super.initState();
    _carregarObservacao();
  }

  Future<Map<String, dynamic>?> carregarObservacaoFirestore(
      String atendimentoId, bool isHospital) async {
    try {
      final collection = isHospital ? 'atendimento' : 'clinica';
      final doc =
          await _firestore.collection(collection).doc(atendimentoId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Erro ao carregar do Firestore: $e");
      return null;
    }
  }

  Future<void> salvarObservacaoFirestore(
      String atendimentoId, bool isHospital, String observacao) async {
    try {
      final collection = isHospital ? 'atendimento' : 'clinica';
      await _firestore.collection(collection).doc(atendimentoId).set({
        'observacao_geral': observacao,
        'ultima_atualizacao': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao salvar no Firestore: $e");
      throw e;
    }
  }

  Future<void> _carregarObservacao() async {
    if (!mounted) return;

    setState(() => _isLoadingObservacao = true);

    try {
      final dadosFirestore = await carregarObservacaoFirestore(
        widget.atendimentoId,
        widget.isHospital,
      );

      if (dadosFirestore != null && dadosFirestore.isNotEmpty) {
        if (mounted) {
          setState(() {
            _observacaoController.text =
                dadosFirestore['observacao_geral'] ?? '';
          });
        }
      } else {
        await _carregarObservacaoLocal();
      }
    } catch (e) {
      print("Erro ao carregar observações: $e");
      await _carregarObservacaoLocal();
    } finally {
      if (mounted) {
        setState(() => _isLoadingObservacao = false);
      }
    }
  }

  Future<void> _carregarObservacaoLocal() async {
    try {
      final dados = await _atendimentoService.carregarAntecedentesPessoais();
      if (dados.isNotEmpty && mounted) {
        setState(() {
          _observacaoController.text = dados['observacao_geral'] ?? '';
        });
      }
    } catch (e) {
      print("Erro ao carregar observações locais: $e");
      if (mounted) {
        setState(() {
          _observacaoController.text = '';
        });
      }
    }
  }

  Future<void> _salvarObservacao() async {
    setState(() => _isLoading = true);
    try {
      await _salvarObservacaoLocal();
    } catch (e) {
      print("Erro ao salvar observações: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarObservacaoLocal() async {
    try {
      await _atendimentoService.salvarObservacaoLocal(
        _observacaoController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar observações: $e')),
        );
      }
    }
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
        ),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            CustomCard(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isLoadingObservacao
                        ? const Center(child: CircularProgressIndicator())
                        : widget.modoLeitura
                            ? Text(
                                _observacaoController.text.isEmpty
                                    ? 'Nenhuma observação cadastrada'
                                    : _observacaoController.text,
                                style: const TextStyle(fontSize: 16),
                              )
                            : TextField(
                                controller: _observacaoController,
                                maxLines: 10,
                                minLines: 5,
                                decoration: const InputDecoration(
                                  hintText: 'Digite suas observações...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        text: 'Fechar',
                        onPressed: () async {
                          if (!widget.modoLeitura) {
                            await _salvarObservacao();
                          }
                          if (mounted) Navigator.pop(context);
                        },
                        color: const Color(0xFF007AFF),
                        textColor: Colors.white,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: _showCustomDialog,
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_note, size: 28),
        tooltip: 'Observações',
      ),
    );
  }
}
