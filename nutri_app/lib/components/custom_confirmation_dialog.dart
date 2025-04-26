import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_button.dart';
import 'package:nutri_app/components/custom_card.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final Color cancelColor;
  final Function() onConfirm;
  final Function()? onCancel;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.confirmColor = const Color(0xFF007AFF),
    this.cancelColor = Colors.red,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
      ),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          CustomCard(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: cancelText,
                        onPressed: () {
                          if (onCancel != null) {
                            onCancel!();
                          }
                          Navigator.pop(context);
                        },
                        color: Colors.white,
                        textColor: cancelColor,
                        boxShadowColor: Colors.black,
                      ),
                      CustomButton(
                        text: confirmText,
                        onPressed: () {
                          onConfirm();
                          Navigator.pop(context);
                        },
                        color: confirmColor,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
