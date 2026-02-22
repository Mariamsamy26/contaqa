import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/app/attendence_cycle/models/monthly_attendence.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/styles/text_style.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimeSheetScreen extends StatelessWidget {
  final MonthlyAttendence monthlyAttendence;

  const TimeSheetScreen({super.key, required this.monthlyAttendence});

  int getOverTimeOrUnderTime(String duration) {
    String hoursInMinutes = duration.split(':')[0];
    String minutes = duration.split(':')[1];

    int totalMinutes = int.parse(hoursInMinutes) * 60 + int.parse(minutes);

    //* //*
    return totalMinutes - 480;
  }

  int getTotalWorkingTime() {
    int totalMinutes = 0;

    for (var attendance in monthlyAttendence.attendance!) {
      if (attendance.workedHours != '0:00') {
        totalMinutes += getOverTimeOrUnderTime(attendance.workedHours!);
      }
    }

    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);

    final languageProvider = context.watch<LanguageProvider>();
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.translate('time_sheet')),
          leading: IconButton(
            onPressed: () => Navigation().closeDialog(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: royalBlue,
          ),
        ),
        body: SizedBox(
          // padding: const EdgeInsets.all(5),
          height: AppDimentions().availableheightWithAppBar,
          width: AppDimentions().availableWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.grey[600],
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        languageProvider.translate('date'),
                        style: mediumText.copyWith(color: white),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        languageProvider.translate('in'),
                        style: mediumText.copyWith(color: white),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        languageProvider.translate('out'),
                        style: mediumText.copyWith(color: white),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        languageProvider.translate('hours'),
                        textAlign: TextAlign.center,
                        style: mediumText.copyWith(color: white),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '',
                        style: mediumText.copyWith(
                          color: white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //* //*

              //* //*
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListView.separated(
                    itemCount: monthlyAttendence.attendance!.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(
                                monthlyAttendence.attendance![index].checkIn!,
                              ),
                            ),
                          ),
                          monthlyAttendence.attendance![index].checkIn == null
                              ? const Expanded(flex: 2, child: Text(''))
                              : Expanded(
                                  flex: 2,
                                  child: Text(
                                    DateFormat('hh:mm a').format(
                                      monthlyAttendence
                                          .attendance![index]
                                          .checkIn!,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                          monthlyAttendence.attendance![index].checkOut == null
                              ? const Expanded(flex: 2, child: Text(''))
                              : Expanded(
                                  flex: 2,
                                  child: Text(
                                    DateFormat('hh:mm a').format(
                                      monthlyAttendence
                                          .attendance![index]
                                          .checkOut!,
                                    ),
                                  ),
                                ),
                          //* //*
                          monthlyAttendence.attendance![index].workedHours ==
                                  null
                              ? const Expanded(flex: 3, child: Text(''))
                              : Expanded(
                                  flex: 2,
                                  child: Text(
                                    monthlyAttendence
                                        .attendance![index]
                                        .workedHours!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          //* //*
                          Expanded(
                            flex: 1,
                            child: Text(
                              monthlyAttendence
                                          .attendance![index]
                                          .workedHours ==
                                      '0:00'
                                  ? ''
                                  : getOverTimeOrUnderTime(
                                      monthlyAttendence
                                          .attendance![index]
                                          .workedHours!,
                                    ).toString(),
                              textAlign: TextAlign.center,
                              style: mediumText.copyWith(
                                color:
                                    getOverTimeOrUnderTime(
                                          monthlyAttendence
                                              .attendance![index]
                                              .workedHours!,
                                        ) >=
                                        0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                          // monthlyAttendence.attendance![index].checkOut == null
                          //     ? Expanded(flex: 1, child: Text(''))
                          //     : Expanded(flex: 1, child: Text('2', textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //* //*
              //            SizedBox(height: 20.h),

              //* //*
              const Divider(),
              //* //*
              SizedBox(
                // height: 50.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        languageProvider.translate('total_working_days'),
                        style: mediumText.copyWith(color: royalBlue),
                      ),
                      Spacer(),
                      Text(
                        '${monthlyAttendence.attendance!.length}',
                        style: boldText.copyWith(
                          fontSize: 22.sp,
                          color: royalBlue,
                        ),
                      ),
                      Text(
                        ' ${languageProvider.translate('days')}',
                        style: mediumText.copyWith(color: royalBlue),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        languageProvider.translate('total_over_under_time'),
                        style: mediumText.copyWith(color: royalBlue),
                      ),
                      Spacer(),
                      Text(
                        '${getTotalWorkingTime() > 0 ? '+${getTotalWorkingTime()}' : getTotalWorkingTime()}',
                        style: boldText.copyWith(
                          fontSize: 22.sp,
                          color: royalBlue,
                        ),
                      ),
                      Text(
                        ' ${languageProvider.translate('min')}',
                        style: mediumText.copyWith(color: royalBlue),
                      ),
                      //*
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
