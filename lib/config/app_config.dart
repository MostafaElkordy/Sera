/// AppConfig: مركز إعدادات التطبيق الثابتة
/// يحتوي على معايير التكوين الأساسية، أرقام الطوارئ، وإعدادات SOS

class AppConfig {
  /// معلومات التطبيق
  static const String appName = 'SERA';
  static const String appNameArabic = 'سيرا - تطبيق الطوارئ الذكي';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String packageName = 'com.salma.sera';
  static const String appDescription =
      'تطبيق ذكي للإسعافات الأولية والتعامل مع الكوارث';

  /// معايير SOS
  static const int sosLongPressDuration = 1500; // ملي ثانية
  static const int sosCountdownDuration = 15; // ثانية
  static const String sosAlertMessage = 'تم تفعيل الاستغاثة الذكية';
  static const String sosSuccessMessage = 'تم إرسال تنبيه الطوارئ بنجاح';
  static const String sosCancelMessage = 'تم إلغاء طلب الاستغاثة';

  /// جهات الطوارئ والاتصالات
  static const Map<String, String> emergencyContacts = {
    'ambulance': '997',
    'fire': '998',
    'police': '999',
    'civil_defense': '777',
  };

  static const Map<String, String> emergencyContactsNames = {
    'ambulance': 'الإسعاف',
    'fire': 'الدفاع المدني',
    'police': 'الشرطة',
    'civil_defense': 'الحماية المدنية',
  };

  /// إعدادات الموقع
  static const int locationTimeoutSeconds = 5;
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;

  /// إعدادات قاعدة البيانات
  static const String databaseName = 'sera.db';
  static const int databaseVersion = 1;
  static const String sosTableName = 'sos_alerts';
  static const String userProfileTableName = 'user_profile';

  /// إعدادات التخزين المحلي
  static const String navigationStackKey = 'navigation_stack';
  static const String selectedCaseKey = 'selected_case_id';
  static const String selectedDisasterKey = 'selected_disaster_id';
  static const String userProfileKey = 'user_profile';
  static const String sosHistoryKey = 'sos_history';
  static const String firstLaunchKey = 'first_launch';

  /// إعدادات التطبيق
  static const bool enableDebugLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  static const bool enableHapticFeedback = true;
  static const bool enableSoundEffects = true;

  /// الألوان والتصميم
  static const String primaryColor = '#FF0000'; // أحمر
  static const String darkBackgroundColor = '#1F2937'; // رمادي داكن
  static const String cardBackgroundColor = '#374151'; // رمادي متوسط
  static const String darkHeaderColor = '#111827'; // أسود داكن جداً

  /// المهلة الزمنية للعمليات
  static const Duration httpTimeout = Duration(seconds: 10);
  static const Duration navigationAnimationDuration =
      Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 120);

  /// حدود السجلات
  static const int maxSosHistoryRecords = 100;
  static const int maxLogRecords = 1000;
  static const int maxAnalyticsEvents = 500;

  /// رسائل التطبيق
  static const Map<String, String> messages = {
    'error_location': 'تعذر تحديد الموقع الحالي',
    'error_permission': 'تم رفض الأذونات المطلوبة',
    'error_database': 'خطأ في قاعدة البيانات',
    'error_network': 'لا يوجد اتصال بالإنترنت',
    'error_generic': 'حدث خطأ غير متوقع',
    'success_sos': 'تم إرسال تنبيه الطوارئ بنجاح',
    'success_saved': 'تم الحفظ بنجاح',
    'loading': 'جاري التحميل...',
    'retry': 'إعادة محاولة',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'ok': 'حسناً',
  };

  /// أنواع الأخطاء
  static const String errorTypeLocation = 'location_error';
  static const String errorTypePermission = 'permission_error';
  static const String errorTypeDatabase = 'database_error';
  static const String errorTypeNetwork = 'network_error';
  static const String errorTypeGeneric = 'generic_error';

  /// معرفات قنوات الإشعارات
  static const String notificationChannelSos = 'sos_alerts';
  static const String notificationChannelWarning = 'warnings';
  static const String notificationChannelInfo = 'information';

  /// حالات الإسعافات الأولية المتاحة
  static const List<String> firstAidCaseIds = [
    'cpr',
    'choking',
    'fainting',
    'drowning',
  ];

  /// حالات الكوارث المتاحة
  static const List<String> disasterIds = [
    'fire',
    'earthquake',
    'floods',
  ];

  /// معايير التحليلات
  static const Map<String, String> analyticsEvents = {
    'app_launched': 'تطبيق تم تشغيله',
    'sos_activated': 'SOS تم تفعيله',
    'first_aid_viewed': 'عُرضت إسعافات أولية',
    'disaster_viewed': 'عُرضت معلومات كارثة',
    'profile_updated': 'تم تحديث الملف الشخصي',
    'tutorial_completed': 'اكتمل الدليل التفاعلي',
  };

  /// مدة الجلسة (لتتبع الاستخدام)
  static const Duration sessionTimeout = Duration(minutes: 30);

  /// إعدادات التطوير
  static const bool isDebugMode = true;
  static const bool showDebugBanner = true;
  static const bool enablePerformanceOverlay = false;

  /// رسائل السجل
  static const Map<String, String> logMessages = {
    'app_start': '🚀 تطبيق SERA بدأ التشغيل',
    'app_exit': '❌ تطبيق SERA تم إيقافه',
    'sos_recorded': '✅ تم تسجيل تنبيه SOS',
    'location_obtained': '📍 تم الحصول على الموقع',
    'database_initialized': '🗄️ تم تهيئة قاعدة البيانات',
    'navigation_restored': '🔄 تم استرجاع حالة الملاحة',
  };
}
