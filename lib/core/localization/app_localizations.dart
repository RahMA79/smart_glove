import 'package:flutter/material.dart';

/// Lightweight localization (no codegen) for this project.
///
/// Usage:
///   Text(context.tr('Home'))
///   Text(context.tr('Request sent to {doctor}', params: {'doctor': name}))
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(loc != null, 'AppLocalizations not found in context');
    return loc!;
  }

  static const supported = [Locale('en'), Locale('ar')];

  String tr(String key, {Map<String, String> params = const {}}) {
    final lang = locale.languageCode;
    final table = lang == 'ar' ? _ar : _en;
    var value = table[key] ?? key;
    params.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}

extension AppLocalizationsX on BuildContext {
  String tr(String key, {Map<String, String> params = const {}}) {
    return AppLocalizations.of(this).tr(key, params: params);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'ar';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

// NOTE: Keys are the existing English (or Arabic) strings found in the UI.
//       If a key is missing, we fallback to the key itself.

const Map<String, String> _en = {
  // General
  'Home': 'Home',
  'Settings': 'Settings',
  'Login': 'Login',
  'Sign up': 'Sign up',
  'Create Account': 'Create Account',
  'Creating...': 'Creating...',
  'Loading...': 'Loading...',
  'Logout': 'Logout',
  'Language': 'Language',
  'English': 'English',
  'Arabic': 'Arabic',
  'Cancel': 'Cancel',
  'Delete': 'Delete',
  'Save': 'Save',
  'Search': 'Search',
  'Skip': 'Skip',
  'Next': 'Next',
  'Get Started': 'Get Started',

  // Onboarding
  'Track Your Recovery Easily': 'Track Your Recovery Easily',
  'Monitor exercises with real-time progress.':
      'Monitor exercises with real-time progress.',
  'Smart AI-Based Insights': 'Smart AI-Based Insights',
  'AI analyzes activity and guides recovery.':
      'AI analyzes activity and guides recovery.',
  'Personalized Therapy Programs': 'Personalized Therapy Programs',
  'Custom programs based on your condition.':
      'Custom programs based on your condition.',

  // Auth
  'Email': 'Email',
  'Password': 'Password',
  'Age': 'Age',
  'Full Name': 'Full Name',
  'Enter your full name': 'Enter your full name',
  'Enter your email': 'Enter your email',
  'Enter your password': 'Enter your password',
  'Enter your age': 'Enter your age',
  "Don't have an account?": "Don't have an account?",
  'Already have an account?': 'Already have an account?',
  'Register error': 'Register error',
  'Email is required': 'Email is required',
  'Enter a valid email': 'Enter a valid email',
  'Password is required': 'Password is required',
  'Min 6 characters': 'Min 6 characters',
  'Name is required': 'Name is required',
  'Age is required': 'Age is required',
  'Enter a valid number': 'Enter a valid number',
  'Enter a valid age': 'Enter a valid age',
  'Age must be a valid number': 'Age must be a valid number',
  'Login failed': 'Login failed',
  'Login failed: user is null': 'Login failed: user is null',
  'Register failed: user is null': 'Register failed: user is null',
  'Unexpected error: {error}': 'Unexpected error: {error}',
  'Register successful as {role}': 'Register successful as {role}',
  'Upload Image': 'Upload Image',

  // Settings
  'Appearance': 'Appearance',
  'Dark Mode': 'Dark Mode',
  'Enable dark theme for the app': 'Enable dark theme for the app',
  'Notifications': 'Notifications',
  'Session reminders': 'Session reminders',
  'New patient requests': 'New patient requests',
  'Account': 'Account',

  // Patient
  'drawer_home': 'Home',
  'drawer_profile': 'Profile',
  'drawer_progress': 'Progress',
  'drawer_notifications': 'Notifications',
  'drawer_session_history': 'Session History',
  'drawer_settings': 'Settings',
  'drawer_logout': 'Logout',

  'Sessions': 'Sessions',
  'Request doctor': 'Request doctor',
  'Your Therapy Programs': 'Your Therapy Programs',
  'Could not open gallery: {error}': 'Could not open gallery: {error}',
  'Patient': 'Patient',

  // Doctor
  'Therapy Programs': 'Therapy Programs',
  'Create New Program': 'Create New Program',
  'Create Program': 'Create Program',
  'Assign Program': 'Assign Program',
  'Assign Therapy Program': 'Assign Therapy Program',
  'No programs yet.': 'No programs yet.',
  'No logged-in doctor. Please login again.':
      'No logged-in doctor. Please login again.',
  'New Patient Request': 'New Patient Request',
  'No new requests.': 'No new requests.',
  'Request accepted': 'Request accepted',
  'Request rejected': 'Request rejected',
  'Failed: {error}': 'Failed: {error}',
  'Accept': 'Accept',
  'Reject': 'Reject',
  'My Patients': 'My Patients',
  "create_program": "Create Program",
  "program_name": "Program Name",
  "enter_program_name": "Enter program name",
  "type_of_injury": "Type of Injury",
  "session_settings": "Session Settings",
  "session_duration": "Session Duration",
  "minutes_unit": "min",
  "finger_angles_and_assistance": "Finger Angles & Assistance",
  "target_finger_flexion": "Target Finger Flexion",
  "degree_unit": "°",
  "motor_assistance_level": "Motor Assistance Level",
  "emg_threshold": "EMG Threshold",
  "emg_activation_threshold": "EMG Activation Threshold",
  "saving": "Saving...",

  // Request doctor screen
  'Select Doctor': 'Select Doctor',
  'Enter doctor name': 'Enter doctor name',
  'Please select a doctor': 'Please select a doctor',
  'Send Request': 'Send Request',
  'Request sent to {doctor}': 'Request sent to {doctor}',
  'No doctors found.': 'No doctors found.',
  'Request already sent.': 'Request already sent.',

  // Misc / UI
  'Add': 'Add',
  'Inbox': 'Inbox',
  'Mark all': 'Mark all',
  'All': 'All',
  'Unread': 'Unread',
  'notifications': 'Notifications',
  'No notifications': 'No notifications',
  "You're all caught up.": "You're all caught up.",
  'John Smith requested to join your care program.':
      'John Smith requested to join your care program.',
  'Report Ready': 'Report Ready',
  'Emily Wilson session report is ready to download.':
      'Emily Wilson session report is ready to download.',
  'Session Completed': 'Session Completed',
  'Mark Smith completed today’s therapy session.':
      'Mark Smith completed today’s therapy session.',

  // Sessions / Programs
  'Session': 'Session',
  'Start Session': 'Start Session',
  '{count} min': '{count} min',
  '{count} sessions / week': '{count} sessions / week',
  'Burn Rehab': 'Burn Rehab',
  'Nerve Therapy': 'Nerve Therapy',
  'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.':
      'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.',
  'Session In Progress': 'Session In Progress',
  'Keep going until the timer ends.': 'Keep going until the timer ends.',
  'Remaining': 'Remaining',
  'Total': 'Total',
  'Stop': 'Stop',
  'Feedback': 'Feedback',
  'How would you rate your pain?': 'How would you rate your pain?',
  'How easy was the session?': 'How easy was the session?',
  'Submit': 'Submit',
  'Feedback submitted': 'Feedback submitted',
  'Patient Report': 'Patient Report',
  'Excel Patients': 'Excel Patients',
  'session Accuracy': 'session Accuracy',
  'progress rate': 'progress rate',
  'patient Level': 'patient Level',
  'Downloading...': 'Downloading...',
  'Download Report': 'Download Report',
  'Duration': 'Duration',
  'Exercises Done': 'Exercises Done',
  'Pain Level': 'Pain Level',

  // Added for full app localization
  'glove_control_emg': 'Glove Control & EMG',
  'servo_control': 'Servo Control',
  'emg_rms': 'RMS',
  'emg_mav': 'MAV',
  'emg_variance': 'Variance',
  'emg_zero_cross': 'ZeroCross',
  'emg_peak': 'Peak',
  'no_logged_in_doctor': 'No logged-in doctor. Please login again.',
  'error_with_details': 'Error: {error}',
  'finger_angles_assistance': 'Finger Angles & Assistance',
  'new_patient_request': 'New Patient Request',
  'patient_join_request_demo':
      'John Smith requested to join your care program.',
  'report_ready': 'Report Ready',
  'session_report_ready_demo':
      'Emily Wilson session report is ready to download.',
  'session_completed': 'Session Completed',
  'therapy_session_completed_demo':
      'Mark Smith completed today’s therapy session.',
  'notification': 'Notifications',
  'mark_all': 'Mark all',
  'no_notifications': 'No notifications',
  'caught_up': 'You’re all caught up.',
  'skip': 'Skip',
  'language': 'Language',
  'get_started': 'Get Started',
  'next': 'Next',
  'finger_thumb': 'Ebham',
  'finger_index': 'Sababa',
  'finger_middle': 'Wosta',
  'finger_ring': 'Bensr',
  'finger_pinky': 'Khansr',
  'no_programs_yet': 'No programs yet.',

  // Added for full app localization
  'failed_to_assign': 'Failed to assign: {error}',
  'glove_data': 'Glove Data',
  'emg_avg': 'EMG Avg',
  'emg_peak_label': 'EMG Peak',
  'assign_program': 'Assign Program',
  'select_program': 'Select a program',
  'create_new': 'Create New',
  'program_created_selected': 'Program created and selected',
  'program_assigned_successfully': 'Program assigned successfully',
  'injury_stroke': 'Stroke',
  'injury_tendon_repair': 'Tendon Repair',
  'injury_fracture': 'Fracture',
  'injury_other': 'Other',
  'sensor_screen': 'sensor screen',

  // Added for full app localization
  'finger_thumb_servo': 'Thumb Servo',
  'finger_index_servo': 'Index Servo',
  'finger_middle_servo': 'Middle Servo',
  'finger_ring_servo': 'Ring Servo',
  'finger_pinky_servo': 'Pinky Servo',
  'injury_burn': 'Burn',
  'injury_nerve_injury': 'Nerve Injury',
  'please_enter_program_name': 'Please enter program name',
  'no_logged_in_doctor_short': 'No logged-in doctor.',
  'failed_to_create_program': 'Failed to create program: {error}',
  'program_settings_saved': 'Program settings saved',
  'failed_to_save': 'Failed to save: {error}',
  'my_patients': 'My Patients',

  // Added for full app localization
  'delete_program': 'Delete Program',
  'delete_program_confirm':
      "Are you sure you want to permanently delete this program? This action cannot be undone.",
  'cancel': 'Cancel',
  'delete': 'Delete',
  'program_deleted': 'Program deleted',
  'failed_to_delete': 'Failed to delete: {error}',
  'hand_rehab_specialist': 'Hand Rehabilitation Specialist',
  'patient_notifications': 'Patient Notifications',

  // Added for full app localization
  'patients_count': '{count} patients',
  'chart_placeholder': 'Chart Placeholder',
  'patient_report': 'Patient Report',
  'excel_patients': 'Excellent Exercises',
  'session_accuracy': 'Session Accuracy',
  'progress_rate': 'Progress Rate',
  'patient_level': 'Patient Level',
  'downloading': 'Downloading...',
  'duration': 'Duration',
  'exercises_done': 'Exercises Done',
  'pain_level': 'Pain Level',
  'onboarding_title_1': 'Track Your Recovery Easily',
  'onboarding_subtitle_1': 'Monitor exercises with real-time progress.',
  'onboarding_title_2': 'Smart AI-Based Insights',
  'onboarding_subtitle_2': 'AI analyzes activity and guides recovery.',
  'onboarding_title_3': 'Personalized Therapy Programs',
  'onboarding_subtitle_3': 'Custom programs based on your condition.',
  "assigning": "Assigning...",
  "assign_program_button": "Assign Program",
  "selected_program_not_found":
      "Selected program not found. Please refresh and select an existing program.",
  "save_changes": "Save Changes",
};
const Map<String, String> _ar = {
  // General
  'Home': 'الرئيسية',
  'Settings': 'الإعدادات',
  'Login': 'تسجيل الدخول',
  'Sign up': 'إنشاء حساب',
  'Create Account': 'إنشاء حساب',
  'Creating...': 'جاري الإنشاء...',
  'Loading...': 'جاري التحميل...',
  'Logout': 'تسجيل الخروج',
  'Language': 'اللغة',
  'English': 'الإنجليزية',
  'Arabic': 'العربية',
  'Cancel': 'إلغاء',
  'Delete': 'حذف',
  'Save': 'حفظ',
  'Search': 'بحث',
  'Skip': 'تخطي',
  'Next': 'التالي',
  'Get Started': 'ابدأ',
  'patient_report': 'تقرير المريض',
  'excel_patients': 'التمارين الممتازة',
  'session_accuracy': 'دقة الجلسة',
  'progress_rate': 'معدل التقدم',
  'patient_level': 'مستوى المريض',
  'downloading': 'جاري التحميل...',

  // Onboarding
  'Track Your Recovery Easily': 'تابعي تعافيك بسهولة',
  'Monitor exercises with real-time progress.': 'راقبي التمارين مع تقدم لحظي.',
  'Smart AI-Based Insights': 'تحليلات ذكية بالذكاء الاصطناعي',
  'AI analyzes activity and guides recovery.':
      'الذكاء الاصطناعي يحلل النشاط ويوجه التعافي.',
  'Personalized Therapy Programs': 'برامج علاج مخصصة',
  'Custom programs based on your condition.': 'برامج مخصصة حسب حالتك.',

  // Auth
  'Email': 'البريد الإلكتروني',
  'Password': 'كلمة المرور',
  'Age': 'العمر',
  'Full Name': 'الاسم بالكامل',
  'Enter your full name': 'اكتب اسمك بالكامل',
  'Enter your email': 'اكتب بريدك الإلكتروني',
  'Enter your password': 'اكتب كلمة المرور',
  'Enter your age': 'اكتب عمرك',
  "Don't have an account?": 'ليس لديك حساب؟',
  'Already have an account?': 'لديك حساب بالفعل؟',
  'Register error': 'خطأ أثناء إنشاء الحساب',
  'Email is required': 'البريد الإلكتروني مطلوب',
  'Enter a valid email': 'اكتب بريد إلكتروني صحيح',
  'Password is required': 'كلمة المرور مطلوبة',
  'Min 6 characters': 'الحد الأدنى 6 حروف',
  'Name is required': 'الاسم مطلوب',
  'Age is required': 'العمر مطلوب',
  'Enter a valid number': 'اكتب رقم صحيح',
  'Enter a valid age': 'اكتب عمر صحيح',
  'Age must be a valid number': 'العمر لازم يكون رقم صحيح',
  'Login failed': 'فشل تسجيل الدخول',
  'Login failed: user is null': 'فشل تسجيل الدخول',
  'Register failed: user is null': 'فشل إنشاء الحساب',
  'Unexpected error: {error}': 'خطأ غير متوقع: {error}',
  'Register successful as {role}': 'تم إنشاء الحساب بنجاح كـ {role}',
  'Upload Image': 'رفع صورة',

  // Settings
  'Appearance': 'المظهر',
  'Dark Mode': 'الوضع الليلي',
  'Enable dark theme for the app': 'تفعيل الوضع الليلي للتطبيق',
  'Notifications': 'الإشعارات',
  'Session reminders': 'تذكير الجلسات',
  'New patient requests': 'طلبات مرضى جديدة',
  'Account': 'الحساب',

  // Patient
  'drawer_home': 'الرئيسية',
  'drawer_profile': 'الملف الشخصي',
  'drawer_progress': 'التقدم',
  'drawer_notifications': 'الإشعارات',
  'drawer_session_history': 'سجل الجلسات',
  'drawer_settings': 'الإعدادات',
  'drawer_logout': 'تسجيل الخروج',
  'Sessions': 'الجلسات',
  'Request doctor': 'طلب طبيب',
  'Your Therapy Programs': 'برامج العلاج الخاصة بك',
  'Could not open gallery: {error}': 'تعذّر فتح المعرض: {error}',
  'Patient': 'مريض',

  // Doctor
  'Therapy Programs': 'برامج العلاج',
  'Create New Program': 'إنشاء برنامج جديد',
  'Create Program': 'إنشاء برنامج',
  'Assign Program': 'إسناد برنامج',
  'Assign Therapy Program': 'إسناد برنامج علاجي',
  'No programs yet.': 'لا يوجد برامج حتى الآن.',
  'No logged-in doctor. Please login again.':
      'لا يوجد طبيب مسجل الدخول. من فضلك سجّل الدخول مرة أخرى.',
  'New Patient Request': 'طلبات مرضى جديدة',
  'No new requests.': 'لا يوجد طلبات جديدة.',
  'Request accepted': 'تم قبول الطلب',
  'Request rejected': 'تم رفض الطلب',
  'Failed: {error}': 'فشل: {error}',
  'Accept': 'قبول',
  'Reject': 'رفض',
  'My Patients': 'مرضاي',
  "create_program": "إنشاء برنامج",
  "program_name": "اسم البرنامج",
  "enter_program_name": "أدخل اسم البرنامج",
  "type_of_injury": "نوع الإصابة",
  "session_settings": "إعدادات الجلسة",
  "session_duration": "مدة الجلسة",
  "minutes_unit": "دقيقة",
  "finger_angles_and_assistance": "زوايا الأصابع والمساعدة",
  "target_finger_flexion": "زاوية ثني الأصابع المستهدفة",
  "degree_unit": "°",
  "motor_assistance_level": "مستوى المساعدة الحركية",
  "emg_threshold": "حد EMG",
  "emg_activation_threshold": "حد تنشيط EMG",
  "saving": "جارٍ الحفظ...",

  // Request doctor screen
  'Select Doctor': 'اختيار الطبيب',
  'Enter doctor name': 'اكتب اسم الطبيب',
  'Please select a doctor': 'من فضلك اختاري طبيب',
  'Send Request': 'إرسال الطلب',
  'Request sent to {doctor}': 'تم إرسال الطلب إلى {doctor}',
  'No doctors found.': 'لا يوجد أطباء.',
  'Request already sent.': 'تم إرسال طلب بالفعل.',

  // Misc / UI
  'Add': 'إضافة',
  'Inbox': 'الوارد',
  'Mark all': 'تحديد الكل',
  'All': 'الكل',
  'Unread': 'غير مقروء',
  'notifications': 'الإشعارات',
  'No notifications': 'لا توجد إشعارات',
  "You're all caught up.": 'لا يوجد جديد حاليًا.',
  'John Smith requested to join your care program.':
      'طلب جون سميث الانضمام لبرنامج الرعاية الخاص بك.',
  'Report Ready': 'التقرير جاهز',
  'Emily Wilson session report is ready to download.':
      'تقرير جلسة إيميلي ويلسون جاهز للتحميل.',
  'Session Completed': 'اكتملت الجلسة',
  'Mark Smith completed today’s therapy session.':
      'أنهى مارك سميث جلسة العلاج اليوم.',

  // Sessions / Programs
  'Session': 'جلسة',
  'Start Session': 'ابدأ الجلسة',
  '{count} min': '{count} دقيقة',
  '{count} sessions / week': '{count} جلسات / أسبوع',
  'Burn Rehab': 'تأهيل الحروق',
  'Nerve Therapy': 'علاج الأعصاب',
  'Designed to improve hand mobility by stimulating the flexor and extensor muscles.\nHelps restore nerve function and enhance activation.':
      'مصممة لتحسين حركة اليد من خلال تحفيز عضلات الثني والبسط.\nتساعد على استعادة وظيفة الأعصاب وتحسين الاستجابة.',
  'Session In Progress': 'الجلسة قيد التنفيذ',
  'Keep going until the timer ends.': 'استمر حتى ينتهي المؤقت.',
  'Remaining': 'المتبقي',
  'Total': 'الإجمالي',
  'Stop': 'إيقاف',
  'Feedback': 'التقييم',
  'How would you rate your pain?': 'كيف تقيّم مستوى الألم؟',
  'How easy was the session?': 'ما مدى سهولة الجلسة؟',
  'Submit': 'إرسال',
  'Feedback submitted': 'تم إرسال التقييم',
  'Patient Report': 'تقرير المريض',
  'Excel Patients': 'مرضى إكسل',
  'session Accuracy': 'دقة الجلسة',
  'progress rate': 'معدل التقدم',
  'patient Level': 'مستوى المريض',
  'Downloading...': 'جاري التحميل...',
  'Download Report': 'تحميل التقرير',
  'Duration': 'المدة',
  'Exercises Done': 'التمارين المنجزة',
  'Pain Level': 'مستوى الألم',

  // Added for full app localization
  'glove_control_emg': 'التحكم في القفاز و EMG',
  'servo_control': 'التحكم في السيرفو',
  'emg_rms': 'RMS',
  'emg_mav': 'MAV',
  'emg_variance': 'التباين',
  'emg_zero_cross': 'العبور الصفري',
  'emg_peak': 'القمة',
  'no_logged_in_doctor':
      'لا يوجد طبيب مسجّل دخول. برجاء تسجيل الدخول مرة أخرى.',
  'error_with_details': 'خطأ: {error}',
  'finger_angles_assistance': 'زوايا الأصابع والمساعدة',
  'new_patient_request': 'طلب مريض جديد',
  'patient_join_request_demo': 'طلب جون سميث الانضمام لبرنامج رعايتك.',
  'report_ready': 'التقرير جاهز',
  'session_report_ready_demo': 'تقرير جلسة إيميلي ويلسون جاهز للتحميل.',
  'session_completed': 'تمت الجلسة',
  'therapy_session_completed_demo': 'أنهى مارك سميث جلسة العلاج اليوم.',
  'notification': 'الإشعارات',
  'mark_all': 'تحديد الكل كمقروء',
  'no_notifications': 'لا توجد إشعارات',
  'caught_up': 'لا يوجد جديد حاليًا.',
  'skip': 'تخطي',
  'language': 'اللغة',
  'get_started': 'ابدأ الآن',
  'next': 'التالي',
  'finger_thumb': 'إبهام',
  'finger_index': 'سبابة',
  'finger_middle': 'وسطى',
  'finger_ring': 'بنصر',
  'finger_pinky': 'خنصر',
  'no_programs_yet': 'لا توجد برامج بعد.',

  // Added for full app localization
  'failed_to_assign': 'فشل التعيين: {error}',
  'glove_data': 'بيانات القفاز',
  'emg_avg': 'متوسط EMG',
  'emg_peak_label': 'قمة EMG',
  'assign_program': 'تعيين برنامج',
  'select_program': 'اختر برنامجًا',
  'create_new': 'إنشاء جديد',
  'program_created_selected': 'تم إنشاء البرنامج واختياره',
  'program_assigned_successfully': 'تم تعيين البرنامج بنجاح',
  'injury_stroke': 'سكتة دماغية',
  'injury_tendon_repair': 'إصلاح الأوتار',
  'injury_fracture': 'كسر',
  'injury_other': 'أخرى',
  'sensor_screen': 'شاشة المستشعرات',

  // Added for full app localization
  'finger_thumb_servo': 'سيرفو الإبهام',
  'finger_index_servo': 'سيرفو السبابة',
  'finger_middle_servo': 'سيرفو الوسطى',
  'finger_ring_servo': 'سيرفو البنصر',
  'finger_pinky_servo': 'سيرفو الخنصر',
  'injury_burn': 'حروق',
  'injury_nerve_injury': 'إصابة أعصاب',
  'please_enter_program_name': 'من فضلك أدخل اسم البرنامج',
  'no_logged_in_doctor_short': 'لا يوجد طبيب مسجّل دخول.',
  'failed_to_create_program': 'فشل إنشاء البرنامج: {error}',
  'program_settings_saved': 'تم حفظ إعدادات البرنامج',
  'failed_to_save': 'فشل الحفظ: {error}',
  'my_patients': 'مرضاي',

  // Added for full app localization
  'delete_program': 'حذف البرنامج',
  'delete_program_confirm':
      'هل أنت متأكد أنك تريد حذف هذا البرنامج نهائيًا؟ لا يمكن التراجع عن هذا الإجراء.',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'program_deleted': 'تم حذف البرنامج',
  'failed_to_delete': 'فشل الحذف: {error}',
  'hand_rehab_specialist': 'أخصائي تأهيل اليد',
  'patient_notifications': 'إشعارات المريض',

  // Added for full app localization
  'patients_count': 'عدد المرضى: {count}',
  'chart_placeholder': 'مكان الرسم البياني',
  'duration': 'المدة',
  'exercises_done': 'التمارين المنجزة',
  'pain_level': 'مستوى الألم',
  'onboarding_title_1': 'تابع تعافيك بسهولة',
  'onboarding_subtitle_1': 'راقب التمارين وتقدّمك لحظة بلحظة.',
  'onboarding_title_2': 'تحليلات ذكية بالذكاء الاصطناعي',
  'onboarding_subtitle_2': 'يحلل الذكاء الاصطناعي نشاطك ويوجّهك للتعافي.',
  'onboarding_title_3': 'برامج علاج مخصصة',
  'onboarding_subtitle_3': 'برامج تناسب حالتك وخطّة علاجك.',
  "assigning": "جارٍ التعيين...",
  "assign_program_button": "تعيين البرنامج",
  "selected_program_not_found":
      "البرنامج المحدد غير موجود. يرجى تحديث الصفحة واختيار برنامج موجود.",
  "save_changes": "حفظ التغييرات",
};
