import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/colors.dart';

class YesNoDialog extends StatelessWidget {
  final String dialogText;
  final void Function() onYesPressed;
  final void Function() onNoPressed;

  const YesNoDialog({super.key, required this.dialogText, required this.onYesPressed, required this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        dialogText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 5,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(royalBlue),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: onYesPressed,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              flex: 5,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(royalBlue),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: onNoPressed,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // TextButton(
            //   style: ButtonStyle(
            //     overlayColor:
            //         MaterialStateProperty.all(mainBlue.withOpacity(0.1)),
            //     shape: MaterialStateProperty.all(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(3.r),
            //       ),
            //     ),
            //   ),
            //   onPressed: onYesPressed,
            //   child: Ink(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         colors: [
            //           mainBlue.withOpacity(0.9),
            //           mainBlue.withOpacity(0.65)
            //         ],
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter,
            //       ),
            //       borderRadius: BorderRadius.all(Radius.circular(3.r)),
            //     ),
            //     child: Container(
            //       width: 70.w,
            //       padding: const EdgeInsets.all(8.0),
            //       child: const Text(
            //         'Yes',
            //         textAlign: TextAlign.center,
            //         style:
            //             TextStyle(fontWeight: FontWeight.bold, color: white),
            //       ),
            //     ),
            //   ),
            // ),
            // TextButton(
            //   style: ButtonStyle(
            //     shape: MaterialStateProperty.all(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(3.r),
            //       ),
            //     ),
            //   ),
            //   onPressed: onNoPressed,
            //   child: Ink(
            //     decoration: BoxDecoration(
            //       // gradient: const LinearGradient(
            //       //   colors: [Color(0xffffa014), Color(0xffffc062)],
            //       //   begin: Alignment.topCenter,
            //       //   end: Alignment.bottomCenter,
            //       // ),
            //       color: white,
            //       border: Border.all(
            //         color: black.withOpacity(0.8),
            //       ),
            //       borderRadius: BorderRadius.all(Radius.circular(3.r)),
            //     ),
            //     child: Container(
            //       width: 70.w,
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         'No',
            //         textAlign: TextAlign.center,
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             color: black.withOpacity(0.8)),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
