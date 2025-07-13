import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showNoInternetDialog(VoidCallback onRetry, context) {
  Get.dialog(
    AlertDialog(
      title: Text(
        'İnternet Yok',
        style: TextStyle(
          fontSize: 30,
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            onRetry();
          },
          child: Text(
            'Tekrar Dene',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
