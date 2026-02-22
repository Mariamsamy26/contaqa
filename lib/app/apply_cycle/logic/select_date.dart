import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/widget/dialog.dart';

class SelectDate {
  static Future<void> pickDateRange({
    required BuildContext context,
    required bool isPTO,
    required int selectedDays,
    required DateTime? currentFromDate,
    required DateTime? currentToDate,
    required Function(DateTime from, DateTime to, int days) onDateSelected,
  }) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12, 1),
        selectedDayHighlightColor: royalBlue,
      ),
      dialogSize: Size(300.w, 400.h),
      value: currentFromDate != null && currentToDate != null
          ? [currentFromDate, currentToDate]
          : [],
    );

    if (results != null && results.isNotEmpty) {
      final from = results[0];
      final to = results.length > 1 ? results[1] : results[0];

      if (from != null && to != null) {
        final diff = calculateWorkingDays(from, to);

        if (isPTO && diff > selectedDays) {
          if (context.mounted) {
            showErrorDialog(
              'Please select less than or equal $selectedDays day${selectedDays == 1 ? '' : 's'}!',
              context,
            );
          }
          return;
        }

        onDateSelected(from, to, diff);
      }
    }
  }

  static int calculateWorkingDays(DateTime from, DateTime to) {
    int count = 0;
    DateTime current = from;

    while (!current.isAfter(to)) {
      if (current.weekday != DateTime.friday &&
          current.weekday != DateTime.saturday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }
}
