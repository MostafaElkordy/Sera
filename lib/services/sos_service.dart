// خدمة إدارة تنبيهات SOS
// تسجيل ومعالجة وتتبع تنبيهات الطوارئ

enum SosStatus {
  pending,
  sent,
  received,
  confirmed,
  cancelled,
  failed,
}

class SosAlert {
  final String id;
  final DateTime timestamp;
  double? latitude;
  double? longitude;
  String? userMessage;
  SosStatus status;
  String? responseMessage;
  DateTime? responseTime;
  Map<String, dynamic>? contactsNotified;
  String? error;

  SosAlert({
    required this.id,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.userMessage,
    this.status = SosStatus.pending,
    this.responseMessage,
    this.responseTime,
    this.contactsNotified,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'userMessage': userMessage,
    'status': status.toString(),
    'responseMessage': responseMessage,
    'responseTime': responseTime?.toIso8601String(),
    'contactsNotified': contactsNotified,
    'error': error,
  };

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      userMessage: json['userMessage'] as String?,
      status: _parseSosStatus(json['status'] as String?),
      responseMessage: json['responseMessage'] as String?,
      responseTime: json['responseTime'] != null
          ? DateTime.parse(json['responseTime'] as String)
          : null,
      contactsNotified: json['contactsNotified'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  static SosStatus _parseSosStatus(String? status) {
    if (status == null) return SosStatus.pending;
    try {
      return SosStatus.values.firstWhere(
        (e) => e.toString() == 'SosStatus.$status',
      );
    } catch (e) {
      return SosStatus.pending;
    }
  }

  @override
  String toString() => 'SosAlert #$id - ${status.name} at $timestamp';

  bool isActive() =>
      status == SosStatus.pending || status == SosStatus.sent;

  bool isResolved() =>
      status == SosStatus.confirmed ||
      status == SosStatus.cancelled ||
      status == SosStatus.failed;
}

typedef SosStatusCallback = Future<void> Function(SosAlert alert);

class SosService {
  static final SosService _instance = SosService._internal();

  final List<SosAlert> _sosHistory = [];
  SosAlert? _currentActiveAlert;
  final List<SosStatusCallback> _statusCallbacks = [];
  bool _isInitialized = false;
  static const int _maxHistorySize = 100;

  factory SosService() => _instance;

  SosService._internal();

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  // إنشاء تنبيه SOS جديد
  Future<SosAlert> createSosAlert({
    double? latitude,
    double? longitude,
    String? userMessage,
  }) async {
    final alert = SosAlert(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      userMessage: userMessage,
      status: SosStatus.pending,
    );

    _currentActiveAlert = alert;
    _sosHistory.add(alert);

    // الاحتفاظ بآخر 100 تنبيه فقط
    if (_sosHistory.length > _maxHistorySize) {
      _sosHistory.removeRange(0, _sosHistory.length - _maxHistorySize);
    }

    await _notifyStatusChange(alert);
    return alert;
  }

  // تحديث حالة التنبيه
  Future<void> updateSosStatus(
    String sosId,
    SosStatus newStatus, {
    String? responseMessage,
    String? error,
  }) async {
    try {
      final alert = _sosHistory.firstWhere((a) => a.id == sosId);

      alert.status = newStatus;
      if (responseMessage != null) {
        alert.responseMessage = responseMessage;
        alert.responseTime = DateTime.now();
      }
      if (error != null) {
        alert.error = error;
      }

      if (alert.isResolved()) {
        _currentActiveAlert = null;
      }

      await _notifyStatusChange(alert);
    } catch (e) {
      // تنبيه غير موجود
    }
  }

  // تحديث موقع التنبيه
  Future<void> updateSosLocation(
    String sosId,
    double latitude,
    double longitude,
  ) async {
    try {
      final alert = _sosHistory.firstWhere((a) => a.id == sosId);
      alert.latitude = latitude;
      alert.longitude = longitude;
      await _notifyStatusChange(alert);
    } catch (e) {
      // تنبيه غير موجود
    }
  }

  // الحصول على التنبيه النشط الحالي
  SosAlert? getCurrentActiveAlert() => _currentActiveAlert;

  // الحصول على سجل SOS الكامل
  List<SosAlert> getSosHistory() => List.from(_sosHistory);

  // الحصول على آخر تنبيه
  SosAlert? getLastSosAlert() {
    if (_sosHistory.isEmpty) return null;
    return _sosHistory.last;
  }

  // الحصول على التنبيهات النشطة
  List<SosAlert> getActiveAlerts() {
    return _sosHistory.where((alert) => alert.isActive()).toList();
  }

  // الحصول على التنبيهات المحفوظة
  List<SosAlert> getResolvedAlerts() {
    return _sosHistory.where((alert) => alert.isResolved()).toList();
  }

  // إلغاء تنبيه SOS
  Future<void> cancelSosAlert(String sosId) async {
    await updateSosStatus(sosId, SosStatus.cancelled);
  }

  // تأكيد استقبال التنبيه
  Future<void> confirmSosAlert(String sosId) async {
    await updateSosStatus(sosId, SosStatus.confirmed);
  }

  // تحديث جهات الاتصال المخطرة
  Future<void> updateNotifiedContacts(
    String sosId,
    Map<String, dynamic> contacts,
  ) async {
    try {
      final alert = _sosHistory.firstWhere((a) => a.id == sosId);
      alert.contactsNotified = contacts;
      await _notifyStatusChange(alert);
    } catch (e) {
      // تنبيه غير موجود
    }
  }

  // تسجيل callback لتغيير الحالة
  void registerStatusCallback(SosStatusCallback callback) {
    _statusCallbacks.add(callback);
  }

  // إزالة callback
  void removeStatusCallback(SosStatusCallback callback) {
    _statusCallbacks.remove(callback);
  }

  // إشعار بتغيير الحالة
  Future<void> _notifyStatusChange(SosAlert alert) async {
    for (final callback in _statusCallbacks) {
      try {
        await callback(alert);
      } catch (e) {
        // تجاهل الأخطاء
      }
    }
  }

  // حذف تنبيه من السجل
  bool removeSosAlert(String sosId) {
    final index = _sosHistory.indexWhere((a) => a.id == sosId);
    if (index != -1) {
      if (_currentActiveAlert?.id == sosId) {
        _currentActiveAlert = null;
      }
      _sosHistory.removeAt(index);
      return true;
    }
    return false;
  }

  // حذف جميع التنبيهات
  void clearSosHistory() {
    _sosHistory.clear();
    _currentActiveAlert = null;
  }

  // إحصائيات SOS
  Map<String, dynamic> getSosStatistics() {
    final activeCount = getActiveAlerts().length;
    final resolvedCount = getResolvedAlerts().length;
    final failedCount =
        _sosHistory.where((a) => a.status == SosStatus.failed).length;

    return {
      'total_alerts': _sosHistory.length,
      'active_alerts': activeCount,
      'resolved_alerts': resolvedCount,
      'failed_alerts': failedCount,
      'last_alert': _sosHistory.isNotEmpty
          ? _sosHistory.last.timestamp.toIso8601String()
          : null,
      'current_active': _currentActiveAlert?.id,
    };
  }

  // البحث عن تنبيه
  SosAlert? findSosAlert(String sosId) {
    try {
      return _sosHistory.firstWhere((a) => a.id == sosId);
    } catch (e) {
      return null;
    }
  }

  // الحصول على التنبيهات من فترة زمنية
  List<SosAlert> getSosAlertsInRange(DateTime start, DateTime end) {
    return _sosHistory
        .where((alert) =>
            alert.timestamp.isAfter(start) &&
            alert.timestamp.isBefore(end))
        .toList();
  }

  // تصدير السجل كـ JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _sosHistory.map((alert) => alert.toJson()).toList();
  }

  // استيراد السجل من JSON
  Future<void> importFromJson(List<dynamic> jsonList) async {
    try {
      _sosHistory.clear();
      for (final item in jsonList) {
        final alert = SosAlert.fromJson(item as Map<String, dynamic>);
        _sosHistory.add(alert);
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // عدد التنبيهات
  int getSosCount() => _sosHistory.length;

  // تنظيف الموارد
  void dispose() {
    _sosHistory.clear();
    _currentActiveAlert = null;
    _statusCallbacks.clear();
    _isInitialized = false;
  }
}

// مثيل عام للاستخدام السريع
final sosService = SosService();
