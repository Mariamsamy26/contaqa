import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_style.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return TextFormField(
      controller: controller,
      style: mediumText.copyWith(color: gray),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: languageProvider.translate(
          'enter_description_for_your_leave',
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: loginRegisterTextBorder,
        enabledBorder: loginRegisterTextBorder,
        focusedBorder: loginRegisterTextBorder,
        filled: true,
        fillColor: white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }
}

class SubmitLeaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SubmitLeaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalBlue,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          languageProvider.translate('submit'),
          style: mediumText.copyWith(color: white),
        ),
      ),
    );
  }
}
