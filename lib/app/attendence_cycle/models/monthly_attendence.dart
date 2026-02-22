// To parse this JSON data, do
//
//     final monthlyAttendence = monthlyAttendenceFromJson(jsonString);

import 'dart:convert';

MonthlyAttendence monthlyAttendenceFromJson(String str) => MonthlyAttendence.fromJson(json.decode(str));

String monthlyAttendenceToJson(MonthlyAttendence data) => json.encode(data.toJson());

class MonthlyAttendence {
  int? status;
  int? employeeId;
  int? month;
  int? year;
  List<Attendance>? attendance;

  MonthlyAttendence({this.status, this.employeeId, this.month, this.year, this.attendance});

  factory MonthlyAttendence.fromJson(Map<String, dynamic> json) => MonthlyAttendence(
    status: json["status"],
    employeeId: json["employee_id"],
    month: json["month"],
    year: json["year"],
    attendance: json["attendance"] == null ? [] : List<Attendance>.from(json["attendance"]!.map((x) => Attendance.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "employee_id": employeeId,
    "month": month,
    "year": year,
    "attendance": attendance == null ? [] : List<dynamic>.from(attendance!.map((x) => x.toJson())),
  };
}

class Attendance {
  DateTime? checkIn;
  DateTime? checkOut;
  String? workedHours;

  Attendance({this.checkIn, this.checkOut, this.workedHours});

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    checkIn: json["check_in"] == null ? null : DateTime.parse(json["check_in"]),

    checkOut: json["check_out"] == null ? null : DateTime.parse(json["check_out"]),
    workedHours: json["worked_hours"],
  );

  Map<String, dynamic> toJson() => {"check_in": checkIn?.toIso8601String(), "check_out": checkOut?.toIso8601String()};
}
