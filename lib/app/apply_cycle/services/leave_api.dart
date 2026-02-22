import 'package:contaqa/app/apply_cycle/models/get_leave_type_model.dart';
import 'package:contaqa/app/apply_cycle/models/remaining_leave_model.dart';
import 'package:contaqa/services/dio_client.dart';

class LeaveApi {
  // make singleton code
  LeaveApi._privateConstructor();

  static final LeaveApi _instance = LeaveApi._privateConstructor();

  factory LeaveApi() {
    return _instance;
  }

  Future<GetLeaveTypeModel?> getLeaveType() async {
    String url = 'http://65.109.226.255:11000/get_hr_leave_type';

    try {
      final response = await Client.client.get(url);

      if (response.statusCode == 200) {
        GetLeaveTypeModel getLeaveTypeModel = GetLeaveTypeModel.fromJson(
          response.data,
        );

        print(response.data.toString());

        return getLeaveTypeModel;
      } else {
        return null;
      }
    } catch (e) {
      throw 'GetLeaveType error >> $e';
    }
  }

  Future<RemainingLeaveModel?> getRemainingLeave({
    required int employeeId,
    required int leaveTypeId,
  }) async {
    String url =
        'http://65.109.226.255:11000/get_remaining_leave/$employeeId/$leaveTypeId';

    try {
      final response = await Client.client.get(url);

      if (response.statusCode == 200) {
        RemainingLeaveModel remainingLeaveModel = RemainingLeaveModel.fromJson(
          response.data,
        );

        print(response.data.toString());

        return remainingLeaveModel;
      } else {
        return null;
      }
    } catch (e) {
      throw 'GetRemainingLeave error >> $e';
    }
  }
}
