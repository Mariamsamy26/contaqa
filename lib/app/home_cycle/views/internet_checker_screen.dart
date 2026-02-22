import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:contaqa/app/home_cycle/providers/webview_provider.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../../../helpers/application_dimentions.dart';

class InternetCheckerScreen extends StatelessWidget {
  const InternetCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProviderWatch = context.watch<WebViewProvider>();

    AppDimentions().appDimentionsInit(context);

    return Container(
      height: AppDimentions().availableheightWithAppBar,
      width: AppDimentions().availableWidth,
      color: backGroundLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              serviceProviderWatch.isConnected ? Icons.wifi : Icons.signal_wifi_off,
              size: 100,
              color: serviceProviderWatch.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              serviceProviderWatch.isConnected ? "You're online!" : "No internet connection",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: serviceProviderWatch.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
