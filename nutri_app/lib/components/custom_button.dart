import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF007AFF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.24),
            offset: const Offset(0, 1),
            blurRadius: 2.5,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.12),
            offset: const Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
