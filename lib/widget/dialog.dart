import 'package:flutter/material.dart';
import 'package:contaqa/widget/ok_dialog.dart';

void showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => OkDialog(text: message),
  );
}

void showSuccessDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => OkDialog(text: message),
  );
}
