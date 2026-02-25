import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:contaqa/app/apply_cycle/models/hr_allocation.dart';
import 'package:contaqa/app/apply_cycle/models/hr_leave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/get_leave_type_model.dart';
import '../services/odoo_service.dart';
import '../services/leave_api.dart';

class HrLeaveProvider extends ChangeNotifier {
  final _service = OdooService();

  bool loading = false;
  List<HrLeave> leaves = [];
  List<HrAllocation> allocations = [];
  List<Record> leaveTypes = [];
  double _leaveAllow = 0;
  int? _leaveTypeId = 0;

  // Quick lookup map: ID -> Name
  Map<int, String> leaveTypeMap = {};

  double get leaveAllow => _leaveAllow;

  int? getPaidTimeOffTypeId() {
    try {
      _leaveTypeId = leaveTypes
          .firstWhere((e) => e.displayName == 'Paid Time Off')
          .id;
      return _leaveTypeId;
    } catch (e) {
      return null;
    }
  }

  Future<double> getLeaveAllow() async {
    final pref = await SharedPreferences.getInstance();
    final employeeId = pref.getInt('employee_id');

    if (employeeId == null) return 0;

    final leaveTypeId = await getPaidTimeOffTypeId();
    if (leaveTypeId == null) return 0;

    final remainingLeave = await LeaveApi().getRemainingLeave(
      employeeId: employeeId,
      leaveTypeId: leaveTypeId,
    );

    _leaveAllow = remainingLeave?.remaining ?? 0;
    return _leaveAllow;
  }

  Future<void> loadAllocations() async {
    loading = true;
    notifyListeners();

    try {
      allocations = await _service.getLeaveAllocations();
    } catch (e) {
      debugPrint('Error loading allocations: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadLeaves() async {
    loading = true;
    notifyListeners();

    leaves = await _service.getLeaves();

    loading = false;
    notifyListeners();
  }

  Future<List<Record>> loadLeaveTypes() async {
    loading = true;
    notifyListeners();
    try {
      final model = await LeaveApi().getLeaveType();
      if (model != null && model.records != null) {
        leaveTypes = model.records!;
        leaveTypeMap = {
          for (var record in leaveTypes)
            if (record.id != null && record.displayName != null)
              record.id!: record.displayName!,
        };
      }
    } catch (e) {
      debugPrint('Error fetching leave types: $e');
    }
    loading = false;
    notifyListeners();
    return leaveTypes;
  }

  Future<void> addLeave(HrLeave leave, {File? attachment}) async {
    loading = true;
    notifyListeners();
    try {
      // 1. Create the Leave Request
      final leaveId = await _service.addLeave(leave);

      // 2. If there is an attachment, upload it linked to this leave
      if (attachment != null) {
        try {
          final bytes = await attachment.readAsBytes();
          final base64Image = base64Encode(bytes);
          final fileName = attachment.path.split('/').last;

          await _service.createAttachment(
            leaveId,
            'hr.leave',
            fileName,
            base64Image,
          );
        } catch (e) {
          debugPrint('Failed to upload attachment: $e');
        }
      }

      await loadLeaves();
    } catch (e) {
      debugPrint('Error adding leave: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    await _service.logout();

    final pref = await SharedPreferences.getInstance();
    pref.clear();
    pref.remove('employee_id');
    pref.remove('email');
    pref.remove('password');
    pref.clear();
  }

  bool isLoading = false;
  String? error;

  Future<void> initAll() async {
    try {
      isLoading = true;
      notifyListeners();

      await loadLeaveTypes();
      await loadAllocations();
      await loadLeaves();

      await getLeaveAllow();

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
