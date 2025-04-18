import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool error;
  final String? errorMessage;
  final Function(String)? onChanged;
  final bool obrigatorio;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final double? height;

  const CustomInput({
    super.key,
    required this.label,
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
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inputHeight = height ?? (screenWidth < 600 ? 36.0 : 42.0);
        final fontSize = screenWidth < 600 ? 14.0 : 16.0;
        final labelFontSize = screenWidth < 600 ? 14.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: error ? Colors.red : Colors.black,
                        fontSize: labelFontSize,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (obrigatorio)
                      const TextSpan(
                        text: ' *',
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
            Container(
              height: inputHeight,
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
              child: Center(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textAlignVertical: TextAlignVertical.center,
                  obscureText: obscureText,
                  enabled: enabled,
                  onChanged: onChanged,
                  inputFormatters: inputFormatters,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 600 ? 12 : 16,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ),
            if (error && errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
