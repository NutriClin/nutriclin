import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;
  final double width;
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
    required this.width,
    this.enabled = true,
    this.obrigatorio = false,
    this.error = false,
    this.errorMessage,
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
                          fontWeight: FontWeight.w500,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      enableFeedback: enabled,
                      onChanged: enabled ? onChanged : null,
                      items: items
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
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
