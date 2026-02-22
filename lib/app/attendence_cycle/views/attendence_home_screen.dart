import 'dart:async';
import 'dart:io';

import 'package:contaqa/app/attendence_cycle/views/login_screen.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:contaqa/app/attendence_cycle/models/monthly_attendence.dart';
import 'package:contaqa/app/attendence_cycle/services/attendence_apis.dart';
import 'package:contaqa/app/attendence_cycle/views/time_sheet_screen.dart';
import 'package:contaqa/app/attendence_cycle/widgets/check_in_widget.dart';
import 'package:contaqa/app/attendence_cycle/widgets/check_in_widget_ibrahim.dart';
import 'package:contaqa/app/home_cycle/views/pick_app_type_screen.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/styles/colors%20copy.dart';
import 'package:contaqa/styles/text_style.dart';
import 'package:contaqa/widget/ok_dialog.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//* CURRENT LATLNG >> 29.973335 , 31.287904
import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

//* CURRENT LATLNG >> 29.973335 , 31.287904

class AttendenceHome extends StatefulWidget {
  final int employeeId;

  const AttendenceHome({super.key, required this.employeeId});

  @override
  State<AttendenceHome> createState() => _AttendenceHomeState();
}

class _AttendenceHomeState extends State<AttendenceHome> {
  bool checkInCompleted = false;
  bool checkOutCompleted = false;

  DateTime serverTime = DateTime.now();
  String serverTimeForAPI = '';

  String deviceType = '';

  bool dataLoaded = false;

  String finalDistance = '';
  bool validDistance = false;

  Future onGoBack(dynamic value) async {
    final pref = await SharedPreferences.getInstance();
    print('ON GO BACK >> $value');

    if (value == 'scan_completed_in') {
      //*
      Navigation().showLoadingGifDialog(context);

      await initData();
      var check = await AttendenceApis().checkIn(
        widget.employeeId,
        serverTimeForAPI,
        deviceType,
      );

      Navigation().closeDialog(context);
      //*
      if (check!.status == 1) {
        checkInCompleted = true;

        showDialog(
          context: context,
          builder: (context) => OkDialog(text: 'check_in_is_completed'),
        );
      } else {
        checkInCompleted = false;

        showDialog(
          context: context,
          builder: (context) => OkDialog(text: check.message!),
        );
      }

      setState(() {});
    } else if (value == 'scan_completed_out') {
      Navigation().showLoadingGifDialog(context);

      await initData();
      var check = await AttendenceApis().checkOut(
        widget.employeeId,
        serverTimeForAPI,
        deviceType,
      );

      Navigation().closeDialog(context);

      if (check!.status == 1) {
        checkOutCompleted = true;

        showDialog(
          context: context,
          builder: (context) => const OkDialog(text: 'Check OUT is Completed'),
        );
      } else {
        checkOutCompleted = false;

        showDialog(
          context: context,
          builder: (context) => OkDialog(text: check.message!),
        );
      }

      setState(() {});
    } else {
      //* DO NOTHING
    }
  }

  Future<void> checkIfQrCodeScannedTodayOrNot(DateTime serverTime) async {
    await AttendenceApis()
        .getMonthlyAttendence(
          widget.employeeId,
          serverTime.year,
          serverTime.month,
        )
        .then((attendence) async {
          if (attendence!.status == 1) {
            var todayAttendence = attendence.attendance!.firstWhere(
              (element) =>
                  DateFormat('dd-MM-yyyy').format(element.checkIn!) ==
                  DateFormat('dd-MM-yyyy').format(serverTime),
              orElse: () =>
                  Attendance(checkIn: null, checkOut: null, workedHours: null),
            );

            if (todayAttendence.checkIn == null) {
              checkInCompleted = false;
              checkOutCompleted = false;
            } else if (todayAttendence.checkIn != null &&
                todayAttendence.checkOut == null) {
              checkInCompleted = true;
              checkOutCompleted = false;
            } else if (todayAttendence.checkIn != null &&
                todayAttendence.checkOut != null) {
              checkInCompleted = true;
              checkOutCompleted = true;
            }

            setState(() {});
          }
          //* //* //*
          else {
            await initData();
          }
        });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void getTimeSheet() async {
    Navigation().showLoadingGifDialog(context);
    //* //*
    await AttendenceApis()
        .getMonthlyAttendence(
          widget.employeeId,
          serverTime.year,
          serverTime.month,
        )
        .then((monthlyAttendence) {
          Navigation().closeDialog(context);
          //* //*
          if (monthlyAttendence!.status == 1) {
            Navigation().goToScreen(
              context,
              (context) =>
                  TimeSheetScreen(monthlyAttendence: monthlyAttendence),
            );
          } else {
            getTimeSheet();
          }
        });
  }

  Future<void> initData() async {
    //* //* //* //* GET SERVER TIME
    var dateOfServer = await AttendenceApis().getServerTime();

    List<String> timeParts = dateOfServer!.time!.split(':');

    String hour = timeParts[0];
    String minute = timeParts[1];
    String second = timeParts[2];

    serverTime = dateOfServer.date!.copyWith(
      hour: int.parse(hour),
      minute: int.parse(minute),
      second: int.parse(second),
    );
    // serverTime.

    serverTimeForAPI = DateFormat('yyyy-MM-ddTHH:mm:ss').format(serverTime);

    await checkIfQrCodeScannedTodayOrNot(serverTime);

    print('$serverTime -- $serverTimeForAPI');

    //* //* //* //* GET DEVICE INFO

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      deviceType = androidInfo.model;

      print('Running on ${androidInfo.model}');
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      deviceType = iosInfo.utsname.machine;
      print('Running on ${iosInfo.utsname.machine}');
    }

    dataLoaded = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    AppDimentions().appDimentionsInit(context);
    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.translate('company_attendance')),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.logout),
          //     onPressed: () async {
          //       final pref = await SharedPreferences.getInstance();

          //       await pref.clear();

          //       // //*
          //       //*moustafa
          //       // Navigation().goToScreenAndClearAll(context, (context) => const PickAppTypeScreen());
          //       Navigation().goToScreenAndClearAll(
          //         context,
          //         (context) => const LoginScreen(),
          //       );
          //     },
          //   ),
          // ],
          leading: IconButton(
            onPressed: () => Navigation().closeDialog(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: royalBlue,
          ),
        ),
        body: Container(
          height: AppDimentions().availableheightWithAppBar,
          width: AppDimentions().availableWidth,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            //  gradient: LinearGradient(colors: [royalBlue, electricBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: dataLoaded
              ? Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy\nhh:mm a').format(serverTime),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaSans(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    //* //*
                    GestureDetector(
                      onTap: validDistance
                          ? () {
                              if (checkInCompleted) {
                                //* DO NOTHING
                              } else {
                                // TODO NORMAL
                                Navigation().goToScreenWithGoBack(
                                  context,
                                  (context) =>
                                      const CheckInWidget(checkIn: true),
                                  onGoBack,
                                );

                                //* //*

                                // TODO IBRAHIM

                                // Navigation()
                                //     .goToScreenWithGoBack(context, (context) => const CheckInWidgetIbr(checkIn: true), onGoBack);
                              }
                            }
                          : null,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(
                            color: validDistance ? white : Colors.grey,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset(
                                'assets/images/check-in.png',
                                height: 75.h,
                                width: 75.w,
                              ),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('check_in'),
                                style: GoogleFonts.firaSans(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                              const Spacer(),
                              //Icon(Icons.arrow_forward_ios, size: 30, color: royalBlue),
                              checkInCompleted
                                  ? Image.asset(
                                      'assets/images/checked.png',
                                      height: 40.h,
                                      width: 30.w,
                                    )
                                  : Image.asset(
                                      'assets/images/cross.png',
                                      height: 40.h,
                                      width: 30.w,
                                    ),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // //* //*
                    GestureDetector(
                      onTap: validDistance
                          ? () {
                              if (checkOutCompleted) {
                                //* DO NOTHING
                              } else {
                                // TODO NORMAL
                                Navigation().goToScreenWithGoBack(
                                  context,
                                  (context) =>
                                      const CheckInWidget(checkIn: false),
                                  onGoBack,
                                );

                                // TODO IBRAHIM
                                // Navigation()
                                //     .goToScreenWithGoBack(context, (context) => const CheckInWidgetIbr(checkIn: false), onGoBack);
                              }
                            }
                          : null,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(
                            color: validDistance ? white : Colors.grey,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset(
                                'assets/images/check-out.png',
                                height: 75.h,
                                width: 75.w,
                              ),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('check_out'),
                                style: GoogleFonts.firaSans(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                              const Spacer(),
                              //   Icon(Icons.arrow_forward_ios, size: 30, color: royalBlue),
                              checkOutCompleted
                                  ? Image.asset(
                                      'assets/images/checked.png',
                                      height: 40.h,
                                      width: 30.w,
                                    )
                                  : Image.asset(
                                      'assets/images/cross.png',
                                      height: 40.h,
                                      width: 30.w,
                                    ),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // //* //*
                    GestureDetector(
                      onTap: () async {
                        getTimeSheet();
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset(
                                'assets/images/clipboard.png',
                                height: 75.h,
                                width: 75.w,
                              ),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('view_time_sheet'),
                                style: GoogleFonts.firaSans(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                              const Spacer(),
                              // Icon(Icons.arrow_forward_ios, size: 30, color: royalBlue),
                              // SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //* //* //*
                    const Spacer(),
                    SizedBox(
                      height: 70.h,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            validDistance ? Colors.green : Colors.red,
                          ),
                        ),
                        onPressed: () {
                          getCurrentLocation();
                        },
                        child: Text(
                          '${languageProvider.translate('check_location')} || $finalDistance m',
                          style: mediumText.copyWith(fontSize: 20.sp),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(color: royalBlue),
                ),
        ),
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    //* //*
    double distanceInMeters = Geolocator.distanceBetween(
      locationData.latitude!,
      locationData.longitude!,
      29.973335,
      31.287904,
    );

    finalDistance = distanceInMeters.toStringAsFixed(0);

    if (distanceInMeters <= 50) {
      validDistance = true;
    } else {
      validDistance = false;
    }

    setState(() {});

    print(
      'LAT LNG >> ${locationData.latitude} -- ${locationData.longitude} -- ${locationData.accuracy} -- Distance: $finalDistance M',
    );
  }
}
