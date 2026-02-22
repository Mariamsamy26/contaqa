import 'package:contaqa/app/apply_cycle/providers/hr_leave_provider.dart';
import 'package:contaqa/app/apply_cycle/views/apply_form_screen.dart';
import 'package:contaqa/app/apply_cycle/views/leaves_screen.dart';
import 'package:contaqa/app/attendence_cycle/services/attendence_apis.dart';
import 'package:contaqa/app/attendence_cycle/views/meeting_screen.dart';
import 'package:contaqa/app/attendence_cycle/views/payslip_screen.dart';
import 'package:contaqa/app/attendence_cycle/views/time_sheet_screen.dart';
import 'package:contaqa/app/attendence_cycle/views/work_fom_home_home_screen.dart';
import 'package:contaqa/app/home_cycle/widgets/custom_card_widget.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:contaqa/app/attendence_cycle/views/attendence_home_screen.dart';
import 'package:contaqa/app/attendence_cycle/views/login_screen.dart';
import 'package:contaqa/app/home_cycle/providers/webview_provider.dart';
import 'package:contaqa/app/home_cycle/views/home_screen.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/styles/text_style.dart';
import 'package:contaqa/widget/ok_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickAppTypeScreen extends StatefulWidget {
  const PickAppTypeScreen({super.key});

  @override
  State<PickAppTypeScreen> createState() => _PickAppTypeScreenState();
}

class _PickAppTypeScreenState extends State<PickAppTypeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HrLeaveProvider>().initAll();
      context.read<HrLeaveProvider>().getLeaveAllow();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);
    final languageProvider = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('app_title')),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<HrLeaveProvider>().logOut();
            if (!context.mounted) return;
            Navigation().goToScreenAndClearAll(
              context,
              (context) => const LoginScreen(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              languageProvider.toggleLanguage();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
        height: AppDimentions().availableheightWithAppBar,
        width: AppDimentions().availableWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [royalBlue, electricBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 10,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 5.h,
                padding: EdgeInsets.only(top: 20.h),
                childAspectRatio: 0.85,
                children: [
                  CustomCardWidget(
                    title: languageProvider.translate('company_attendance'),
                    imagePath: 'assets/images/work.png',
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();

                      int employeeId = pref.getInt('employee_id')!;
                      Navigation().goToScreen(
                        context,
                        (context) => AttendenceHome(employeeId: employeeId),
                      );
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('from_home_attendance'),
                    imagePath: 'assets/images/workFromHome.png',
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();

                      int employeeId = pref.getInt('employee_id')!;
                      Navigation().goToScreen(
                        context,
                        (context) => WorkFromHomeScreen(employeeId: employeeId),
                      );
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('email'),
                    imagePath: 'assets/images/business.png',
                    onTap: () {
                      Navigation().goToScreen(
                        context,
                        (context) => const HomeScreen(),
                      );
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('time_sheet'),
                    imagePath: 'assets/images/schedule.png',
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      int employeeId = pref.getInt('employee_id')!;

                      Navigation().showLoadingGifDialog(context);
                      var now = DateTime.now();
                      await AttendenceApis()
                          .getMonthlyAttendence(employeeId, now.year, now.month)
                          .then((monthlyAttendence) {
                            Navigation().closeDialog(context);
                            if (monthlyAttendence!.status == 1) {
                              Navigation().goToScreen(
                                context,
                                (context) => TimeSheetScreen(
                                  monthlyAttendence: monthlyAttendence,
                                ),
                              );
                            }
                          });
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('request_time_off'),
                    imagePath: 'assets/images/apply.png',
                    onTap: () => Navigation().goToScreen(
                      context,
                      (context) => const ApplyFormScreen(),
                    ),
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('leave_requests'),
                    imagePath: 'assets/images/daysOff.png',
                    onTap: () {
                      Navigation().goToScreen(
                        context,
                        (context) => const LeavesScreen(),
                      );
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('payslip'),
                    imagePath: 'assets/images/payslip.png',
                    onTap: () {
                      Navigation().goToScreen(
                        context,
                        (context) => const PayslipScreen(),
                      );
                    },
                  ),
                  CustomCardWidget(
                    title: languageProvider.translate('meeting'),
                    imagePath: 'assets/images/meeting.png',
                    onTap: () {
                      Navigation().goToScreen(
                        context,
                        (context) => const MeetingScreen(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
