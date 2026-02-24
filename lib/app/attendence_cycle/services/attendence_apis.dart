import 'dart:convert';
import 'dart:developer';

import 'package:contaqa/app/attendence_cycle/models/app_version.dart';
import 'package:contaqa/app/attendence_cycle/models/check.dart';
import 'package:contaqa/app/attendence_cycle/models/login_model.dart';
import 'package:contaqa/app/attendence_cycle/models/monthly_attendence.dart';
import 'package:contaqa/app/attendence_cycle/models/server_time.dart';
import 'package:contaqa/services/dio_client.dart';

class AttendenceApis {
  static const String baseUrl = 'http://65.109.226.255:11000';

  /* ----------------------------- LOGIN ----------------------------- */

  Future<Login?> login(String email, String password) async {
    return _request(
      () => Client.client.post(
        '$baseUrl/login-odoo/',
        data: {"username": email, "password": password},
      ),
      (data) => Login.fromJson(data),
      'login',
    );
  }

  /* --------------------------- SERVER TIME --------------------------- */

  Future<ServerTime?> getServerTime() async {
    return _request(
      () => Client.client.get('$baseUrl/server_time'),
      (data) => ServerTime.fromJson(data),
      'getServerTime',
    );
  }

  /* ----------------------- MONTHLY ATTENDANCE ----------------------- */

  Future<MonthlyAttendence?> getMonthlyAttendence(
      int employeeId, int year, int month) async {
    return _request(
      () => Client.client.post(
        '$baseUrl/monthly_attendance',
        data: {
          "employee_id": employeeId,
          "year": year,
          "month": month,
        },
      ),
      (data) => MonthlyAttendence.fromJson(data),
      'getMonthlyAttendence',
    );
  }

  /* ----------------------------- CHECK IN ---------------------------- */

  Future<Check?> checkIn(
      int employeeId, String timeChecked, String deviceType) async {
    return _request(
      () => Client.client.post(
        '$baseUrl/check_in',
        data: {
          "employee_id": employeeId,
          "check_in": timeChecked,
          "device_type": deviceType,
        },
      ),
      (data) => Check.fromJson(data),
      'checkIn',
    );
  }

  /* ----------------------------- CHECK OUT --------------------------- */

  Future<Check?> checkOut(
      int employeeId, String timeChecked, String deviceType) async {
    return _request(
      () => Client.client.post(
        '$baseUrl/check_out',
        data: {
          "employee_id": employeeId,
          "check_out": timeChecked,
          "device_type": deviceType,
        },
      ),
      (data) => Check.fromJson(data),
      'checkOut',
    );
  }

  /* ---------------------- WORK FROM HOME ATTENDANCE ---------------------- */

  Future<MonthlyAttendence?> getFromHomeAttendence(
      int employeeId, int year, int month) async {
    return _request(
      () => Client.client.post(
        '$baseUrl/monthly_work_from_home_attendance',
        data: {
          "employee_id": employeeId,
          "year": year,
          "month": month,
        },
      ),
      (data) => MonthlyAttendence.fromJson(data),
      'getFromHomeAttendence',
    );
  }

  /* ----------------------------- APP VERSION ----------------------------- */

  Future<AppVersion?> getAppVersion() async {
    return _retryRequest(
      () => Client.client.get(
        'http://157.180.26.238/mariam/version_info.json',
      ),
      (data) {
        if (data is String) {
          return AppVersion.fromJson(json.decode(data));
        }
        return AppVersion.fromJson(data);
      },
    );
  }

  /* ========================= COMMON HELPERS ========================= */

  /// Normal request
  Future<T?> _request<T>(
    Future<dynamic> Function() apiCall,
    T Function(dynamic data) parser,
    String tag,
  ) async {
    try {
      final response = await apiCall();

      if (response.statusCode == 200) {
        log('$tag => ${response.data}');
        return parser(response.data);
      }

      return null;
    } catch (e) {
      throw '$tag error >> $e';
    }
  }

  /// Retry request (used for version check)
  Future<T?> _retryRequest<T>(
    Future<dynamic> Function() apiCall,
    T Function(dynamic data) parser, {
    int retries = 3,
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await apiCall();

        if (response.statusCode == 200) {
          return parser(response.data);
        }
      } catch (_) {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return null;
  }
}