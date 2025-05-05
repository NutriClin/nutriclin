import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/components/custom_list_atendimento.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  _RelatoriosPageState createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLastPage = false;
  DocumentSnapshot? _lastDocument;
  bool _error = false;
  bool _initialLoading = true;
  bool _loadingMore = false;
  final int _limit = 100;
  String? _userType;
  bool _isUserTypeLoaded = false;

  List<Map<String, dynamic>> _atendimentos = [];
  List<Map<String, dynamic>> _atendimentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _fetchUserType().then((_) {
      _fetchInitialData();
    });
    _searchController.addListener(_filtrarAtendimentos);
  }

  Future<void> _fetchUserType() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userType = userDoc.data()?['tipo_usuario'];
            _isUserTypeLoaded = true;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar tipo de usuário: $e");
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      // Query para atendimentos hospitalares
      Query atendimentoQuery = _firestore
          .collection('atendimento')
          .orderBy('nome')
          .limit(_limit);

      // Query para atendimentos clínicos
      Query clinicaQuery = _firestore
          .collection('clinica')
          .orderBy('nome')
          .limit(_limit);

      // Aplicar filtros baseados no tipo de usuário
      if (_userType == 'Professor') {
        atendimentoQuery = atendimentoQuery.where('status_atendimento', isEqualTo: 'enviado');
        clinicaQuery = clinicaQuery.where('status_atendimento', isEqualTo: 'enviado');
      } else if (_userType == 'Aluno') {
        atendimentoQuery = atendimentoQuery.where('status_atendimento', isEqualTo: 'reprovado');
        clinicaQuery = clinicaQuery.where('status_atendimento', isEqualTo: 'reprovado');
      }

      final atendimentoSnapshot = await atendimentoQuery.get();
      _processQuerySnapshot(atendimentoSnapshot, 'atendimento');

      final clinicaSnapshot = await clinicaQuery.get();
      _processQuerySnapshot(clinicaSnapshot, 'clinica');
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
      Query query = _firestore
          .collection('atendimento')
          .orderBy('nome')
          .limit(_limit);

      // Aplicar filtros para paginação
      if (_userType == 'Professor') {
        query = query.where('status_atendimento', isEqualTo: 'enviado');
      } else if (_userType == 'Aluno') {
        query = query.where('status_atendimento', isEqualTo: 'reprovado');
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();
      _processQuerySnapshot(querySnapshot, 'atendimento');

      // Repetir para clínica
      Query clinicaQuery = _firestore
          .collection('clinica')
          .orderBy('nome')
          .limit(_limit);

      if (_userType == 'Professor') {
        clinicaQuery = clinicaQuery.where('status_atendimento', isEqualTo: 'enviado');
      } else if (_userType == 'Aluno') {
        clinicaQuery = clinicaQuery.where('status_atendimento', isEqualTo: 'reprovado');
      }

      final clinicaSnapshot = await clinicaQuery.get();
      _processQuerySnapshot(clinicaSnapshot, 'clinica');
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
      Timestamp timestamp = doc['criado_em'] ?? Timestamp.now();
      DateTime data = timestamp.toDate();

      return {
        'id': doc.id,
        'nome': doc['nome'],
        'status_atendimento': doc['status_atendimento'],
        'data': data,
        'origem': origem,
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
          title: 'Relatórios',
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomInputSearch(controller: _searchController),
                const SizedBox(height: 10),
                if (_userType != null) ...[
                  Text(
                    'Visualizando: ${_getFilterDescription()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Expanded(
                  child: _buildAtendimentoList(),
                ),
              ],
            ),
          ),
        ),
        if (_initialLoading || !_isUserTypeLoaded)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (_initialLoading || !_isUserTypeLoaded)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }

  String _getFilterDescription() {
    if (_userType == 'Professor') {
      return 'Apenas relatórios enviados para correção';
    } else if (_userType == 'Aluno') {
      return 'Apenas relatórios reprovados para revisão';
    }
    return 'Todos os relatórios';
  }

  Widget _buildAtendimentoList() {
    if (_initialLoading || !_isUserTypeLoaded) {
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              _userType == 'Professor'
                  ? 'Nenhum relatório enviado para correção'
                  : _userType == 'Aluno'
                      ? 'Nenhum relatório reprovado para revisão'
                      : 'Nenhum relatório encontrado',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
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