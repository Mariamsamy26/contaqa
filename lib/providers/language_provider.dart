import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
  }

  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'Contaqa HR',
      'company_attendance': 'Company Attendance',
      'from_home_attendance': 'From Home Attendance',
      'email': 'Email',
      'time_sheet': 'Time Sheet',
      'leave_requests': 'Leave Requests',
      'request_time_off': 'Request Time Off',
      'logout': 'Logout',
      'check_in_completed': 'Check IN is Completed',
      'check_out_completed': 'Check OUT is Completed',
      'view_time_sheet': 'View Time \nSheet',
      'check_location': 'Check Location',
      'Approved': 'Approved',
      'Waiting': 'Waiting',
      'Refuse': 'Refuse',
      'Draft': 'Draft',
      'payslip': 'Payslip',
      'meeting': 'Meeting',
      'check_in': 'Check In',
      'check_out': 'Check Out',
      'date': 'Date',
      'in': 'IN',
      'out': 'OUT',
      'hours': 'Hours',
      'total_working_days': 'Total Working Days:',
      'total_over_under_time': 'Total Over/Under Time:',
      'days': 'days',
      'min': 'min',
      'enter_email': 'Please enter an email address',
      'valid_email': 'Please enter a valid email address',
      'password_required': 'Password is required',
      'password': 'Password',
      'login': 'Login',
      'error_no_employee_id': 'Error: No Employee ID returned',
      'check_credentials': 'Please Check your Credentials',
      'login_failed': 'Login Failed: No Response',
      'soon': 'SOON',
      'no_leaves_found': 'No leaves found',
      'from': 'From',
      'to': 'To',
      'type': 'Type',
      'leave_type': 'Leave Type',
      'date_range': 'Date Range',
      'description': 'Description',
      'retry': 'Retry',
      'leave_note':
          'NOTE: In case of delay of rejoining from vacation without valid and approved reasons, the management reserves the right to take disciplinary actions as mandated by labor law.',
      'select_leave_type_error': 'Please select a leave type first!',
      'select_date_range_error': 'Please select date range!',
      'employee_id_error': 'Employee ID not found. Please log in again.',
      'sick_leave_attachment_error': 'Please attach a document for Sick Leave!',
      'leave_submitted_success': 'Leave application submitted successfully!',
      'online': "You're online!",
      'offline': "No internet connection",
      'enter_description_for_your_leave': 'Enter description for your leave',
      'loading_leave_types': 'Loading leave types...',
      'select_leave_type': 'Select Leave Type',
      'paid_time_off_balance': 'Paid Time Off Balance:',
      'from_date': 'From Date',
      'to_date': 'To Date',
      'attachment': 'Attachment',
      'submit': 'Submit',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'supporting_document': 'Supporting Document',
    },
    'ar': {
      'app_title': 'Contaqa HR',
      'company_attendance': 'حضور الشركة',
      'from_home_attendance': 'حضور من المنزل',
      'email': 'البريد الإلكتروني',
      'time_sheet': 'جدول الحضور',
      'leave_requests': 'طلبات الإجازة',
      'request_time_off': 'طلب اجازه',
      'logout': 'تسجيل الخروج',
      'check_in_completed': 'تم تسجيل الحضور بنجاح',
      'check_out_completed': 'تم تسجيل الانصراف بنجاح',
      'view_time_sheet': 'عرض جدول \nالمواعيد',
      'check_location': 'تحقق من الموقع',
      'Approved': 'تم القبول',
      'Waiting': 'جاري المراجعه',
      'Refuse': 'تم الرفض',
      'Draft': 'مسودة',
      'payslip': 'تفاصيل الراتب',
      'meeting': "اجتماع",
      'check_in': 'تسجيل الحضور',
      'check_out': 'تسجيل الانصراف',
      'date': 'التاريخ',
      'in': 'دخول',
      'out': 'خروج',
      'hours': 'ساعات',
      'total_working_days': 'مجموع أيام العمل:',
      'total_over_under_time': 'إجمالي الوقت الإضافي/الناقص:',
      'days': 'أيام',
      'min': 'دقيقة',
      'enter_email': 'يرجى إدخال البريد الإلكتروني',
      'valid_email': 'يرجى إدخال بريد إلكتروني صالح',
      'password_required': 'كلمة المرور مطلوبة',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'error_no_employee_id': 'خطأ: لم يتم إرجاع معرف الموظف',
      'check_credentials': 'يرجى التحقق من بيانات الاعتماد الخاصة بك',
      'login_failed': 'فشل تسجيل الدخول: لايوجد استجابة',
      'soon': 'قريباً',
      'no_leaves_found': 'لا توجد إجازات',
      'from': 'من',
      'to': 'إلى',
      'type': 'النوع',
      'leave_type': 'نوع الإجازة',
      'date_range': 'الفترة الزمنية',
      'description': 'الوصف',
      'retry': 'إعادة المحاولة',
      'leave_note':
          'ملاحظة: في حالة التأخر عن العودة من الإجازة بدون أسباب مقبولة وموافق عليها، تحتفظ الإدارة بالحق في اتخاذ إجراءات تأديبية وفقًا لقانون العمل.',
      'select_leave_type_error': 'يرجى اختيار نوع الإجازة أولاً!',
      'select_date_range_error': 'يرجى اختيار الفترة الزمنية!',
      'employee_id_error': 'لم يتم العثور على معرف الموظف. يرجى تسجيل الدخول مرة أخرى.',
      'sick_leave_attachment_error': 'يرجى إرفاق مستند للإجازة المرضية!',
      'leave_submitted_success': 'تم تقديم طلب الإجازة بنجاح!',
      'online': "أنت متصل بالإنترنت!",
      'offline': "لا يوجد اتصال بالإنترنت",
      'enter_description_for_your_leave': 'أدخل وصفًا لإجازتك',
      'loading_leave_types': 'جاري تحميل أنواع الإجازات...',
      'select_leave_type': 'اختر نوع الإجازة',
      'paid_time_off_balance': 'رصيد الإجازات المدفوعة:',
      'from_date': 'من تاريخ',
      'to_date': 'إلى تاريخ',
      'attachment': 'المرفق',
      'submit': 'إرسال',
      'camera': 'كاميرا',
      'gallery': 'معرض الصور',
      'supporting_document': 'مستند دعم',
    },
  };
}
