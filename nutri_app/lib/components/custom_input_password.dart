import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputPassword extends StatefulWidget {
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

  const CustomInputPassword({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = true,
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
  _CustomInputPasswordState createState() => _CustomInputPasswordState();
}

class _CustomInputPasswordState extends State<CustomInputPassword> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inputHeight = widget.height ?? (screenWidth < 600 ? 36.0 : 42.0);
        final fontSize = screenWidth < 600 ? 14.0 : 16.0;
        final labelFontSize = screenWidth < 600 ? 14.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label acima do input
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
                      style: TextStyle(
                        color: widget.error ? Colors.red : Colors.black,
                        fontSize: labelFontSize,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.obrigatorio)
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
            // Campo de texto
            Container(
              height: inputHeight,
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : const Color(0xFFEEE9EF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.error ? Colors.red : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.error
                        ? Colors.red.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: 2.5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textAlignVertical: TextAlignVertical.center,
                obscureText: widget.obscureText && !_isPasswordVisible,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                inputFormatters: widget.inputFormatters,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 600 ? 12 : 16,
                    vertical: screenWidth < 600 ? 14 : 16,
                  ),
                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (widget.error && widget.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.errorMessage!,
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
