// To parse this JSON data, do
//
//     final remainingLeaveModel = remainingLeaveModelFromJson(jsonString);

import 'dart:convert';

RemainingLeaveModel remainingLeaveModelFromJson(String str) =>
    RemainingLeaveModel.fromJson(json.decode(str));

String remainingLeaveModelToJson(RemainingLeaveModel data) =>
    json.encode(data.toJson());

class RemainingLeaveModel {
  int? status;
  int? employeeId;
  int? leaveTypeId;
  String? leaveType;
  String? unit;
  String? requiresAllocation;
  bool? unpaid;
  double? max;
  double? taken;
  double? remaining;

  RemainingLeaveModel({
    this.status,
    this.employeeId,
    this.leaveTypeId,
    this.leaveType,
    this.unit,
    this.requiresAllocation,
    this.unpaid,
    this.max,
    this.taken,
    this.remaining,
  });

  factory RemainingLeaveModel.fromJson(Map<String, dynamic> json) =>
      RemainingLeaveModel(
        status: json["status"],
        employeeId: json["employee_id"],
        leaveTypeId: json["leave_type_id"],
        leaveType: json["leave_type"],
        unit: json["unit"],
        requiresAllocation: json["requires_allocation"],
        unpaid: json["unpaid"],
        max: json["max"],
        taken: json["taken"],
        remaining: json["remaining"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "employee_id": employeeId,
    "leave_type_id": leaveTypeId,
    "leave_type": leaveType,
    "unit": unit,
    "requires_allocation": requiresAllocation,
    "unpaid": unpaid,
    "max": max,
    "taken": taken,
    "remaining": remaining,
  };
}
