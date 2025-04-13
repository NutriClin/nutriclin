// utils/toast_util.dart
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtil {
  static void showToast({
    required BuildContext context,
    required String message,
    bool isError = true,
    int durationSeconds = 3,
  }) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: Duration(seconds: durationSeconds),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: Icon(isError ? Icons.error : Icons.check_circle),
      primaryColor: isError ? Colors.red : Colors.green,
      backgroundColor: isError ? Colors.red[50] : Colors.green[50],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: false,
      dragToClose: true,
    );
  }
}

extension ToastExtension on BuildContext {
  void showToast(String message, {bool isError = true}) {
    ToastUtil.showToast(
      context: this,
      message: message,
      isError: isError,
    );
  }
}
