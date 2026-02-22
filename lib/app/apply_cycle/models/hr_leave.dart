class HrLeave {
  final int? id;
  final int? employeeId;
  final int holidayStatusId;
  final String holidayStatusName;
  final String name;
  final DateTime requestDateFrom;
  final DateTime requestDateTo;
  final double numberOfDays;
  final String state;

  HrLeave({
    this.id,
    this.employeeId,
    required this.holidayStatusId,
    required this.holidayStatusName,
    required this.name,
    required this.requestDateFrom,
    required this.requestDateTo,
    required this.numberOfDays,
    required this.state,
  });

  factory HrLeave.fromJson(Map<String, dynamic> json) {
    final statusIdList = json['holiday_status_id'] is List
        ? (json['holiday_status_id'] as List)
        : [];

    return HrLeave(
      id: json['id'],
      employeeId: json['employee_id'] is List
          ? (json['employee_id'] as List).first
          : json['employee_id'],
      holidayStatusId: statusIdList.isNotEmpty ? statusIdList.first : 0,
      holidayStatusName: statusIdList.length > 1 ? statusIdList[1] : 'Unknown',
      name: (json['name'] is String) ? json['name'] : '',
      requestDateFrom: (json['request_date_from'] is String)
          ? DateTime.parse(json['request_date_from'])
          : DateTime.now(),
      requestDateTo: (json['request_date_to'] is String)
          ? DateTime.parse(json['request_date_to'])
          : DateTime.now(),
      numberOfDays: (json['number_of_days'] is num)
          ? (json['number_of_days'] as num).toDouble()
          : 0.0,
      state: (json['state'] is String) ? json['state'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'holiday_status_id': holidayStatusId,
      'name': name,
      'request_date_from': requestDateFrom.toIso8601String().split('T').first,
      'request_date_to': requestDateTo.toIso8601String().split('T').first,
      'date_from':
          "${requestDateFrom.toIso8601String().split('T').first} 07:00:00",
      'date_to': "${requestDateTo.toIso8601String().split('T').first} 17:00:00",
      'holiday_type': 'employee',
    };

    if (employeeId != null) {
      data['employee_id'] = employeeId;
    }

    return data;
  }
}
