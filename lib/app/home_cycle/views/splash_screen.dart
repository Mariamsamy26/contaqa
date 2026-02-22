import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final serviceProviderRead = context.read<WebViewProvider>();

      subscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> result,
      ) async {
        bool isConnected =
            await InternetConnectionChecker.createInstance().hasConnection;

        log('Connection >> $isConnected');

        serviceProviderRead.setIsConnected = isConnected;
      });
    });

    Future.delayed(const Duration(milliseconds: 2500), () async {
      //Navigation().goToScreenAndClearAll(context, (context) => const HomeScreen());
      Navigation().goToScreenAndClearAll(
        context,
        (context) => const PickAppTypeScreen(),
      );

      if (context.read<WebViewProvider>().isConnected) {
        final pref = await SharedPreferences.getInstance();

        int? employeeId = pref.getInt('employee_id');
        if (employeeId != null) {
          Navigation().goToScreenAndClearAll(
            context,
            (context) => const PickAppTypeScreen(),
          );
        } else {
          Navigation().goToScreenAndClearAll(
            context,
            (context) => const LoginScreen(),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) =>
              const OkDialog(text: 'Please Check your Connection!'),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);
    return Scaffold(
      backgroundColor: white,
      body: SizedBox(
        height: AppDimentions().availableheightWithAppBar,
        width: AppDimentions().availableWidth,
        child: Center(child: Image.asset('assets/images/Contaqa_logo.png')),
      ),
    );
  }
}
