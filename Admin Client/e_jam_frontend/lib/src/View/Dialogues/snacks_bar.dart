import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class SnacksBar {
  static void showFailureSnack(
      ScaffoldMessengerState scaffoldMessenger, String message, String title) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.failure,
          ),
          elevation: 0.0,
          dismissDirection: DismissDirection.vertical,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  static void showHelpSnack(
      ScaffoldMessengerState scaffoldMessenger, String message, String title) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.help,
          ),
          elevation: 0.0,
          dismissDirection: DismissDirection.vertical,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  static void showWarningSnack(
      ScaffoldMessengerState scaffoldMessenger, String message, String title) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.warning,
          ),
          elevation: 0.0,
          dismissDirection: DismissDirection.vertical,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  static void showSuccessSnack(
      ScaffoldMessengerState scaffoldMessenger, String message, String title) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.success,
          ),
          elevation: 0.0,
          dismissDirection: DismissDirection.vertical,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 1),
        ),
      );
  }
}
