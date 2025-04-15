import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBox extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onTap;
  final double labelFontSize;
  final double cardWidth;

  const CustomBox({
    super.key,
    required this.text,
    required this.imagePath,
    required this.onTap,
    this.labelFontSize = 14,
    this.cardWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - this.cardWidth) / 3;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(1),
        highlightColor: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: cardWidth,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 2.5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    imagePath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
