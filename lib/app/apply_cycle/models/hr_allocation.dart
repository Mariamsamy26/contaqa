class HrAllocation {
  final int holidayStatusId;
  final String holidayStatusName;
  final double numberOfDays;
  final String state;

  HrAllocation({
    required this.holidayStatusId,
    required this.holidayStatusName,
    required this.numberOfDays,
    required this.state,
  });

  factory HrAllocation.fromJson(Map<String, dynamic> json) {
    final statusIdList = json['holiday_status_id'] is List
        ? (json['holiday_status_id'] as List)
        : [];

    return HrAllocation(
      holidayStatusId: statusIdList.isNotEmpty ? statusIdList.first : 0,
      holidayStatusName: statusIdList.length > 1 ? statusIdList[1] : 'Unknown',
      numberOfDays: (json['number_of_days'] is num)
          ? (json['number_of_days'] as num).toDouble()
          : 0.0,
      state: (json['state'] is String) ? json['state'] : '',
    );
  }
}
