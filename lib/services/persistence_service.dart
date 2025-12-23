// خدمة الحفظ والاسترجاع المحلية (Placeholder - Phase 3)
// تدير البيانات المحلية لحفظ بيانات المستخدم والإعدادات والسجلات

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sera_database.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  factory PersistenceService() => _instance;

  PersistenceService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  // Keys
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserBloodType = 'user_blood_type';
  static const String _keyMedicalHistory = 'medical_history';
  static const String _keyAppTheme = 'app_theme';
  static const String _keyAppLanguage = 'app_language';
  static const String _keySosHistoryList = 'sos_history_list';
  static const String _keyTutorialCompleted = 'tutorial_completed';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyFirstTimeUser = 'first_time_user';
  static const String _keyEmergencyContacts = 'emergency_contacts';

  // New Constants Phase 2
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserDob = 'user_dob';
  static const String _keyUserWeight = 'user_weight';
  static const String _keyUserHeight = 'user_height';
  static const String _keyUserMedications = 'user_medications';
  static const String _keyUserImagePath = 'user_image_path';
  static const String _keyUserMedicalDirectives = 'user_medical_directives';
  static const String _keyUserDoctorName = 'user_doctor_name';
  static const String _keyUserDoctorPhone = 'user_doctor_phone';
  static const String _keyUserInsuranceType = 'user_insurance_type';
  static const String _keyUserInsuranceProvider = 'user_insurance_provider';
  static const String _keyUserInsurancePolicy = 'user_insurance_policy';

  // Initialize Service
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      // Also try to init DB
      try {
        await SeraDatabase.instance.init();
      } catch (e) {
        debugPrint('Database init failed: $e');
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('SharedPrefs init failed: $e');
    }
  }

  static const String _keyThemeMode = 'theme_mode';

  // --- Theme ---
  Future<void> saveThemeMode(String themeName) async {
    await _prefs?.setString(_keyThemeMode, themeName);
  }

  String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? 'daylight';
  }

  // ===== User Data =====

  Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
  }

  String? getUserName() => _prefs?.getString(_keyUserName);

  Future<void> setUserEmail(String email) async {
    await _prefs?.setString(_keyUserEmail, email);
  }

  String? getUserEmail() => _prefs?.getString(_keyUserEmail);

  Future<void> setUserPhone(String phone) async {
    await _prefs?.setString(_keyUserPhone, phone);
  }

  String? getUserPhone() => _prefs?.getString(_keyUserPhone);

  Future<void> setUserBloodType(String bloodType) async {
    await _prefs?.setString(_keyUserBloodType, bloodType);
  }

  String? getUserBloodType() => _prefs?.getString(_keyUserBloodType);

  // ===== Emergency Contacts =====

  Future<void> setEmergencyContacts(List<Map<String, String>> contacts) async {
    final jsonString = jsonEncode(contacts);
    await _prefs?.setString(_keyEmergencyContacts, jsonString);
  }

  List<Map<String, String>> getEmergencyContacts() {
    final jsonString = _prefs?.getString(_keyEmergencyContacts);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEmergencyContact(String name, String phone) async {
    final contacts = getEmergencyContacts();
    contacts.add({'name': name, 'phone': phone});
    await setEmergencyContacts(contacts);
  }

  Future<void> removeEmergencyContact(String name) async {
    final contacts = getEmergencyContacts();
    contacts.removeWhere((c) => c['name'] == name);
    await setEmergencyContacts(contacts);
  }

  // ===== Medical History =====

  Future<void> setMedicalHistory(String history) async {
    await _prefs?.setString(_keyMedicalHistory, history);
  }

  String? getMedicalHistory() => _prefs?.getString(_keyMedicalHistory);

  // ===== Settings =====

  Future<void> setAppTheme(String theme) async {
    await _prefs?.setString(_keyAppTheme, theme);
  }

  String getAppTheme() => _prefs?.getString(_keyAppTheme) ?? 'dark';

  Future<void> setAppLanguage(String language) async {
    await _prefs?.setString(_keyAppLanguage, language);
  }

  String getAppLanguage() => _prefs?.getString(_keyAppLanguage) ?? 'ar';

  // ===== SOS Data =====

  Future<void> addSosToHistory(Map<String, dynamic> sosData) async {
    try {
      await SeraDatabase.instance.insertSos(sosData);
    } catch (e) {
      // Fallback to SharedPreferences if DB fails
      final history = getSosHistory();
      history.add(sosData);
      if (history.length > 50) history.removeAt(0); // Limit size
      await _prefs?.setString(_keySosHistoryList, jsonEncode(history));
    }
  }

  List<Map<String, dynamic>> getSosHistory() {
    // Note: Ideally read from DB asynchronously, but for sync access we return empty or cached
    // Real implementation should primarily use Future<List> from SeraDatabase.
    // This is a fallback/cache reader.
    final jsonString = _prefs?.getString(_keySosHistoryList);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSosHistory() async {
    try {
      // Clear from Prefs
      await _prefs?.remove(_keySosHistoryList);
      // Clear from DB (Placeholder for when DB is fully active)
      // await SeraDatabase.instance.clearSos();
    } catch (e) {
      debugPrint('Error clearing SOS history: $e');
    }
  }

  Future<void> saveSosHistory(List<Map<String, dynamic>> history) async {
    await _prefs?.setString(_keySosHistoryList, jsonEncode(history));
  }

  // ===== Tutorial & First Time =====

  Future<void> setTutorialCompleted(bool completed) async {
    await _prefs?.setBool(_keyTutorialCompleted, completed);
  }

  bool isTutorialCompleted() => _prefs?.getBool(_keyTutorialCompleted) ?? false;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  bool areNotificationsEnabled() =>
      _prefs?.getBool(_keyNotificationsEnabled) ?? true;

  bool isFirstTimeUser() => _prefs?.getBool(_keyFirstTimeUser) ?? true;

  Future<void> setFirstTimeUser(bool isFirst) async {
    await _prefs?.setBool(_keyFirstTimeUser, isFirst);
  }

  // --- New Getters/Setters ---

  Future<void> setUserGender(String gender) async =>
      await _prefs?.setString(_keyUserGender, gender);
  String? getUserGender() => _prefs?.getString(_keyUserGender);

  Future<void> setUserDob(String dob) async =>
      await _prefs?.setString(_keyUserDob, dob);
  String? getUserDob() => _prefs?.getString(_keyUserDob);

  Future<void> setUserWeight(String weight) async =>
      await _prefs?.setString(_keyUserWeight, weight);
  String? getUserWeight() => _prefs?.getString(_keyUserWeight);

  Future<void> setUserHeight(String height) async =>
      await _prefs?.setString(_keyUserHeight, height);
  String? getUserHeight() => _prefs?.getString(_keyUserHeight);

  Future<void> setUserImagePath(String path) async =>
      await _prefs?.setString(_keyUserImagePath, path);
  String? getUserImagePath() => _prefs?.getString(_keyUserImagePath);

  Future<void> setUserDoctorName(String name) async =>
      await _prefs?.setString(_keyUserDoctorName, name);
  String? getUserDoctorName() => _prefs?.getString(_keyUserDoctorName);

  Future<void> setUserDoctorPhone(String phone) async =>
      await _prefs?.setString(_keyUserDoctorPhone, phone);
  String? getUserDoctorPhone() => _prefs?.getString(_keyUserDoctorPhone);

  Future<void> setUserInsuranceType(String type) async =>
      await _prefs?.setString(_keyUserInsuranceType, type);
  String? getUserInsuranceType() => _prefs?.getString(_keyUserInsuranceType);

  Future<void> setUserInsuranceProvider(String provider) async =>
      await _prefs?.setString(_keyUserInsuranceProvider, provider);
  String? getUserInsuranceProvider() =>
      _prefs?.getString(_keyUserInsuranceProvider);

  Future<void> setUserInsurancePolicy(String policy) async =>
      await _prefs?.setString(_keyUserInsurancePolicy, policy);
  String? getUserInsurancePolicy() =>
      _prefs?.getString(_keyUserInsurancePolicy);

  // Lists (Medications & Directives)
  Future<void> setUserMedications(List<String> meds) async =>
      await _prefs?.setString(_keyUserMedications, jsonEncode(meds));
  List<String> getUserMedications() {
    final s = _prefs?.getString(_keyUserMedications);
    if (s == null) return [];
    try {
      return List<String>.from(jsonDecode(s));
    } catch (_) {
      return [];
    }
  }

  Future<void> setUserMedicalDirectives(List<String> directives) async =>
      await _prefs?.setString(
          _keyUserMedicalDirectives, jsonEncode(directives));
  List<String> getUserMedicalDirectives() {
    final s = _prefs?.getString(_keyUserMedicalDirectives);
    if (s == null) return [];
    try {
      return List<String>.from(jsonDecode(s));
    } catch (_) {
      return [];
    }
  }

  // ===== Advanced =====

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (userData.containsKey('name')) await setUserName(userData['name']);
    if (userData.containsKey('email')) await setUserEmail(userData['email']);
    if (userData.containsKey('phone')) await setUserPhone(userData['phone']);
    if (userData.containsKey('bloodType'))
      await setUserBloodType(userData['bloodType']);
    if (userData.containsKey('medicalHistory'))
      await setMedicalHistory(userData['medicalHistory']);

    // New Fields
    // New Fields
    if (userData.containsKey('gender') && userData['gender'] != null)
      await setUserGender(userData['gender']);
    if (userData.containsKey('dob') && userData['dob'] != null)
      await setUserDob(userData['dob']);
    if (userData.containsKey('weight') && userData['weight'] != null)
      await setUserWeight(userData['weight']);
    if (userData.containsKey('height') && userData['height'] != null)
      await setUserHeight(userData['height']);
    if (userData.containsKey('imagePath') && userData['imagePath'] != null)
      await setUserImagePath(userData['imagePath']);

    if (userData.containsKey('doctorName') && userData['doctorName'] != null)
      await setUserDoctorName(userData['doctorName']);
    if (userData.containsKey('doctorPhone') && userData['doctorPhone'] != null)
      await setUserDoctorPhone(userData['doctorPhone']);

    if (userData.containsKey('insuranceType') &&
        userData['insuranceType'] != null)
      await setUserInsuranceType(userData['insuranceType']);
    if (userData.containsKey('insuranceProvider') &&
        userData['insuranceProvider'] != null)
      await setUserInsuranceProvider(userData['insuranceProvider']);
    if (userData.containsKey('insurancePolicy') &&
        userData['insurancePolicy'] != null)
      await setUserInsurancePolicy(userData['insurancePolicy']);

    if (userData.containsKey('medications') && userData['medications'] != null)
      await setUserMedications(List<String>.from(userData['medications']));
    if (userData.containsKey('medicalDirectives') &&
        userData['medicalDirectives'] != null)
      await setUserMedicalDirectives(
          List<String>.from(userData['medicalDirectives']));
  }

  Map<String, dynamic> getUserData() {
    return {
      'name': getUserName(),
      'email': getUserEmail(),
      'phone': getUserPhone(),
      'bloodType': getUserBloodType(),
      'medicalHistory': getMedicalHistory(),
      // New Fields
      'gender': getUserGender(),
      'dob': getUserDob(),
      'weight': getUserWeight(),
      'height': getUserHeight(),
      'imagePath': getUserImagePath(),
      'doctorName': getUserDoctorName(),
      'doctorPhone': getUserDoctorPhone(),
      'insuranceType': getUserInsuranceType(),
      'insuranceProvider': getUserInsuranceProvider(),
      'insurancePolicy': getUserInsurancePolicy(),
      'medications': getUserMedications(),
      'medicalDirectives': getUserMedicalDirectives(),
    };
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
    _isInitialized = false;
  }

  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      await saveUserData(data);
    } catch (e) {
      debugPrint('Import data failed: $e');
    }
  }

  static const String _keyPermissionsSeen = 'permissions_seen';

  Future<void> setPermissionsSeen(bool seen) async {
    await _prefs?.setBool(_keyPermissionsSeen, seen);
  }

  bool hasSeenPermissions() => _prefs?.getBool(_keyPermissionsSeen) ?? false;

  bool isInitialized() => _isInitialized;
}

// إنشاء instance عام
final persistence = PersistenceService();
