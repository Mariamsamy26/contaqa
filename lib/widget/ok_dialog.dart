import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/styles/colors.dart';

class OkDialog extends StatelessWidget {
  final String text;

  const OkDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: royalBlue,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          TextButton(
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(royalBlue),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            onPressed: () {
              Navigation().closeDialog(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text(
                'OK',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
