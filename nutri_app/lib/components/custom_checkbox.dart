import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final String trueLabel;
  final String falseLabel;
  final Color activeColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trueLabel = 'Sim',
    this.falseLabel = 'Não',
    this.activeColor = const Color(0xFF007AFF),
    this.labelStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
      color: Colors.black,
    );

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: labelStyle ?? textStyle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: value == true,
                onChanged: (v) => onChanged(v == true ? true : null),
                activeColor: activeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(trueLabel, style: textStyle),
            ],
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: value == false,
                onChanged: (v) => onChanged(v == true ? false : null),
                activeColor: activeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(falseLabel, style: textStyle),
            ],
          ),
        ],
      ),
    );
  }
}
