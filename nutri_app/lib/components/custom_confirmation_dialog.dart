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
    this.confirmColor = Colors.blue,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 15),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
