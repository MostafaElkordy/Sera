// خدمة الإشعارات المحلية
// إدارة الإشعارات المحلية والتنبيهات

enum NotificationType {
  info,
  warning,
  error,
  success,
  sos,
}

class LocalNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;
  bool isRead;
  String? action;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.info,
    DateTime? timestamp,
    this.payload,
    this.isRead = false,
    this.action,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'payload': payload,
    'isRead': isRead,
    'action': action,
  };

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] as String?),
        orElse: () => NotificationType.info,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      action: json['action'] as String?,
    );
  }

  @override
  String toString() => 'Notification #$id: $title';

  String getIconByType() {
    switch (type) {
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.error:
        return '❌';
      case NotificationType.success:
        return '✅';
      case NotificationType.sos:
        return '🚨';
    }
  }
}

typedef NotificationCallback = Future<void> Function(LocalNotification notification);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  final List<LocalNotification> _notifications = [];
  final List<NotificationCallback> _callbacks = [];
  bool _isEnabled = true;
  bool _isInitialized = false;
  static const int _maxNotifications = 50;

  factory NotificationService() => _instance;

  NotificationService._internal();

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  // إرسال إشعار
  Future<void> sendNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isEnabled) return;

    final notification = LocalNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      payload: payload,
    );

    _notifications.add(notification);

    // الاحتفاظ بآخر 50 إشعار فقط
    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(0, _notifications.length - _maxNotifications);
    }

    await _notifyCallbacks(notification);
  }

  // إرسال إشعار SOS
  Future<void> sendSosNotification({
    required String message,
    double? latitude,
    double? longitude,
  }) async {
    await sendNotification(
      title: 'تنبيه SOS',
      body: message,
      type: NotificationType.sos,
      payload: {
        'latitude': latitude,
        'longitude': longitude,
        'action': 'view_sos',
      },
    );
  }

  // إرسال إشعار نجاح
  Future<void> sendSuccessNotification(String message) async {
    await sendNotification(
      title: 'نجح',
      body: message,
      type: NotificationType.success,
    );
  }

  // إرسال إشعار خطأ
  Future<void> sendErrorNotification(String message) async {
    await sendNotification(
      title: 'خطأ',
      body: message,
      type: NotificationType.error,
    );
  }

  // إرسال إشعار تحذير
  Future<void> sendWarningNotification(String message) async {
    await sendNotification(
      title: 'تحذير',
      body: message,
      type: NotificationType.warning,
    );
  }

  // تسجيل callback
  void registerCallback(NotificationCallback callback) {
    _callbacks.add(callback);
  }

  // إزالة callback
  void removeCallback(NotificationCallback callback) {
    _callbacks.remove(callback);
  }

  // إشعار الـ callbacks
  Future<void> _notifyCallbacks(LocalNotification notification) async {
    for (final callback in _callbacks) {
      try {
        await callback(notification);
      } catch (e) {
        // تجاهل الأخطاء
      }
    }
  }

  // تحديد الإشعار كمقروء
  bool markAsRead(String notificationId) {
    try {
      final notification = _notifications
          .firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  // تحديد جميع الإشعارات كمقروءة
  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }
  }

  // الحصول على جميع الإشعارات
  List<LocalNotification> getAllNotifications() {
    return List.from(_notifications);
  }

  // الحصول على الإشعارات غير المقروءة
  List<LocalNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // الحصول على الإشعارات من نوع معين
  List<LocalNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // حذف إشعار
  bool deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      return true;
    }
    return false;
  }

  // حذف جميع الإشعارات
  void clearAllNotifications() {
    _notifications.clear();
  }

  // حذف الإشعارات القديمة
  void clearOldNotifications(Duration duration) {
    final cutoffTime = DateTime.now().subtract(duration);
    _notifications
        .removeWhere((n) => n.timestamp.isBefore(cutoffTime));
  }

  // تفعيل / تعطيل الإشعارات
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool isEnabled() => _isEnabled;

  // الحصول على عدد الإشعارات غير المقروءة
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // إحصائيات الإشعارات
  Map<String, dynamic> getStatistics() {
    final typeStats = <String, int>{};
    for (final notification in _notifications) {
      typeStats[notification.type.name] =
          (typeStats[notification.type.name] ?? 0) + 1;
    }

    return {
      'total': _notifications.length,
      'unread': getUnreadCount(),
      'read': _notifications.where((n) => n.isRead).length,
      'by_type': typeStats,
      'enabled': _isEnabled,
    };
  }

  // تصدير الإشعارات كـ JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _notifications.map((n) => n.toJson()).toList();
  }

  // استيراد الإشعارات من JSON
  Future<void> importFromJson(List<dynamic> jsonList) async {
    try {
      _notifications.clear();
      for (final item in jsonList) {
        final notification = LocalNotification.fromJson(
            item as Map<String, dynamic>);
        _notifications.add(notification);
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // البحث في الإشعارات
  List<LocalNotification> search(String query) {
    return _notifications
        .where((n) =>
            n.title.toLowerCase().contains(query.toLowerCase()) ||
            n.body.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // تنظيف الموارد
  void dispose() {
    _notifications.clear();
    _callbacks.clear();
    _isInitialized = false;
  }
}

// مثيل عام للاستخدام السريع
final notificationService = NotificationService();
