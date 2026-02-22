import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_style.dart';

class BalanceDisplayCard extends StatelessWidget {
  final double leaveAllow;

  const BalanceDisplayCard({super.key, required this.leaveAllow});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            languageProvider.translate('paid_time_off_balance'),
            style: mediumText.copyWith(color: black),
          ),
          Text(
            "${leaveAllow.toInt()} ${languageProvider.translate('days')}",
            style: boldText.copyWith(color: black, fontSize: 18.sp),
          ),
        ],
      ),
    );
  }
}
