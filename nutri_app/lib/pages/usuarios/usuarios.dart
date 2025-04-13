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
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];
  bool isLoading = false; // Adicionado estado para o loader

  @override
  void initState() {
    super.initState();
    _buscarUsuarios();
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarUsuarios);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscarUsuarios() async {
    setState(() => isLoading = true);

    try {
      FirebaseFirestore.instance
          .collection('usuarios')
          .snapshots()
          .listen((snapshot) {
        List<Map<String, dynamic>> listaUsuarios = snapshot.docs.map((doc) {
          Timestamp timestamp = doc['data'];
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
          usuarios = listaUsuarios;
          usuariosFiltrados = List.from(usuarios);
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() => isLoading = false);
      ToastUtil.showToast(
        context: context,
        message: 'Erro ao carregar usuários: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _filtrarUsuarios() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      usuariosFiltrados = usuarios.where((usuario) {
        return usuario["nome"].toLowerCase().contains(query);
      }).toList();
    });
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
                CustomInputSearch(controller: _searchController),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const SizedBox()
                      : usuariosFiltrados.isEmpty
                          ? const Center(
                              child: Text("Nenhum usuário encontrado."))
                          : ListView.builder(
                              itemCount: usuariosFiltrados.length,
                              itemBuilder: (context, index) {
                                var usuario = usuariosFiltrados[index];
                                return CustomListUsuario(report: usuario);
                              },
                            ),
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
        if (isLoading)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
