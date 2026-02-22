import 'dart:developer';

import 'package:contaqa/app/attendence_cycle/models/check.dart';
import 'package:contaqa/app/attendence_cycle/models/login_model.dart';
import 'package:contaqa/app/attendence_cycle/models/monthly_attendence.dart';
import 'package:contaqa/app/attendence_cycle/models/server_time.dart';
import 'package:contaqa/services/dio_client.dart';

class AttendenceApis {
  Future<Login?> login(String email, String password) async {
    String url = 'http://65.109.226.255:11000/login-odoo/';

    try {
      final response = await Client.client.post(url, data: {"username": email, "password": password});

      if (response.statusCode == 200) {
        Login login = Login.fromJson(response.data);

        log(response.data.toString());

        return login;
      } else {
        return null;
      }
    } catch (e) {
      throw 'login error >> $e';
    }
  }

  Future<ServerTime?> getServerTime() async {
    String url = 'http://65.109.226.255:11000/server_time';

    try {
      final response = await Client.client.get(url);

      if (response.statusCode == 200) {
        ServerTime serverTime = ServerTime.fromJson(response.data);

        log(response.data.toString());

        return serverTime;
      } else {
        return null;
      }
    } catch (e) {
      throw 'getServerTime error >> $e';
    }
  }

  Future<MonthlyAttendence?> getMonthlyAttendence(int employeeId, int year, int month) async {
    print('$employeeId -- $year -- $month');

    String url = 'http://65.109.226.255:11000/monthly_attendance';

    try {
      final response = await Client.client.post(url, data: {"employee_id": employeeId, "year": year, "month": month});

      if (response.statusCode == 200) {
        MonthlyAttendence monthlyAttendence = MonthlyAttendence.fromJson(response.data);

        log(response.data.toString());

        return monthlyAttendence;
      } else {
        return null;
      }
    } catch (e) {
      throw 'getMonthlyAttendence error >> $e';
    }
  }

  Future<Check?> checkIn(int employeeId, String timeChecked, String deviceType) async {
    String url = 'http://65.109.226.255:11000/check_in';

    try {
      final response = await Client.client.post(
        url,
        data: {"employee_id": employeeId, "check_in": timeChecked, "device_type": deviceType},
      );

      if (response.statusCode == 200) {
        Check check = Check.fromJson(response.data);

        log(response.data.toString());

        return check;
      } else {
        return null;
      }
    } catch (e) {
      throw 'checkIn error >> $e';
    }
  }

  Future<Check?> checkOut(int employeeId, String timeChecked, String deviceType) async {
    String url = 'http://65.109.226.255:11000/check_out';

    try {
      final response = await Client.client.post(
        url,
        data: {"employee_id": employeeId, "check_out": timeChecked, "device_type": deviceType},
      );

      if (response.statusCode == 200) {
        Check check = Check.fromJson(response.data);

        log(response.data.toString());

        return check;
      } else {
        return null;
      }
    } catch (e) {
      throw 'checkOut error >> $e';
    }
  }

  Future<MonthlyAttendence?> getFromHomeAttendence(int employeeId, int year, int month) async {
    print('$employeeId -- $year -- $month');

    String url = 'http://65.109.226.255:11000/monthly_work_from_home_attendance';

    try {
      final response = await Client.client.post(url, data: {"employee_id": employeeId, "year": year, "month": month});

      if (response.statusCode == 200) {
        MonthlyAttendence monthlyAttendence = MonthlyAttendence.fromJson(response.data);

        log(response.data.toString());

        return monthlyAttendence;
      } else {
        return null;
      }
    } catch (e) {
      throw 'getMonthlyAttendence error >> $e';
    }
  }
}
