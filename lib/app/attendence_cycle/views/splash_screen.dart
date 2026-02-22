// import 'dart:async';
// import 'dart:developer';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:contaqa/app/attendence_cycle/views/home_screen.dart';
// import 'package:contaqa/app/attendence_cycle/views/login_screen.dart';
// import 'package:contaqa/helpers/application_dimentions.dart';
// import 'package:contaqa/helpers/navigation_helper.dart';
// import 'package:contaqa/styles/colors.dart';
// import 'package:contaqa/widget/ok_dialog.dart';

// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   StreamSubscription<List<ConnectivityResult>>? subscription;

//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
//         bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;

//         log('Connection >> $isConnected');

//         // print(MediaQuery.sizeOf(context).height);
//         // print(MediaQuery.sizeOf(context).width);

//         if (isConnected) {
//           Future.delayed(const Duration(milliseconds: 1500), () async {
//             final pref = await SharedPreferences.getInstance();

//             int? employeeId = pref.getInt('employee_id');
//             if (employeeId != null) {
//               Navigation().goToScreenAndClearAll(context, (context) => HomeScreen(employeeId: employeeId));
//             } else {
//               Navigation().goToScreenAndClearAll(context, (context) => const LoginScreen());
//             }
//           });
//         } else {
//           showDialog(context: context, builder: (context) => const OkDialog(text: 'Please Check your Internet Connection!'));
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     AppDimentions().appDimentionsInit(context);
//     return Scaffold(
//       backgroundColor: white,
//       body: SizedBox(
//         height: AppDimentions().availableheightWithAppBar,
//         width: AppDimentions().availableWidth,
//         child: Center(child: Image.asset('assets/images/Contaqa_logo.png', height: 300.h, width: 300.w, fit: BoxFit.cover)),
//       ),
//     );
//   }
// }
