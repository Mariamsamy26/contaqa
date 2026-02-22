import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_style.dart';
import '../providers/hr_leave_provider.dart';

class LeaveTypeDropdown extends StatelessWidget {
  final HrLeaveProvider provider;
  final int? selectedLeaveTypeId;
  final ValueChanged<int?> onChanged;

  const LeaveTypeDropdown({
    super.key,
    required this.provider,
    required this.selectedLeaveTypeId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return DropdownButtonFormField<int>(
      value: provider.leaveTypes.any((e) => e.id == selectedLeaveTypeId)
          ? selectedLeaveTypeId
          : null,
      isExpanded: true,
      hint: Text(
        provider.loading
            ? languageProvider.translate('loading_leave_types')
            : languageProvider.translate('select_leave_type'),
        style: mediumText.copyWith(color: gray),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: royalBlue),
      decoration: _getInputDecoration('Leave Type'),
      items: provider.leaveTypes.map((record) {
        return DropdownMenuItem<int>(
          value: record.id,
          child: Text(
            record.displayName ?? '',
            style: mediumText.copyWith(fontSize: 16.sp, color: gray),
          ),
        );
      }).toList(),
      onChanged: provider.leaveTypes.isEmpty ? null : onChanged,
      validator: (value) => value == null ? 'Please select leave type' : null,
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: loginRegisterTextBorder,
      enabledBorder: loginRegisterTextBorder,
      focusedBorder: loginRegisterTextBorder,
      filled: true,
      fillColor: white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
    );
  }
}

class DaysAppliedDropdown extends StatelessWidget {
  final int? selectedDays;
  final double leaveAllow;
  final bool isPTO;
  final ValueChanged<int?> onChanged;

  const DaysAppliedDropdown({
    super.key,
    required this.selectedDays,
    required this.leaveAllow,
    required this.isPTO,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPTO) return const SizedBox.shrink();

    return DropdownButtonFormField<int>(
      value: selectedDays,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: royalBlue),
      menuMaxHeight: 0.4.sh,
      dropdownColor: white,
      decoration: _getInputDecoration('Number of Days Applied'),
      style: mediumText.copyWith(color: gray, fontSize: 16.sp),
      items: List.generate(leaveAllow.toInt(), (index) => index + 1).map((
        int value,
      ) {
        return DropdownMenuItem<int>(
          value: value,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text('$value', style: mediumText.copyWith(fontSize: 16.sp)),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) return 'Please select number of days';
        if (isPTO && value > leaveAllow) {
          return 'Exceeds balance (${leaveAllow.toInt()} days)';
        }
        return null;
      },
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: mediumText.copyWith(color: gray),
      border: loginRegisterTextBorder,
      enabledBorder: loginRegisterTextBorder,
      focusedBorder: loginRegisterTextBorder,
      filled: true,
      fillColor: white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
    );
  }
}
