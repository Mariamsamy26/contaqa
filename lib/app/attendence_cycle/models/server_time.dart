// To parse this JSON data, do
//
//     final serverTime = serverTimeFromJson(jsonString);

import 'dart:convert';

ServerTime serverTimeFromJson(String str) => ServerTime.fromJson(json.decode(str));

String serverTimeToJson(ServerTime data) => json.encode(data.toJson());

class ServerTime {
  DateTime? date;
  String? time;

  ServerTime({this.date, this.time});

  factory ServerTime.fromJson(Map<String, dynamic> json) =>
      ServerTime(date: json["date"] == null ? null : DateTime.parse(json["date"]), time: json["time"]);

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
  };
}
