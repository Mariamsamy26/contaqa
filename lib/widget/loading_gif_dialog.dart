import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../styles/colors.dart';

class LoadingGifDialog extends StatelessWidget {
  const LoadingGifDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: SizedBox(
          height: 75.h,
          width: 75.w,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballScale,
            pathBackgroundColor: electricBlue,
            colors: [electricBlue],
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
