import 'package:flutter/material.dart';
import 'package:contaqa/app/apply_cycle/models/hr_allocation.dart';
import 'package:contaqa/app/apply_cycle/models/hr_leave.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OdooService {
  late OdooClient client;
  bool _isLoggedIn = false;

  OdooService() {
    client = OdooClient('https://erp.gosmart.eg');
  }

  Future<void> login() async {
    if (_isLoggedIn) return;

    final pref = await SharedPreferences.getInstance();
    String email = pref.getString('email')!;
    String password = pref.getString('password')!;

    await client.authenticate('Contaqa', email, password);
    _isLoggedIn = true;
  }

  // 🔹 READ
  Future<List<HrLeave>> getLeaves() async {
    await login();

    final result = await client.callKw({
      'model': 'hr.leave',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': [
          'holiday_status_id',
          'name',
          'request_date_from',
          'request_date_to',
          'number_of_days',
          'state',
        ],
        'limit': 20,
        'order': 'id desc',
      },
    });

    return (result as List).map((e) => HrLeave.fromJson(e)).toList();
  }

  Future<List<HrAllocation>> getLeaveAllocations() async {
    await login();

    final result = await client.callKw({
      'model': 'hr.leave.allocation',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': ['holiday_status_id', 'number_of_days', 'state'],
        'domain': [
          ['state', '=', 'validate'],
        ],
      },
    });

    return (result as List).map((e) => HrAllocation.fromJson(e)).toList();
  }

  // 🔹 CREATE
  Future<int> addLeave(HrLeave leave) async {
    await login();

    final data = leave.toJson();
    print('Sending to Odoo: $data');

    final id = await client.callKw({
      'model': 'hr.leave',
      'method': 'create',
      'args': [data],
      'kwargs': {},
    });

    return id;
  }

  Future<void> createAttachment(
    int resId,
    String resModel,
    String fileName,
    String base64Content,
  ) async {
    await login();

    try {
      await client.callKw({
        'model': 'ir.attachment',
        'method': 'create',
        'args': [
          {
            'name': fileName,
            'type': 'binary',
            'datas': base64Content,
            'res_model': resModel,
            'res_id': resId,
          },
        ],
        'kwargs': {},
      });
      debugPrint('Attachment created for $resModel ID: $resId');
    } catch (e) {
      debugPrint('Error creating attachment: $e');
    }
  }

  Future<void> logout() async {
    if (!_isLoggedIn) return;

    try {
      // Logout from Odoo session
      await client.callKw({
        'model': 'hr.leave',
        'method': 'session_destroy',
        'args': [],
        'kwargs': {},
      });
    } catch (e) {
      debugPrint('Odoo logout error: $e');
    }

    // Clear local session
    final pref = await SharedPreferences.getInstance();
    await pref.clear();

    _isLoggedIn = false;
  }
}
