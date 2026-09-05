import 'package:flutter/material.dart';
import 'app_dialog.dart';

// Thin wrapper kept for backward compatibility — delegates to AppSnackBar.
class ToastHelper {
  static void showToast(String message, {bool isSuccess = true, BuildContext? context}) {
    if (context != null) {
      AppSnackBar.show(context, message, isSuccess: isSuccess);
    }
  }
}
