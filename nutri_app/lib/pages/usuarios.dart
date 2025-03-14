import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'package:nutri_app/components/custom_list_usuario.dart';
import 'package:nutri_app/pages/usuario_detalhe.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final TextEditingController _searchController = TextEditingController();

  // Lista de relatórios simulada
  final List<Map<String, dynamic>> allReports = [
    {
      "nome": "Bryan Mernick",
      "data": DateTime(2025, 2, 11, 9, 0),
      "status": "Ativo",
    },
    {
      "nome": "Giovane Galvão",
      "data": DateTime(2025, 2, 10, 13, 42),
      "status": "Desativado",
    },
    {
      "nome": "Isabelle Cordova Gomez",
      "data": DateTime(2025, 2, 10, 11, 0),
      "status": "Ativo",
    },
  ];

  List<Map<String, dynamic>> filteredReports = [];

  @override
  void initState() {
    super.initState();
    filteredReports = List.from(allReports);
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReports);
    _searchController.dispose();
    super.dispose();
  }

  void _filterReports() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredReports = allReports.where((report) {
        return report["nome"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ordenando a lista: mais novo por último
    filteredReports.sort((a, b) {
      return a['data'].compareTo(b['data']);
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Usuários'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CustomInputSearch(
              controller: _searchController,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  return CustomListUsuario(report: filteredReports[index]);
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
                  builder: (context) => UsuarioDetalhe(idUsuario: 123,),
                ),
              );
            },
            backgroundColor: const Color(0xFF007AFF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
