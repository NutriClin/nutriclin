import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/custom_list_atendimento.dart'; // Importa o novo widget

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLastPage = false;
  DocumentSnapshot? _lastDocument;
  bool _error = false;
  bool _initialLoading = true;
  bool _loadingMore = false;
  final int _limit = 100;

  List<Map<String, dynamic>> _atendimentos = [];
  List<Map<String, dynamic>> _atendimentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filtrarAtendimentos);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_filtrarAtendimentos);
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      if (!_loadingMore && !_isLastPage) {
        _fetchMoreData();
      }
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('atendimento')
          .orderBy('nome')
          .limit(_limit)
          .get();

      _processQuerySnapshot(querySnapshot);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _fetchMoreData() async {
    if (_isLastPage || _loadingMore) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('atendimento')
          .orderBy('nome')
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();
      _processQuerySnapshot(querySnapshot);
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void _processQuerySnapshot(QuerySnapshot querySnapshot) {
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _isLastPage = true;
      });
      return;
    }

    List<Map<String, dynamic>> newAtendimentos = querySnapshot.docs.map((doc) {
      Timestamp timestamp = doc['criado_em'] ?? Timestamp.now();
      DateTime data = timestamp.toDate();

      return {
        'id': doc.id,
        'nome': doc['nome'],
        'status_atendimento': doc['status_atendimento'],
        'data': data,
      };
    }).toList();

    setState(() {
      _initialLoading = false;
      _lastDocument = querySnapshot.docs.last;
      _atendimentos.addAll(newAtendimentos);
      _atendimentosFiltrados = List.from(_atendimentos);
      _isLastPage = newAtendimentos.length < _limit;
    });
  }

  void _handleError(dynamic e) {
    print("error --> $e");
    ToastUtil.showToast(
      context: context,
      message: 'Erro ao carregar atendimentos: ${e.toString()}',
      isError: true,
    );
    setState(() {
      _initialLoading = false;
      _error = true;
      _loadingMore = false;
    });
  }

  void _filtrarAtendimentos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _atendimentosFiltrados = _atendimentos.where((atendimento) {
        return atendimento["nome"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BasePage(
          title: 'Atendimentos',
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomInputSearch(controller: _searchController),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildAtendimentoList(),
                ),
              ],
            ),
          ),
        ),
        if (_initialLoading)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (_initialLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildAtendimentoList() {
    if (_initialLoading) {
      return const SizedBox();
    }

    if (_error && _atendimentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ocorreu um erro ao carregar os atendimentos.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initialLoading = true;
                  _error = false;
                  _atendimentos.clear();
                  _lastDocument = null;
                  _isLastPage = false;
                  _fetchInitialData();
                });
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_atendimentosFiltrados.isEmpty) {
      return const Center(child: Text("Nenhum atendimento encontrado."));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _atendimentosFiltrados.length + 1,
      itemBuilder: (context, index) {
        if (index < _atendimentosFiltrados.length) {
          final atendimento = _atendimentosFiltrados[index];
          return CustomListAtendimento(report: atendimento);
        } else {
          if (_isLastPage) {
            return const SizedBox(height: 100); // Espaço extra no final
          } else {
            return _buildLoader();
          }
        }
      },
    );
  }

  Widget _buildLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _error
            ? Column(
                children: [
                  const Text(
                    'Erro ao carregar mais atendimentos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _fetchMoreData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
