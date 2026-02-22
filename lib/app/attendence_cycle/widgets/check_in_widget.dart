import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contaqa/styles/colors.dart';

import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class CheckInWidget extends StatefulWidget {
  final bool checkIn;

  const CheckInWidget({super.key, required this.checkIn});

  @override
  State<CheckInWidget> createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends State<CheckInWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  bool popCalled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(borderColor: royalBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      log('${result!.code}');
      if (result!.code == 'contaqa_attendence' && popCalled == false) {
        setState(() {
          popCalled = true;
        });

        //* //*
        if (widget.checkIn) {
          Navigator.of(context).pop('scan_completed_in');
        } else {
          Navigator.of(context).pop('scan_completed_out');
        }
      }
    });
  }
}
