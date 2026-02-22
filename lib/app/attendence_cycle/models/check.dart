// To parse this JSON data, do
//
//     final check = checkFromJson(jsonString);

import 'dart:convert';

Check checkFromJson(String str) => Check.fromJson(json.decode(str));

String checkToJson(Check data) => json.encode(data.toJson());

class Check {
  int? status;
  String? message;

  Check({this.status, this.message});

  factory Check.fromJson(Map<String, dynamic> json) => Check(status: json["status"], message: json["message"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}
