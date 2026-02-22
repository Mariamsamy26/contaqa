import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/app/apply_cycle/models/hr_leave.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:contaqa/providers/language_provider.dart';
import 'package:contaqa/styles/colors.dart';
import 'package:contaqa/styles/text_style.dart';
import 'package:contaqa/widget/dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/hr_leave_provider.dart';
import 'dart:io';

import '../widgets/balance_display_card.dart';
import '../widgets/leave_form_dropdowns.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/attachment_selector_widget.dart';
import '../widgets/form_footer_widgets.dart';

class ApplyFormScreen extends StatefulWidget {
  const ApplyFormScreen({super.key});

  @override
  State<ApplyFormScreen> createState() => _ApplyFormScreenState();
}

class _ApplyFormScreenState extends State<ApplyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  int? selectedLeaveTypeId;
  int? selectedDays;
  double? leaveAllow;
  DateTime? _fromDate;
  DateTime? _toDate;
  File? _sickLeaveAttachment;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HrLeaveProvider>().initAll();
      leaveAllow = await context.read<HrLeaveProvider>().getLeaveAllow();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('request_time_off')),
        leading: IconButton(
          onPressed: () => Navigation().closeDialog(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: royalBlue,
        ),
      ),
      body: Consumer<HrLeaveProvider>(
        builder: (context, provider, child) {
          /// 🔹 Loading State
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🔹 Error State
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.error!,
                      style: mediumText.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        provider.initAll();
                      },
                      child: Text(languageProvider.translate('retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          /// 🔹 Normal UI
          final isPTO =
              provider.leaveTypeMap[selectedLeaveTypeId] == 'Paid Time Off';

          return Container(
            width: double.infinity,
            height: double.infinity,
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  children: [
                    BalanceDisplayCard(leaveAllow: leaveAllow ?? 0.0),
                    SizedBox(height: 20.h),

                    /// 🔹 Form Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(
                              languageProvider.translate('leave_type'),
                            ),
                            SizedBox(height: 8.h),
                            LeaveTypeDropdown(
                              provider: provider,
                              selectedLeaveTypeId: selectedLeaveTypeId,
                              onChanged: (value) {
                                setState(() {
                                  selectedLeaveTypeId = value;
                                  selectedDays = null;
                                  _fromDate = null;
                                  _toDate = null;
                                  _daysController.clear();
                                  _sickLeaveAttachment = null;
                                });
                              },
                            ),

                            /// 🔹 Sick attachment
                            if (selectedLeaveTypeId != null &&
                                (provider.leaveTypeMap[selectedLeaveTypeId]
                                        ?.contains('Sick') ??
                                    false)) ...[
                              SizedBox(height: 15.h),
                              AttachmentSelectorWidget(
                                onImageSelected: (file) {
                                  _sickLeaveAttachment = file;
                                },
                              ),
                            ],

                            SizedBox(height: 20.h),
                            _buildSectionLabel(
                              languageProvider.translate('date_range'),
                            ),
                            SizedBox(height: 8.h),
                            DateRangeSelector(
                              fromDate: _fromDate,
                              toDate: _toDate,
                              selectedLeaveTypeId: selectedLeaveTypeId,
                              selectedDays: leaveAllow?.toInt(),
                              isPTO: isPTO,
                              onDateSelected: (from, to, diff) {
                                setState(() {
                                  _fromDate = from;
                                  _toDate = to;
                                  if (!isPTO) selectedDays = diff;
                                  _daysController.text = diff.toString();
                                });
                              },
                            ),

                            SizedBox(height: 20.h),
                            _buildSectionLabel(
                              languageProvider.translate('description'),
                            ),
                            SizedBox(height: 8.h),
                            DescriptionField(controller: _reasonController),

                            SizedBox(height: 30.h),
                            SubmitLeaveButton(
                              onPressed: () => _submitForm(provider),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Text(
                      languageProvider.translate('leave_note'),
                      style: mediumText.copyWith(fontSize: 12.sp, color: gray),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> _submitForm(HrLeaveProvider provider) async {
    final languageProvider = context.read<LanguageProvider>();
    if (!_formKey.currentState!.validate()) return;

    if (selectedLeaveTypeId == null) {
      showErrorDialog(
        languageProvider.translate('select_leave_type_error'),
        context,
      );
      return;
    }

    if (_fromDate == null || _toDate == null) {
      showErrorDialog(
        languageProvider.translate('select_date_range_error'),
        context,
      );
      return;
    }

    final pref = await SharedPreferences.getInstance();
    final employeeId = pref.getInt('employee_id');

    if (employeeId == null) {
      showErrorDialog(languageProvider.translate('employee_id_error'), context);
      return;
    }

    final isSickLeave =
        provider.leaveTypeMap[selectedLeaveTypeId]?.contains('Sick') ?? false;

    if (isSickLeave && _sickLeaveAttachment == null) {
      showErrorDialog(
        languageProvider.translate('sick_leave_attachment_error'),
        context,
      );
      return;
    }

    final leave = HrLeave(
      employeeId: employeeId,
      holidayStatusId: selectedLeaveTypeId!,
      holidayStatusName: provider.leaveTypeMap[selectedLeaveTypeId] ?? '',
      name: _reasonController.text,
      requestDateFrom: _fromDate!,
      requestDateTo: _toDate!,
      numberOfDays: (selectedDays ?? 0).toDouble(),
      state: 'draft',
    );

    try {
      await provider.addLeave(leave, attachment: _sickLeaveAttachment);

      if (!mounted) return;

      Navigation().closeDialog(context);
      showSuccessDialog(
        languageProvider.translate('leave_submitted_success'),
        context,
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();

      if (errorMessage.contains('OdooException')) {
        final RegExp regex = RegExp(r'message:\s*"([^"]+)"|message:\s*([^,]+)');
        final match = regex.firstMatch(errorMessage);
        if (match != null) {
          errorMessage = (match.group(1) ?? match.group(2) ?? errorMessage)
              .trim();
        }
      }

      showErrorDialog(errorMessage, context);
    }
  }

  // ================= UI HELPERS =================

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: mediumText.copyWith(
        color: black,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
