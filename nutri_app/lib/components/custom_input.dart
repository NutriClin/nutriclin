import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final double width;

  const CustomInput({
    super.key,
    required this.label,
    required this.width,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  // Primeira sombra conforme a imagem, corrigida para baixo
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 30% de opacidade
                    offset: const Offset(0,
                        2), // Aumentado para Y: 2 para mover a sombra mais para baixo
                    blurRadius: 2.5, // Blur de 2.5
                    spreadRadius: 0, // Sem spread
                  ),
                  // Segunda sombra adicional conforme solicitado
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 5% de opacidade
                    offset: Offset.zero, // Sem deslocamento
                    blurRadius: 0.5, // Sem blur
                    spreadRadius: 0.5, // Spread de 0.5
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textAlignVertical: TextAlignVertical.bottom,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
