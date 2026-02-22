import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/app/attendence_cycle/services/attendence_apis.dart';
import 'package:contaqa/app/home_cycle/views/pick_app_type_screen.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/widget/ok_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:contaqa/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // final _emailController = TextEditingController(text: "amira.mohamed@contaqa.eg");
  // final _passwordController = TextEditingController(text: "contaqa+001");

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);
    final languageProvider = context.watch<LanguageProvider>();
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SizedBox(
          height: AppDimentions().availableheightWithAppBar,
          width: AppDimentions().availableWidth,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10.h,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50.h),
                  Image.asset('assets/images/Contaqa_logo.png', height: 250.h),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return languageProvider.translate('enter_email');
                      }

                      // Regular expression for validating email
                      final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!regex.hasMatch(email)) {
                        return languageProvider.translate('valid_email');
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: Text(languageProvider.translate('email')),
                      border: loginRegisterTextBorder,
                      enabledBorder: loginRegisterTextBorder,
                      errorBorder: loginRegisterTextBorder,
                      focusedBorder: loginRegisterTextBorder,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: hidePassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return languageProvider.translate('password_required');
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: Text(languageProvider.translate('password')),
                      border: loginRegisterTextBorder,
                      enabledBorder: loginRegisterTextBorder,
                      errorBorder: loginRegisterTextBorder,
                      focusedBorder: loginRegisterTextBorder,
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: Icon(hidePassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye),
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(height: 150.h),
                  SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                        backgroundColor: const WidgetStatePropertyAll(royalBlue),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          //*
                          Navigation().showLoadingGifDialog(context);
                          //*
                          await AttendenceApis().login(_emailController.text, _passwordController.text).then((
                            loginResponse,
                          ) async {
                            //*
                            Navigation().closeDialog(context);
                            //*
                            if (loginResponse != null) {
                              if (loginResponse.status == 1) {
                                if (loginResponse.employeeId != null) {
                                  //* ALL GOOD
                                  final pref = await SharedPreferences.getInstance();
                                  await pref.setInt('employee_id', loginResponse.employeeId!);
                                  await pref.setString('email', _emailController.text);
                                  await pref.setString('password', _passwordController.text);

                                  print("mmm");
                                  Navigation().goToScreenAndClearAll(context, (context) => const PickAppTypeScreen());
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => OkDialog(text: languageProvider.translate('error_no_employee_id')),
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => OkDialog(text: languageProvider.translate('check_credentials')),
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => OkDialog(text: languageProvider.translate('login_failed')),
                              );
                            }
                          });
                        }
                      },
                      child: Text(
                        languageProvider.translate('login'),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
