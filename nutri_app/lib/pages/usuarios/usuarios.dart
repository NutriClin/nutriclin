import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_app/components/base_page.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'package:nutri_app/components/custom_list_usuario.dart';
import 'package:nutri_app/components/toast_util.dart';
import 'package:nutri_app/pages/usuarios/usuario_detalhe.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLastPage = false;
  DocumentSnapshot? _lastDocument;
  bool _error = false;
  bool _initialLoading = true;
  bool _loadingMore = false;
  final int _limit = 100;
  String _filtroAtivo = 'todos'; // 'todos' ou 'ativos'

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _usuariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_filtrarUsuarios);
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
          .collection('usuarios')
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
          .collection('usuarios')
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

    List<Map<String, dynamic>> newUsers = querySnapshot.docs.map((doc) {
      Timestamp timestamp = doc['data'] ?? Timestamp.now();
      DateTime data = timestamp.toDate();

      return {
        'id': doc.id,
        'nome': doc['nome'],
        'email': doc['email'],
        'tipo_usuario': doc['tipo_usuario'],
        'ativo': doc['ativo'] ?? true,
        'data': data,
      };
    }).toList();

    setState(() {
      _initialLoading = false;
      _lastDocument = querySnapshot.docs.last;
      _usuarios.addAll(newUsers);
      _usuariosFiltrados = List.from(_usuarios);
      _isLastPage = newUsers.length < _limit;
    });
  }

  void _handleError(dynamic e) {
    print("error --> $e");
    ToastUtil.showToast(
      context: context,
      message: 'Erro ao carregar usuários: ${e.toString()}',
      isError: true,
    );
    setState(() {
      _initialLoading = false;
      _error = true;
      _loadingMore = false;
    });
  }

  void _filtrarUsuarios() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        final nomeMatch = usuario["nome"].toLowerCase().contains(query);
        final ativoMatch = _filtroAtivo == 'todos' || usuario["ativo"] == true;
        return nomeMatch && ativoMatch;
      }).toList();
    });
  }

  Widget _buildFiltroAtivo() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filtroAtivo,
          items: const [
            DropdownMenuItem(
              value: 'todos',
              child: Text('Todos'),
            ),
            DropdownMenuItem(
              value: 'ativos',
              child: Text('Ativos'),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _filtroAtivo = value;
                _filtrarUsuarios();
              });
            }
          },
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BasePage(
          title: 'Usuários',
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child:
                            CustomInputSearch(controller: _searchController)),
                    _buildFiltroAtivo(),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildUsersList(),
                ),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsuarioDetalhe(idUsuario: ""),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
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

  Widget _buildUsersList() {
    if (_initialLoading) {
      return const SizedBox();
    }

    if (_error && _usuarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ocorreu um erro ao carregar os usuários.',
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
                  _usuarios.clear();
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

    if (_usuariosFiltrados.isEmpty) {
      return const Center(child: Text("Nenhum usuário encontrado."));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _usuariosFiltrados.length + 1,
      itemBuilder: (context, index) {
        if (index < _usuariosFiltrados.length) {
          final usuario = _usuariosFiltrados[index];
          return CustomListUsuario(report: usuario);
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
                  Text(
                    'Erro ao carregar mais usuários',
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
