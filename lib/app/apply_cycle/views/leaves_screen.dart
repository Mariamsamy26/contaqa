import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contaqa/helpers/navigation_helper.dart';
import 'package:provider/provider.dart';
import 'package:contaqa/providers/language_provider.dart';
import '../providers/hr_leave_provider.dart';

import '../../../styles/colors.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<HrLeaveProvider>(context, listen: false);
      await provider.loadLeaves();
      await provider.loadLeaveTypes();

      await provider.loadAllocations();
    });
  }

  String _getStateLabel(String state) {
    switch (state.toLowerCase()) {
      case 'validate':
        return 'Approved';
      case 'confirm':
        return 'Waiting';
      case 'refuse':
        return 'Refuse';
      case 'draft':
        return 'Draft';
      default:
        return state;
    }
  }

  Color _getStatusColor(String state) {
    switch (state.toLowerCase()) {
      case 'validate':
        return Colors.green;
      case 'confirm':
        return Colors.orange;
      case 'refuse':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return royalBlue;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: backGroundLight,
      appBar: AppBar(
        title: Text(languageProvider.translate('leave_requests')),
        leading: IconButton(
          onPressed: () => Navigation().closeDialog(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: royalBlue,
        ),
        backgroundColor: white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Consumer<HrLeaveProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(color: royalBlue),
            );
          }
          if (provider.leaves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80.sp, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text(
                    languageProvider.translate('no_leaves_found'),
                    style: TextStyle(fontSize: 18.sp, color: gray),
                  ),
                ],
              ),
            );
          }
          return SafeArea(
            child: Container(
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
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: ListView.separated(
                itemCount: provider.leaves.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final leave = provider.leaves[index];
                  final statusColor = _getStatusColor(leave.state);

                  return Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(width: 6.w, color: statusColor),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                leave.holidayStatusName,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: black,
                                                ),
                                              ),
                                              if (leave.name.isNotEmpty &&
                                                  leave.name !=
                                                      leave.holidayStatusName)
                                                Text(
                                                  leave.name,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: gray,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          child: Text(
                                            languageProvider.translate(
                                              _getStateLabel(leave.state),
                                            ),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        _buildDateInfo(
                                          Icons.calendar_today_outlined,
                                          languageProvider.translate('from'),
                                          _formatDate(leave.requestDateFrom),
                                        ),
                                        SizedBox(width: 24.w),
                                        _buildDateInfo(
                                          Icons.calendar_month_outlined,
                                          languageProvider.translate('to'),
                                          _formatDate(leave.requestDateTo),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 24.h, thickness: 0.5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 16.sp,
                                              color: gray,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "${leave.numberOfDays.round()} ${languageProvider.translate('days')}",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: gray,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${languageProvider.translate('type')}: ${leave.holidayStatusName}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: royalBlue),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: gray),
            ),
            Text(
              date,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
