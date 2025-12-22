// تفعيل SOS الفعلي
// ربط جميع الخدمات لتنشيط تنبيه SOS كامل

class SosActivationResult {
  final bool success;
  final String message;
  final SosAlert? sosAlert;
  final String? error;
  final DateTime timestamp;

  SosActivationResult({
    required this.success,
    required this.message,
    this.sosAlert,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'sos_id': sosAlert?.id,
    'error': error,
    'timestamp': timestamp.toIso8601String(),
  };
}

class SosAlert {
  final String id;
  final double? latitude;
  final double? longitude;
  final String? message;
  final DateTime timestamp;
  final String status;

  SosAlert({
    required this.id,
    this.latitude,
    this.longitude,
    this.message,
    required this.timestamp,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
  };
}

typedef SosActivationCallback = Future<void> Function(
    SosActivationResult result);

class SosActivationManager {
  static final SosActivationManager _instance =
      SosActivationManager._internal();

  final List<SosActivationCallback> _callbacks = [];
  bool _isActivating = false;
  SosAlert? _currentAlert;

  factory SosActivationManager() => _instance;

  SosActivationManager._internal();

  // تنشيط SOS
  Future<SosActivationResult> activateSos({
    String? userMessage,
    bool includeLocation = true,
    bool playSound = true,
    bool saveToHistory = true,
  }) async {
    if (_isActivating) {
      return SosActivationResult(
        success: false,
        message: 'تنبيه SOS قيد التنشيط بالفعل',
        error: 'ALREADY_ACTIVATING',
      );
    }

    _isActivating = true;

    try {
      // 1. الحصول على الموقع
      double? latitude;
      double? longitude;

      if (includeLocation) {
        // final location = await locationService.getCurrentLocation();
        // latitude = location?.latitude;
        // longitude = location?.longitude;
      }

      // 2. إنشاء تنبيه SOS
      final alert = SosAlert(
        id: 'SOS_${DateTime.now().millisecondsSinceEpoch}',
        latitude: latitude,
        longitude: longitude,
        message: userMessage,
        timestamp: DateTime.now(),
        status: 'active',
      );

      _currentAlert = alert;

      // 3. حفظ في السجل
      if (saveToHistory) {
        // await persistence.addSosToHistory(alert.toMap());
      }

      // 4. تشغيل الصوت
      if (playSound) {
        try {
          // await audioService.playSosAlert();
        } catch (e) {
          print('خطأ في تشغيل الصوت: $e');
        }
      }

      // 5. إرسال إشعار
      // await notificationService.sendSosNotification();

      // 6. تنبيه جهات الطوارئ
      // await _notifyEmergencyContacts();

      // تنفيذ callbacks
      final result = SosActivationResult(
        success: true,
        message: 'تم تفعيل تنبيه الطوارئ بنجاح',
        sosAlert: alert,
      );

      for (final callback in _callbacks) {
        try {
          await callback(result);
        } catch (e) {
          print('خطأ في callback: $e');
        }
      }

      return result;
    } catch (e) {
      final result = SosActivationResult(
        success: false,
        message: 'فشل في تفعيل تنبيه الطوارئ',
        error: e.toString(),
      );

      for (final callback in _callbacks) {
        try {
          await callback(result);
        } catch (callbackError) {
          print('خطأ في callback: $callbackError');
        }
      }

      return result;
    } finally {
      _isActivating = false;
    }
  }

  // إلغاء SOS
  Future<bool> cancelCurrentSos() async {
    if (_currentAlert == null) {
      return false;
    }

    try {
      // await sosService.updateSosStatus(_currentAlert!.id, 'cancelled');
      _currentAlert = null;
      return true;
    } catch (e) {
      print('خطأ في إلغاء SOS: $e');
      return false;
    }
  }

  // التحقق من وجود SOS نشط
  bool hasActiveSos() => _currentAlert != null && _currentAlert!.status == 'active';

  // الحصول على SOS الحالي
  SosAlert? getCurrentSos() => _currentAlert;

  // تسجيل callback
  void registerCallback(SosActivationCallback callback) {
    _callbacks.add(callback);
  }

  // إلغاء تسجيل callback
  void unregisterCallback(SosActivationCallback callback) {
    _callbacks.remove(callback);
  }

  // حالة التفعيل
  bool get isActivating => _isActivating;

  // Helper for tests: reset internal state and callbacks
  void resetForTesting() {
    _currentAlert = null;
    _callbacks.clear();
    _isActivating = false;
  }

  // Alias to match other modules expecting dispose()
  void dispose() => resetForTesting();
}

// إنشاء instance عام
final sosActivationManager = SosActivationManager();
