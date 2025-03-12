import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_input_search.dart';
import 'components/custom_appbar.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final TextEditingController _searchController = TextEditingController();

  // Lista de relatórios simulada
  final List<Map<String, dynamic>> reports = [
    {
      "name": "Bryan Mernick",
      "date": "Feb 11, 2025 as 9:00 Hrs",
      "status": "Pendente",
      "statusColor": Colors.red,
      "isPriority": true
    },
    {
      "name": "Giovane Galvão",
      "date": "Feb 10, 2025 as 13:42 Hrs",
      "status": "Entregue",
      "statusColor": Colors.green,
      "isPriority": false
    },
    {
      "name": "Isabelle Cordova Gom...",
      "date": "Feb 10, 2025 as 11:00 Hrs",
      "status": "Entregue",
      "statusColor": Colors.green,
      "isPriority": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Usuários'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          CustomInputSearch(
            width: 50,
            controller: _searchController,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return ReportItem(report: reports[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Componente para os itens da lista de relatórios
class ReportItem extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: report["isPriority"]
              ? const Icon(Icons.arrow_upward, color: Colors.blue)
              : null,
          title: Text(
            report["name"],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            report["date"],
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            report["status"],
            style: TextStyle(
              color: report["statusColor"],
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {}, // Ação ao clicar no item
        ),
        const Divider(indent: 20, endIndent: 20, height: 1),
      ],
    );
  }
}
