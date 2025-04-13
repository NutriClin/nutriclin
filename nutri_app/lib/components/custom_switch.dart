import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool obrigatorio;
  final double? height;

  const CustomSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.obrigatorio = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inputHeight = height ?? (screenWidth < 600 ? 36.0 : 42.0);
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
                        color: Colors.black,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Switch(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    activeColor: const Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
