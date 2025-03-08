import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
      leading: IconButton(
        icon: const Icon(Icons.menu_sharp, color: Color(0xFF007AFF)),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_rounded, color: Color(0xFF007AFF)),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 0.5),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 0),
              blurRadius:
                  15,
              spreadRadius: -5,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
