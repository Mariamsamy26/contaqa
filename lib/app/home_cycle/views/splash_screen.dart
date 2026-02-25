import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/app/attendence_cycle/views/login_screen.dart';
import 'package:contaqa/app/home_cycle/providers/webview_provider.dart';
import 'package:contaqa/app/home_cycle/views/pick_app_type_screen.dart';
import 'package:contaqa/widget/ok_dialog.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/application_dimentions.dart';
import '../../../helpers/navigation_helper.dart';
import '../../../styles/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  /// -------------------------------
  /// Main logic
  /// -------------------------------
  Future<void> _startApp() async {
    /// splash delay
    await Future.delayed(const Duration(milliseconds: 2500));

    final webProvider = context.read<WebViewProvider>();

    /// internet checker
    final checker = InternetConnectionChecker.createInstance(
      addresses: [
        AddressCheckOption(uri: Uri.parse('https://www.google.com')),
        AddressCheckOption(uri: Uri.parse('https://www.bing.com')),
        AddressCheckOption(uri: Uri.parse('https://www.amazon.com')),
      ],
    );

    bool hasConnection = await checker.hasConnection;

    log('Connection >> $hasConnection');

    /// save inside provider
    webProvider.setIsConnected = hasConnection;

    /// -------------------------------
    /// no internet
    /// -------------------------------
    if (!hasConnection) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => const OkDialog(text: 'Please Check your Connection!'),
      );

      return;
    }

    /// -------------------------------
    /// check login
    /// -------------------------------
    final pref = await SharedPreferences.getInstance();

    int? employeeId = pref.getInt('employee_id');
    String? email = pref.getString('email');
    String? password = pref.getString('password');

    if (!mounted) return;

    if (employeeId != null && email != null && password != null) {
      Navigation().goToScreenAndClearAll(
        context,
        (_) => const PickAppTypeScreen(),
      );
    } else {
      Navigation().goToScreenAndClearAll(context, (_) => const LoginScreen());
    }
  }

  /// -------------------------------
  /// UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);

    return Scaffold(
      backgroundColor: white,
      body: SizedBox(
        height: AppDimentions().availableheightWithAppBar,
        width: AppDimentions().availableWidth,
        child: Center(
          child: Image.asset(
            'assets/images/Contaqa_logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
