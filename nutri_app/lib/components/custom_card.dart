import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  const CustomCard({
    Key? key,
    required this.child,
    required this.width,
    this.padding = const EdgeInsets.all(5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 2.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
