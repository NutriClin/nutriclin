import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = const Color(0xFF007AFF),
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}