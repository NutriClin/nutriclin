import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;
  final double labelWidth; // Largura fixa para a label
  final bool enabled;
  final bool obrigatorio;
  final bool error;
  final String? errorMessage;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.labelWidth = 120, // Largura padrão para a label
    this.enabled = true,
    this.obrigatorio = false,
    this.error = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;
    final labelSpacing = screenWidth < 600 ? 10.0 : 15.0;
    final inputHeight = screenWidth < 600 ? 36.0 : 42.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label com largura fixa
              SizedBox(
                width: labelWidth,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: error ? Colors.red : Colors.black,
                          fontSize: fontSize,
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
              SizedBox(width: labelSpacing),
              // Dropdown que ocupa o restante da row
              Expanded(
                child: Container(
                  height: inputHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 600 ? 10 : 15,
                  ),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black54),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: enabled ? Colors.black : Colors.grey,
                        fontSize: fontSize,
                        fontFamily: 'Poppins',
                      ),
                      enableFeedback: enabled,
                      onChanged: enabled ? onChanged : null,
                      items: items
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
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
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth < 600 ? 12 : 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}
