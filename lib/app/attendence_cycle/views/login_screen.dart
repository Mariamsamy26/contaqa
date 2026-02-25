import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/app/attendence_cycle/models/app_version.dart';
import 'package:contaqa/app/attendence_cycle/services/attendence_apis.dart';
import 'package:contaqa/app/attendence_cycle/widgets/UnClosable_Ok_Dialog.dart';
import 'package:contaqa/app/home_cycle/views/pick_app_type_screen.dart';
import 'package:contaqa/helpers/application_dimentions.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/widget/ok_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool hidePassword = true;

  double downloadProgress = 0.0;
  String downloadSpeed = '0 KB/s';
  bool isDownloading = false;
  AppVersion? appVersionInfo;

  String version = "0.0.0";
  String versionWithoutBuildNumber = "0.0.0";
  bool forceUpdateRequired = false;
  bool isUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = "${info.version}+${info.buildNumber}";
      versionWithoutBuildNumber = info.version;
    });

    await checkForUpdates();
  }

  bool _isUpdateRequired(
    String localVersionName,
    String localBuildNumber,
    String? serverVersionName,
    int? serverBuildNumber,
  ) {
    if (serverVersionName == null) return false;

    List<int> localParts = localVersionName
        .split('+')[0]
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> serverParts = serverVersionName
        .split('+')[0]
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (int i = 0; i < 3; i++) {
      int localPart = i < localParts.length ? localParts[i] : 0;
      int serverPart = i < serverParts.length ? serverParts[i] : 0;
      if (serverPart > localPart) return true;
      if (serverPart < localPart) return false;
    }

    if (serverBuildNumber != null) {
      int localBuild = int.tryParse(localBuildNumber) ?? 0;
      if (serverBuildNumber > localBuild) return true;
    }

    return false;
  }

  Future<void> checkForUpdates() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final localName = info.version;
      final localBuild = info.buildNumber;

      final serverVersion = await AttendenceApis().getAppVersion();
      if (serverVersion == null) {
        log('Failed to fetch app version from server.');
        return;
      }

      setState(() {
        appVersionInfo = serverVersion;
      });

      bool updateNeeded = _isUpdateRequired(
        localName,
        localBuild,
        serverVersion.versionName,
        serverVersion.versionCode,
      );

      setState(() {
        forceUpdateRequired =
            updateNeeded && (serverVersion.forceUpdate ?? false);
        isUpdateAvailable = updateNeeded;
      });

      if (updateNeeded &&
          serverVersion.apkUrl != null &&
          serverVersion.apkUrl!.isNotEmpty) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UnClosableOkDialog(
            text: 'New version available (${serverVersion.versionName})',
            onPressed: () {
              Navigator.pop(context);
              setState(() => isDownloading = true);
              downloadAndInstallApk(serverVersion.apkUrl!);
            },
          ),
        );
      }
    } catch (e) {
      log('Error in checkForUpdates: $e');
    }
  }

  Future<void> downloadAndInstallApk(String apkURL) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        log('Starting download attempt ${retryCount + 1} from: $apkURL');
        final dir = await getExternalStorageDirectory();
        if (dir == null) throw 'Could not access external storage';
        final file = File('${dir.path}/app-release.apk');

        if (await file.exists()) {
          await file.delete();
        }

        int lastReceived = 0;
        DateTime lastUpdateTime = DateTime.now();

        final dio = Dio();
        await dio.download(
          apkURL,
          file.path,
          options: Options(
            followRedirects: true,
            receiveTimeout: const Duration(minutes: 10),
            sendTimeout: const Duration(minutes: 1),
            headers: {
              'Connection': 'Keep-Alive',
              'Keep-Alive': 'timeout=60, max=100',
            },
          ),
          onReceiveProgress: (received, total) {
            final now = DateTime.now();
            final diffMs = now.difference(lastUpdateTime).inMilliseconds;

            if (diffMs >= 1000) {
              final bytesDiff = received - lastReceived;
              final speedBytesPerSec = bytesDiff / (diffMs / 1000);

              String speedText;
              if (speedBytesPerSec >= 1024 * 1024) {
                speedText =
                    '${(speedBytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
              } else {
                speedText =
                    '${(speedBytesPerSec / 1024).toStringAsFixed(0)} KB/s';
              }

              if (mounted) {
                setState(() => downloadSpeed = speedText);
              }
              lastReceived = received;
              lastUpdateTime = now;
            }

            if (total > 0 && mounted) {
              setState(() => downloadProgress = received / total);
            }
          },
        );

        log('Download completed. File saved at: ${file.path}');
        final result = await OpenFilex.open(file.path);
        log('OpenFilex result: ${result.type} - ${result.message}');

        if (result.type != ResultType.done && mounted) {
          showDialog(
            context: context,
            builder: (context) =>
                OkDialog(text: 'Installer Error: ${result.message}'),
          );
        }

        if (mounted) {
          setState(() {
            isDownloading = false;
            downloadProgress = 0.0;
          });
        }
        return; // Success
      } catch (e) {
        log('Error during download (attempt ${retryCount + 1}): $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => OkDialog(text: 'Update failed: $e'),
            );
            setState(() {
              isDownloading = false;
              downloadProgress = 0.0;
            });
          }
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDimentions().appDimentionsInit(context);
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50.h),

                  Image.asset(
                    'assets/images/Contaqa_logo.png',
                    height: 250.h,
                    width: 250.w,
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return 'Please enter an email address';
                      }
                      final regex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!regex.hasMatch(email)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Email'),
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
                        return 'Password is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      border: loginRegisterTextBorder,
                      enabledBorder: loginRegisterTextBorder,
                      errorBorder: loginRegisterTextBorder,
                      focusedBorder: loginRegisterTextBorder,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: Icon(
                          hidePassword
                              ? Icons.remove_red_eye_outlined
                              : Icons.remove_red_eye,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 150.h),

                  SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          forceUpdateRequired ? Colors.grey : royalBlue,
                        ),
                      ),
                      onPressed: forceUpdateRequired
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                Navigation().showLoadingGifDialog(context);

                                await AttendenceApis()
                                    .login(
                                      _emailController.text,
                                      _passwordController.text,
                                    )
                                    .then((loginResponse) async {
                                      Navigation().closeDialog(context);

                                      if (loginResponse != null) {
                                        if (loginResponse.status == 1 &&
                                            loginResponse.employeeId != null) {
                                          final pref =
                                              await SharedPreferences.getInstance();
                                          await pref.setInt(
                                            'employee_id',
                                            loginResponse.employeeId!,
                                          );
                                          await pref.setString(
                                            'email',
                                            _emailController.text,
                                          );
                                          await pref.setString(
                                            'password',
                                            _passwordController.text,
                                          );

                                          Navigation().goToScreenAndClearAll(
                                            context,
                                            (context) =>
                                                const PickAppTypeScreen(),
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => const OkDialog(
                                              text:
                                                  'Please Check your Credentials',
                                            ),
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const OkDialog(
                                            text: 'Login Failed: No Response',
                                          ),
                                        );
                                      }
                                    });
                              }
                            },

                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (forceUpdateRequired) ...[
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Please update the app to continue',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (isUpdateAvailable) ...[
                    SizedBox(height: 20.h),
                    if (!isDownloading)
                      const SizedBox()
                    else ...[
                      LinearProgressIndicator(
                        value: downloadProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(downloadProgress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            downloadSpeed,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  SizedBox(height: 70.h),

                  Text(
                    versionWithoutBuildNumber,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
