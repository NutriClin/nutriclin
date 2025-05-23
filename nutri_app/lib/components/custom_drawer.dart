import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/calculos/calculos.dart';
import 'package:nutri_app/pages/relatorios/relatorios.dart';
import 'package:nutri_app/pages/usuarios/usuarios.dart';
import 'package:nutri_app/services/preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: DrawerHeader(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/imagens/campologo.svg',
                      height: 60,
                      semanticsLabel: 'Logo Campo',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ..._buildMenuItems(context, tipoUsuario),
                  ],
                ),
              ),
              _buildLogoutItem(context),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // Widget do logout separado
  Widget _buildLogoutItem(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAppVersion(),
      builder: (context, snapshot) {
        final version = snapshot.data ?? '0.1.0';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Sair',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  PreferencesService.clearUserType();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Versão $version',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<Widget> _buildMenuItems(BuildContext context, String? tipoUsuario) {
  List<Widget> items = [];

  items.add(const SizedBox(height: 15));

  items.add(
    ListTile(
      leading: const Icon(Icons.calculate, color: Color(0xFF007AFF)),
      title: const Text('Cálculos'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalculosPage(),
          ),
        );
      },
    ),
  );

  if (tipoUsuario == 'Coordenador') {
    items.addAll([
      ListTile(
        leading: const Icon(Icons.people, color: Color(0xFF007AFF)),
        title: const Text('Usuários'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UsuarioPage(),
            ),
          );
        },
      ),
    ]);
  } else if (tipoUsuario == 'Aluno') {
    items.add(
      ListTile(
        leading: const Icon(Icons.medical_services, color: Color(0xFF007AFF)),
        title: const Text('Atendimento'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AtendimentoPage(),
            ),
          );
        },
      ),
    );
    items.add(
      ListTile(
        leading: const Icon(Icons.insert_drive_file_rounded,
            color: Color(0xFF007AFF)),
        title: const Text('Relatórios'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RelatoriosPage(),
            ),
          );
        },
      ),
    );
  } else if (tipoUsuario == 'Professor') {
    items.add(
      ListTile(
        leading: const Icon(Icons.insert_drive_file_rounded,
            color: Color(0xFF007AFF)),
        title: const Text('Relatórios'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RelatoriosPage(),
            ),
          );
        },
      ),
    );
  }

  return items;
}
