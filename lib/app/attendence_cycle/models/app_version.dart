// To parse this JSON data, do
//
//     final appVersion = appVersionFromJson(jsonString);

import 'dart:convert';

AppVersion appVersionFromJson(String str) => AppVersion.fromJson(json.decode(str));

String appVersionToJson(AppVersion data) => json.encode(data.toJson());

class AppVersion {
  int? versionCode;
  String? versionName;
  String? apkUrl;
  bool? forceUpdate;

  AppVersion({this.versionCode, this.versionName, this.apkUrl, this.forceUpdate});

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    versionCode: json["versionCode"],
    versionName: json["versionName"],
    apkUrl: json["apkUrl"],
    forceUpdate: json["forceUpdate"],
  );

  Map<String, dynamic> toJson() => {
    "versionCode": versionCode,
    "versionName": versionName,
    "apkUrl": apkUrl,
    "forceUpdate": forceUpdate,
  };
}
