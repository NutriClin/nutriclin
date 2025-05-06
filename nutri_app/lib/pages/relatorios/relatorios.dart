import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/custom_list_atendimento.dart';
import 'package:nutri_app/services/preferences_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLastPage = false;
  DocumentSnapshot? _lastAtendimentoDoc;
  DocumentSnapshot? _lastClinicaDoc;
  bool _error = false;
  bool _initialLoading = true;
  bool _loadingMore = false;
  final int _limit = 100;

  List<Map<String, dynamic>> _atendimentos = [];
  List<Map<String, dynamic>> _atendimentosFiltrados = [];
  String? _userType;
  String? _userId;
  String orderBy = 'data';

  @override
  void initState() {
    super.initState();
    _getUserInfo().then((_) {
      _fetchInitialData();
    });
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filtrarAtendimentos);
  }

  Future<void> _getUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userType = await PreferencesService.getUserType();

        setState(() {
          _userType = userType;
          _userId = user.uid;
        });
      }
    } catch (e) {
      _handleError(e);
    }
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
      // Consulta para atendimentos
      Query atendimentoQuery =
          FirebaseFirestore.instance.collection('atendimento');

      if (_userType == 'Professor') {
        atendimentoQuery = atendimentoQuery
            .where('id_professor_supervisor', isEqualTo: _userId)
            .orderBy('data', descending: true);
      } else if (_userType == 'Aluno') {
        atendimentoQuery = atendimentoQuery
            .where('id_aluno', isEqualTo: _userId)
            .orderBy('data', descending: true);
      } else {
        atendimentoQuery = atendimentoQuery.orderBy('data', descending: true);
      }

      final atendimentoSnapshot = await atendimentoQuery.limit(_limit).get();
      _processQuerySnapshot(atendimentoSnapshot, 'atendimento');
      _lastAtendimentoDoc = atendimentoSnapshot.docs.isNotEmpty
          ? atendimentoSnapshot.docs.last
          : null;

      // Consulta para clínicas
      Query clinicaQuery = FirebaseFirestore.instance.collection('clinica');

      if (_userType == 'Professor') {
        clinicaQuery = clinicaQuery
            .where('id_professor_supervisor', isEqualTo: _userId)
            .orderBy('data', descending: true);
      } else if (_userType == 'Aluno') {
        clinicaQuery = clinicaQuery
            .where('id_aluno', isEqualTo: _userId)
            .orderBy('data', descending: true);
      } else {
        clinicaQuery = clinicaQuery.orderBy('data', descending: true);
      }

      final clinicaSnapshot = await clinicaQuery.limit(_limit).get();
      _processQuerySnapshot(clinicaSnapshot, 'clinica');
      _lastClinicaDoc =
          clinicaSnapshot.docs.isNotEmpty ? clinicaSnapshot.docs.last : null;

      // Se ambas as consultas retornaram vazias, define _initialLoading como false
      if (atendimentoSnapshot.docs.isEmpty && clinicaSnapshot.docs.isEmpty) {
        setState(() {
          _initialLoading = false;
          _isLastPage = true;
        });
      }
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
      if (_lastAtendimentoDoc != null) {
        Query atendimentoQuery =
            FirebaseFirestore.instance.collection('atendimento');

        if (_userType == 'Professor') {
          atendimentoQuery = atendimentoQuery
              .where('id_professor_supervisor', isEqualTo: _userId)
              .orderBy('data', descending: true);
        } else if (_userType == 'Aluno') {
          atendimentoQuery = atendimentoQuery
              .where('id_aluno', isEqualTo: _userId)
              .orderBy('data', descending: true);
        } else {
          atendimentoQuery = atendimentoQuery.orderBy('data', descending: true);
        }

        final atendimentoSnapshot = await atendimentoQuery
            .startAfterDocument(_lastAtendimentoDoc!)
            .limit(_limit)
            .get();

        _processQuerySnapshot(atendimentoSnapshot, 'atendimento');
        _lastAtendimentoDoc = atendimentoSnapshot.docs.isNotEmpty
            ? atendimentoSnapshot.docs.last
            : null;
      }

      // Carregar mais clínicas
      if (_lastClinicaDoc != null) {
        Query clinicaQuery = FirebaseFirestore.instance.collection('clinica');

        if (_userType == 'Professor') {
          clinicaQuery = clinicaQuery
              .where('id_professor_supervisor  ', isEqualTo: _userId)
              .orderBy('data', descending: true);
        } else if (_userType == 'Aluno') {
          clinicaQuery = clinicaQuery
              .where('id_aluno', isEqualTo: _userId)
              .orderBy('data', descending: true);
        } else {
          clinicaQuery = clinicaQuery.orderBy('data', descending: true);
        }

        final clinicaSnapshot = await clinicaQuery
            .startAfterDocument(_lastClinicaDoc!)
            .limit(_limit)
            .get();

        _processQuerySnapshot(clinicaSnapshot, 'clinica');
        _lastClinicaDoc =
            clinicaSnapshot.docs.isNotEmpty ? clinicaSnapshot.docs.last : null;
      }

      // Verifica se chegou na última página
      setState(() {
        _isLastPage = (_lastAtendimentoDoc == null && _lastClinicaDoc == null);
      });
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void _processQuerySnapshot(QuerySnapshot querySnapshot, String origem) {
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _isLastPage = true;
      });
      return;
    }

    List<Map<String, dynamic>> newAtendimentos = querySnapshot.docs.map((doc) {
      Timestamp timestamp = doc['data'] ?? doc['criado_em'] ?? Timestamp.now();
      DateTime data = timestamp.toDate();

      return {
        'id': doc.id,
        'nome': doc['nome'] ?? 'Sem nome',
        'status_atendimento': doc['status_atendimento'] ?? 'Desconhecido',
        'data': data,
        'origem': origem,
      };
    }).toList();

    setState(() {
      _initialLoading = false;
      _atendimentos.addAll(newAtendimentos);
      _atendimentosFiltrados = List.from(_atendimentos);
      _isLastPage = newAtendimentos.length < _limit;
    });
  }

  void _handleError(dynamic e) {
    print("error --> $e");
    ToastUtil.showToast(
      context: context,
      message: 'Erro ao carregar dados: ${e.toString()}',
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
          title: 'Relatórios',
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
              'Ocorreu um erro ao carregar os dados.',
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
                  _lastAtendimentoDoc = null;
                  _lastClinicaDoc = null;
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
      return const Center(child: Text("Nenhum registro encontrado."));
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
            return const SizedBox(height: 100);
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
                    'Erro ao carregar mais registros',
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
