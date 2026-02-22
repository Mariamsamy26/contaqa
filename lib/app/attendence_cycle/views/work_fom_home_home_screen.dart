import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:contaqa/app/attendence_cycle/models/monthly_attendence.dart';
import 'package:contaqa/app/attendence_cycle/services/attendence_apis.dart';
import 'package:contaqa/app/attendence_cycle/views/time_sheet_screen.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/widget/ok_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//* CURRENT LATLNG >> 29.973335 , 31.287904

class WorkFromHomeScreen extends StatefulWidget {
  final int employeeId;

  const WorkFromHomeScreen({super.key, required this.employeeId});

  @override
  State<WorkFromHomeScreen> createState() => _WorkFromHomeScreenState();
}

class _WorkFromHomeScreenState extends State<WorkFromHomeScreen> {
  bool checkInCompleted = false;
  bool checkOutCompleted = false;

  DateTime serverTime = DateTime.now();
  String serverTimeForAPI = '';

  bool dataLoaded = false;

  String finalDistance = '';

  Future onGoBack(dynamic value) async {
    print('ON GO BACK >> $value');

    if (value == 'scan_completed_in') {
      //*
      Navigation().showLoadingGifDialog(context);

      await initData();
      var check = await AttendenceApis().checkIn(widget.employeeId, serverTimeForAPI, "work from home");
      //*work off home

      Navigation().closeDialog(context);
      //*
      if (check!.status == 1) {
        checkInCompleted = true;

        showDialog(
          context: context,
          builder: (context) => const OkDialog(text: 'Check IN is Completed'),
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
      var check = await AttendenceApis().checkOut(widget.employeeId, serverTimeForAPI, "work from home");

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
    await AttendenceApis().getFromHomeAttendence(widget.employeeId, serverTime.year, serverTime.month).then((attendence) async {
      if (attendence!.status == 1) {
        var todayAttendence = attendence.attendance!.firstWhere(
          (element) => DateFormat('dd-MM-yyyy').format(element.checkIn!) == DateFormat('dd-MM-yyyy').format(serverTime),
          orElse: () => Attendance(checkIn: null, checkOut: null, workedHours: null),
        );

        if (todayAttendence.checkIn == null) {
          checkInCompleted = false;
          checkOutCompleted = false;
        } else if (todayAttendence.checkIn != null && todayAttendence.checkOut == null) {
          checkInCompleted = true;
          checkOutCompleted = false;
        } else if (todayAttendence.checkIn != null && todayAttendence.checkOut != null) {
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
    print('getTimeSheet called');
    Navigation().showLoadingGifDialog(context);
    //* //*
    await AttendenceApis().getFromHomeAttendence(widget.employeeId, serverTime.year, serverTime.month).then((monthlyAttendence) {
      Navigation().closeDialog(context);
      //* //*
      if (monthlyAttendence!.status == 1) {
        Navigation().goToScreen(context, (context) => TimeSheetScreen(monthlyAttendence: monthlyAttendence));
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

    serverTime = dateOfServer.date!.copyWith(hour: int.parse(hour), minute: int.parse(minute), second: int.parse(second));
    // serverTime.

    serverTimeForAPI = DateFormat('yyyy-MM-ddTHH:mm:ss').format(serverTime);

    await checkIfQrCodeScannedTodayOrNot(serverTime);

    print('$serverTime -- $serverTimeForAPI');

    //* //* //* //* GET DEVICE INFO

    dataLoaded = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);

    final languageProvider = context.watch<LanguageProvider>();
    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.translate('from_home_attendance')),

          leading: IconButton(
            onPressed: () => Navigation().closeDialog(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: royalBlue,
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.logout),
          //     onPressed: () async {
          //       //*
          //       Navigation().goToScreenAndClearAll(
          //           context, (context) => const PickAppTypeScreen());
          //     },
          //   ),
          // ],
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
                      style: GoogleFonts.firaSans(fontSize: 30.sp, fontWeight: FontWeight.bold, color: black),
                    ),
                    SizedBox(height: 10.h),
                    //* //*
                    GestureDetector(
                      onTap: () async {
                        if (checkInCompleted) return;

                        Navigation().showLoadingGifDialog(context);

                        await initData();

                        var check = await AttendenceApis().checkIn(widget.employeeId, serverTimeForAPI, "work from home");

                        Navigation().closeDialog(context);

                        if (check!.status == 1) {
                          checkInCompleted = true;

                          showDialog(
                            context: context,
                            builder: (context) => const OkDialog(text: 'Check IN is Completed'),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => OkDialog(text: check.message!),
                          );
                        }

                        setState(() {});
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.r)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset('assets/images/check-in.png', height: 75.h, width: 75.w),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('check_in'),
                                maxLines: 2,
                                style: GoogleFonts.firaSans(fontSize: 28.sp, fontWeight: FontWeight.bold, color: black),
                              ),
                              const Spacer(),
                              //Icon(Icons.arrow_forward_ios, size: 30, color: royalBlue),
                              checkInCompleted
                                  ? Image.asset('assets/images/checked.png', height: 40.h, width: 30.w)
                                  : Image.asset('assets/images/cross.png', height: 40.h, width: 30.w),
                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // //* //*
                    GestureDetector(
                      onTap: () async {
                        if (checkOutCompleted) return;

                        Navigation().showLoadingGifDialog(context);

                        await initData();

                        var check = await AttendenceApis().checkOut(widget.employeeId, serverTimeForAPI, "work from home");

                        Navigation().closeDialog(context);

                        if (check!.status == 1) {
                          checkOutCompleted = true;

                          showDialog(
                            context: context,
                            builder: (context) => const OkDialog(text: 'Check OUT is Completed'),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => OkDialog(text: check.message!),
                          );
                        }

                        setState(() {});
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.r)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset('assets/images/check-out.png', height: 75.h, width: 75.w),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('check_out'),
                                maxLines: 2,
                                style: GoogleFonts.firaSans(fontSize: 28.sp, fontWeight: FontWeight.bold, color: black),
                              ),
                              const Spacer(),
                              //   Icon(Icons.arrow_forward_ios, size: 30, color: royalBlue),
                              checkOutCompleted
                                  ? Image.asset('assets/images/checked.png', height: 40.h, width: 30.w)
                                  : Image.asset('assets/images/cross.png', height: 40.h, width: 30.w),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        child: Container(
                          height: 150.h,
                          width: AppDimentions().availableWidth * 0.7,
                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.r)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 20.w),
                              Image.asset('assets/images/clipboard.png', height: 75.h, width: 75.w),
                              SizedBox(width: 20.w),
                              Text(
                                languageProvider.translate('view_time_sheet'),
                                style: GoogleFonts.firaSans(fontSize: 28.sp, fontWeight: FontWeight.bold, color: black),
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
                  ],
                )
              : const Center(child: CircularProgressIndicator(color: royalBlue)),
        ),
      ),
    );
  }
}
