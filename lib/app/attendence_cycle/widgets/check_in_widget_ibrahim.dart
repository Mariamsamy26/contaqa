import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInWidgetIbr extends StatefulWidget {
  final bool checkIn;

  const CheckInWidgetIbr({super.key, required this.checkIn});

  @override
  State<CheckInWidgetIbr> createState() => _CheckInWidgetIbrState();
}

class _CheckInWidgetIbrState extends State<CheckInWidgetIbr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? _barcode;

  bool popCalled = false;

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;

        print('${_barcode!.displayValue}');
      });

      log('${_barcode!.displayValue}');
      if (_barcode!.displayValue == 'contaqa_attendence' &&
          popCalled == false) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: MobileScanner(onDetect: _handleBarcode)),
        ],
      ),
    );
  }
}
