import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para TextInputFormatter

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final double width;
  final bool enabled;
  final bool error;
  final String? errorMessage;
  final Function(String)? onChanged;
  final bool obrigatorio;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;

  const CustomInput({
    super.key,
    required this.label,
    required this.width,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.error = false,
    this.errorMessage,
    this.onChanged,
    this.obrigatorio = false,
    this.inputFormatters,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(
                          color: error ? Colors.red : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (obrigatorio)
                        const TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: enabled ? Colors.white : const Color(0xFFEEE9EF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: error ? Colors.red : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: error
                            ? Colors.red.withOpacity(0.2)
                            : Colors.black.withOpacity(0.15),
                        blurRadius: 2.5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlignVertical: TextAlignVertical.center,
                    obscureText: obscureText,
                    enabled: enabled,
                    onChanged: onChanged,
                    inputFormatters: inputFormatters,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}
