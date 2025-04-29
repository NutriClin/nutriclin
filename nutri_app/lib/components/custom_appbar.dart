import 'package:flutter/material.dart';
import 'package:nutri_app/services/preferences_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ScaffoldState? scaffoldState;

  const CustomAppBar({
    super.key,
    required this.title,
    this.scaffoldState,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<String?> _getUserType() async {
    return await PreferencesService.getUserType();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserType(),
      builder: (context, snapshot) {
        final tipoUsuario = snapshot.data;

        return AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFEAEAEA),
          elevation: 0,
          leading: tipoUsuario != null
              ? Builder(
                  builder: (context) => IconButton(
                    icon:
                        const Icon(Icons.menu_sharp, color: Color(0xFF007AFF)),
                    onPressed: () {
                      (scaffoldState ?? Scaffold.of(context)).openDrawer();
                    },
                  ),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.house_rounded, color: Color(0xFF007AFF)),
              onPressed: () => _navigateToHome(context),
            ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 2.5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
