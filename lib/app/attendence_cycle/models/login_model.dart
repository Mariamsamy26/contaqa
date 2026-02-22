// To parse this JSON data, do
//
//     final login = loginFromJson(jsonString);

import 'dart:convert';

Login loginFromJson(String str) => Login.fromJson(json.decode(str));

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
  int? status;
  String? message;
  int? contactId;
  int? employeeId;

  Login({this.status, this.message, this.contactId, this.employeeId});

  factory Login.fromJson(Map<String, dynamic> json) =>
      Login(status: json["status"], message: json["message"], contactId: json["contact_id"], employeeId: json["employee_id"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message, "contact_id": contactId, "employee_id": employeeId};
}
