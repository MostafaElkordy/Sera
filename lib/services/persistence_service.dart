import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المحلي الموحدة - Clean Version
class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  factory PersistenceService() => _instance;
  PersistenceService._internal();

  /// تهيئة الخدمة
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// التأكد من التهيئة
  bool isInitialized() => _isInitialized;

  // ===========================================================================
  // 1. إعدادات المستخدم والبيانات الشخصية
  // ===========================================================================

  static const String _keyUserName = 'user_name';
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserDob = 'user_dob';
  static const String _keyUserWeight = 'user_weight';
  static const String _keyUserHeight = 'user_height';
  static const String _keyUserImagePath = 'user_image_path';
  static const String _keyUserBloodType = 'user_blood_type';
  static const String _keyUserMedications = 'user_medications';
  static const String _keyUserMedicalDirectives = 'user_medical_directives';
  static const String _keyMedicalHistory =
      'medical_history'; // قائمة مفصولة بفاصلة
  static const String _keyUserDoctorName = 'user_doctor_name';
  static const String _keyUserDoctorPhone = 'user_doctor_phone';
  static const String _keyUserInsuranceType = 'user_insurance_type';
  static const String _keyUserInsuranceProvider = 'user_insurance_provider';
  static const String _keyUserInsurancePolicy = 'user_insurance_policy';

  Future<void> saveUserData(Map<String, dynamic> data) async {
    if (data['name'] != null)
      await _prefs?.setString(_keyUserName, data['name']);
    if (data['gender'] != null)
      await _prefs?.setString(_keyUserGender, data['gender']);
    if (data['dob'] != null) await _prefs?.setString(_keyUserDob, data['dob']);
    if (data['weight'] != null)
      await _prefs?.setString(_keyUserWeight, data['weight']);
    if (data['height'] != null)
      await _prefs?.setString(_keyUserHeight, data['height']);
    if (data['imagePath'] != null)
      await _prefs?.setString(_keyUserImagePath, data['imagePath']);

    // Medical
    if (data['bloodType'] != null)
      await _prefs?.setString(_keyUserBloodType, data['bloodType']);
    if (data['medicalHistory'] != null)
      await _prefs?.setString(_keyMedicalHistory, data['medicalHistory']);
    if (data['medications'] != null)
      await _setStringList(_keyUserMedications, data['medications']);
    if (data['medicalDirectives'] != null)
      await _setStringList(
          _keyUserMedicalDirectives, data['medicalDirectives']);

    // Doctor
    if (data['doctorName'] != null)
      await _prefs?.setString(_keyUserDoctorName, data['doctorName']);
    if (data['doctorPhone'] != null)
      await _prefs?.setString(_keyUserDoctorPhone, data['doctorPhone']);

    // Insurance
    if (data['insuranceType'] != null)
      await _prefs?.setString(_keyUserInsuranceType, data['insuranceType']);
    if (data['insuranceProvider'] != null)
      await _prefs?.setString(
          _keyUserInsuranceProvider, data['insuranceProvider']);
    if (data['insurancePolicy'] != null)
      await _prefs?.setString(_keyUserInsurancePolicy, data['insurancePolicy']);
  }

  Map<String, dynamic> getUserData() {
    return {
      'name': _prefs?.getString(_keyUserName),
      'gender': _prefs?.getString(_keyUserGender),
      'dob': _prefs?.getString(_keyUserDob),
      'weight': _prefs?.getString(_keyUserWeight),
      'height': _prefs?.getString(_keyUserHeight),
      'imagePath': _prefs?.getString(_keyUserImagePath),
      'bloodType': _prefs?.getString(_keyUserBloodType),
      'medicalHistory': _prefs?.getString(_keyMedicalHistory),
      'medications': _getStringList(_keyUserMedications),
      'medicalDirectives': _getStringList(_keyUserMedicalDirectives),
      'doctorName': _prefs?.getString(_keyUserDoctorName),
      'doctorPhone': _prefs?.getString(_keyUserDoctorPhone),
      'insuranceType': _prefs?.getString(_keyUserInsuranceType),
      'insuranceProvider': _prefs?.getString(_keyUserInsuranceProvider),
      'insurancePolicy': _prefs?.getString(_keyUserInsurancePolicy),
    };
  }

  // Getters المختصرة (Direct Access)
  String? getUserName() => _prefs?.getString(_keyUserName);
  String? getUserGender() => _prefs?.getString(_keyUserGender);

  // ===========================================================================
  // 2. جهات الاتصال للطوارئ
  // ===========================================================================

  static const String _keyEmergencyContacts = 'emergency_contacts';

  Future<void> setEmergencyContacts(List<Map<String, String>> contacts) async {
    await _prefs?.setString(_keyEmergencyContacts, jsonEncode(contacts));
  }

  List<Map<String, String>> getEmergencyContacts() {
    final str = _prefs?.getString(_keyEmergencyContacts);
    if (str == null) return [];
    try {
      final List<dynamic> list = jsonDecode(str);
      return list.map((e) => Map<String, String>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ===========================================================================
  // 3. سجل SOS (التخزين الاحتياطي البسيط)
  // ===========================================================================

  static const String _keySosHistory = 'sos_history_quick';

  Future<void> addSosToHistory(Map<String, dynamic> alert) async {
    // نقرأ القائمة الحالية، نضيف عليها، ونحفظ
    final current = getSosHistory();
    current.insert(0, alert); // الأحدث أولاً
    if (current.length > 50) current.removeLast(); // حد أقصى للحفظ السريع
    await _prefs?.setString(_keySosHistory, jsonEncode(current));
  }

  List<Map<String, dynamic>> getSosHistory() {
    final str = _prefs?.getString(_keySosHistory);
    if (str == null) return [];
    try {
      final List<dynamic> list = jsonDecode(str);
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSosHistory(List<Map<String, dynamic>> history) async {
    await _prefs?.setString(_keySosHistory, jsonEncode(history));
  }

  Future<void> clearSosHistory() async {
    await _prefs?.remove(_keySosHistory);
  }

  // ===========================================================================
  // 4. إعدادات التطبيق (Theme, Language, Permissions)
  // ===========================================================================

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyPermissionsSeen = 'permissions_seen';

  Future<void> saveThemeMode(String mode) async =>
      await _prefs?.setString(_keyThemeMode, mode);
  String getThemeMode() => _prefs?.getString(_keyThemeMode) ?? 'daylight';

  Future<void> setPermissionsSeen(bool seen) async =>
      await _prefs?.setBool(_keyPermissionsSeen, seen);
  bool hasSeenPermissions() => _prefs?.getBool(_keyPermissionsSeen) ?? false;

  // ===========================================================================
  // 5. الملاحة (Navigation State)
  // ===========================================================================

  static const String _keyNavStack = 'nav_stack';

  Future<void> saveNavigationStack(List<String> stack) async {
    await _prefs?.setString(_keyNavStack, jsonEncode(stack));
  }

  List<String> loadNavigationStack() {
    return _getStringList(_keyNavStack);
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Future<void> _setStringList(String key, List<dynamic> list) async {
    // نحفظ كـ JSON String لمرونة أكثر من setStringList العادي
    await _prefs?.setString(key, jsonEncode(list));
  }

  List<String> _getStringList(String key) {
    final s = _prefs?.getString(key);
    if (s == null) return [];
    try {
      return List<String>.from(jsonDecode(s));
    } catch (_) {
      return [];
    }
  }
}

/// المتغير العام للاستخدام في التطبيق
final persistence = PersistenceService();
