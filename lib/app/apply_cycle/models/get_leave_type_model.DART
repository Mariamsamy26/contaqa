// To parse this JSON data, do
//
//     final getLeaveTypeModel = getLeaveTypeModelFromJson(jsonString);

import 'dart:convert';

GetLeaveTypeModel getLeaveTypeModelFromJson(String str) => GetLeaveTypeModel.fromJson(json.decode(str));

String getLeaveTypeModelToJson(GetLeaveTypeModel data) => json.encode(data.toJson());

class GetLeaveTypeModel {
    List<Record>? records;

    GetLeaveTypeModel({
        this.records,
    });

    factory GetLeaveTypeModel.fromJson(Map<String, dynamic> json) => GetLeaveTypeModel(
        records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toJson())),
    };
}

class Record {
    int? id;
    String? displayName;

    Record({
        this.id,
        this.displayName,
    });

    factory Record.fromJson(Map<String, dynamic> json) => Record(
        id: json["id"],
        displayName: json["display_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "display_name": displayName,
    };
}
