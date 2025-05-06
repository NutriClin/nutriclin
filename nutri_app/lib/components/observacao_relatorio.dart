import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';

class ObservacaoRelatorio extends StatefulWidget {
  final bool modoLeitura;

  const ObservacaoRelatorio({
    super.key,
    this.modoLeitura = false,
  });

  @override
  _ObservacaoRelatorioState createState() => _ObservacaoRelatorioState();
}

class _ObservacaoRelatorioState extends State<ObservacaoRelatorio> {
  final TextEditingController _observacaoController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingObservacao = false;

  @override
  void initState() {
    super.initState();
    _carregarObservacaoLocal();
  }

  Future<void> _carregarObservacaoLocal() async {
    setState(() => _isLoadingObservacao = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final observacao = prefs.getString('observacao_geral');
      if (observacao != null) {
        _observacaoController.text = observacao;
      }
    } catch (e) {
      print("Erro ao carregar observações locais: $e");
    } finally {
      setState(() => _isLoadingObservacao = false);
    }
  }

  Future<void> _saveObservacaoLocally() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('observacao_geral', _observacaoController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar observações: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.modoLeitura
                          ? 'Observações do Professor'
                          : 'Observações',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                decoration: InputDecoration(
                                  hintText: 'Digite suas observações...',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        text: 'Fechar',
                        onPressed: () async {
                          if (!widget.modoLeitura) {
                            await _saveObservacaoLocally();
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
        child: const Icon(Icons.edit_note),
        tooltip: widget.modoLeitura
            ? 'Editar observações'
            : 'Visualizar observações',
      ),
    );
  }
}
