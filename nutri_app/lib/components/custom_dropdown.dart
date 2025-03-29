import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;
  final double width;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.width,
    this.enabled = true,
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: enabled ? Colors.white : const Color(0xFFEEE9EF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 2.5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset.zero,
                    blurRadius: 0.5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.black,
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
    );
  }
}
