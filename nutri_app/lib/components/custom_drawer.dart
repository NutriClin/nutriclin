// Widget para o Drawer personalizado
import 'package:flutter/material.dart';
import 'package:nutri_app/services/preferences_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<String?> _getUserType() async {
    return await PreferencesService.getUserType();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserType(),
      builder: (context, snapshot) {
        final tipoUsuario = snapshot.data;
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._buildMenuItems(context, tipoUsuario),
            ],
          ),
        );
      },
    );
  }
}

// Método para construir os itens do menu baseado no tipo de usuário
List<Widget> _buildMenuItems(BuildContext context, String? tipoUsuario) {
  List<Widget> items = [];

  // Itens comuns a todos os usuários
  items.addAll([
    ListTile(
      leading: const Icon(Icons.calculate, color: Color(0xFF007AFF)),
      title: const Text('Cálculos'),
      onTap: () {
        Navigator.pop(context);
        // Navegar para tela de cálculos
      },
    ),
  ]);

  // Itens específicos por tipo de usuário
  if (tipoUsuario == 'Coordenador') {
    items.addAll([
      ListTile(
        leading: const Icon(Icons.people, color: Color(0xFF007AFF)),
        title: const Text('Usuários'),
        onTap: () {
          Navigator.pop(context);
          // Navegar para tela de usuários
        },
      ),
      ListTile(
        leading: const Icon(Icons.assessment, color: Color(0xFF007AFF)),
        title: const Text('Relatórios'),
        onTap: () {
          Navigator.pop(context);
          // Navegar para tela de relatórios
        },
      ),
    ]);
  } else if (tipoUsuario == 'Aluno') {
    items.addAll([
      ListTile(
        leading: const Icon(Icons.medical_services, color: Color(0xFF007AFF)),
        title: const Text('Atendimento'),
        onTap: () {
          Navigator.pop(context);
          // Navegar para tela de atendimento
        },
      ),
    ]);
  }

  // Item de logout (comum a todos)
  items.add(const Divider());
  items.add(
    ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.red),
      title: const Text('Sair', style: TextStyle(color: Colors.red)),
      onTap: () {
        // Implementar logout
        PreferencesService.clearUserType();
        Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  );

  return items;
}
