import 'package:flutter/material.dart';

class UnClosableOkDialog extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double progress;
  final String speed;
  final bool isDownloading;

  const UnClosableOkDialog({
    super.key,
    required this.text,
    required this.onPressed,
    this.progress = 0.0,
    this.speed = '',
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, 
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDownloading ? Icons.download : Icons.system_update,
                size: 60,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                isDownloading ? 'Downloading Update...' : text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
