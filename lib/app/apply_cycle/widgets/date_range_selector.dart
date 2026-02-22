import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:contaqa/widget/dialog.dart';
import 'package:provider/provider.dart';
import '../../../styles/colors.dart';
import '../../../styles/text_style.dart';
import '../logic/select_date.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? selectedLeaveTypeId;
  final int? selectedDays;
  final bool isPTO;
  final Function(DateTime, DateTime, int) onDateSelected;

  const DateRangeSelector({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedLeaveTypeId,
    required this.selectedDays,
    required this.isPTO,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: black.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateField(fromDate, languageProvider.translate('from_date')),
          Icon(Icons.arrow_forward, color: gray),
          _buildDateField(
            toDate,
            languageProvider.translate('to_date'),
            textAlign: TextAlign.right,
          ),
          IconButton(
            onPressed: () => _handleTap(context),
            icon: Icon(
              Icons.calendar_month,
              color: royalBlue.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (selectedLeaveTypeId == null) {
      showErrorDialog('Please select Leave Type first!', context);
      return;
    }

    SelectDate.pickDateRange(
      context: context,
      isPTO: isPTO,
      selectedDays: selectedDays!,
      currentFromDate: fromDate,
      currentToDate: toDate,
      onDateSelected: onDateSelected,
    );
  }

  Widget _buildDateField(
    DateTime? date,
    String label, {
    TextAlign textAlign = TextAlign.left,
  }) {
    return Text(
      date != null ? _formatDate(date) : label,
      textAlign: textAlign,
      style: mediumText.copyWith(fontSize: 15.sp, color: gray),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
