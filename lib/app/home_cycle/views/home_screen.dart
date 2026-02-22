import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:contaqa/app/home_cycle/views/internet_checker_screen.dart';
import '../providers/webview_provider.dart';
import '../../../widget/yes_no_dialog.dart';
import 'package:provider/provider.dart';

import '../../../helpers/navigation_helper.dart';
import '../../../widget/loading_percent_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: false,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    javaScriptEnabled: true,
    useOnDownloadStart: true,
  );

  int pageProgress = 0;
  bool showLoading = false;

  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        body: PopScope(
          //   canPop: false,
          onPopInvokedWithResult: (didPop, value) async {
            // if (await webViewController!.canGoBack()) {
            //   webViewController!.goBack();
            // } else {
            //   print('last page');

            //   showDialog(
            //       context: context,
            //       builder: (context) => YesNoDialog(
            //             dialogText: 'Are you sure you want to Exit ?',
            //             onYesPressed: () {
            //               exit(0);
            //             },
            //             onNoPressed: () {
            //               Navigator.of(context).pop();
            //             },
            //           ));
            // }
          },
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialSettings: settings,
                  //  onWebViewCreated: _onWebViewCreated,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                  },

                  //*
                  onDownloadStartRequest: (controller, url) async {},

                  //*
                  initialUrlRequest: URLRequest(url: WebUri('https://box.gosmart.ae/mail/')),

                  onProgressChanged: (controller, progress) {
                    //    log('progress: $progress');
                    context.read<WebViewProvider>().setLoadingPercentage = progress;
                  },
                  onLoadStart: (controller, url) async {
                    log('onPageStarted $url');

                    showDialog(context: context, builder: (context) => const LoadingPercentDialog());

                    showLoading = true;
                  },
                  onLoadStop: (controller, url) {
                    if (showLoading) {
                      Navigation().closeDialog(context);
                      showLoading = false;
                    }
                  },
                  onReceivedError: (controller, request, error) async {
                    log('onReceivedError >> ${error.description}');

                    if (error.description.contains('INTERNET_DISCONNECTED')) {
                      await controller.reload();
                    }
                  },
                ),
                //* //*
                if (context.watch<WebViewProvider>().isConnected == false) const InternetCheckerScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
