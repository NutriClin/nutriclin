import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final Color boxShadowColor;
  final bool isLoading;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF007AFF),
    this.textColor = Colors.white,
    this.boxShadowColor = const Color(0xFF007AFF),
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color:
              enabled ? (isLoading ? const Color(0xFFEEE9EF) : color) : color,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor.withOpacity(0.24),
              offset: const Offset(0, 1),
              blurRadius: 2.5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: enabled ? (!isLoading ? onPressed : null) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Poppins',
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
