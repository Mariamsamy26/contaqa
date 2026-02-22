import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:provider/provider.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('payslip')),
        leading: IconButton(
          onPressed: () => Navigation().closeDialog(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: royalBlue,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              electricBlue.withOpacity(0.05),
              royalBlue.withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            languageProvider.translate('soon'),
            style: TextStyle(fontSize: 30.sp),
          ),
        ),
      ),
    );
  }
}
