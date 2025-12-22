/// خدمة تتبع أحداث الاستخدام (Analytics)
/// تسجل أحداث التطبيق الهامة لتحليل السلوك والاستخدام

class AnalyticsEvent {
  final String eventName;
  final DateTime timestamp;
  final Map<String, dynamic>? params;

  AnalyticsEvent({
    required this.eventName,
    required this.timestamp,
    this.params,
  });

  Map<String, dynamic> toJson() => {
    'event_name': eventName,
    'timestamp': timestamp.toIso8601String(),
    'params': params,
  };

  @override
  String toString() {
    return '📊 Event: $eventName at ${timestamp.toIso8601String()}${params != null ? ' | $params' : ''}';
  }
}

/// خدمة التحليلات المركزية
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  final List<AnalyticsEvent> _events = [];
  static const int _maxEvents = 500;

  factory AnalyticsService() => _instance;
  
  AnalyticsService._internal();

  /// تتبع حدث عام
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? params,
  }) {
    final event = AnalyticsEvent(
      eventName: eventName,
      timestamp: DateTime.now(),
      params: params,
    );
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
  }

  /// تتبع تفعيل SOS
  void trackSosActivation({
    double? latitude,
    double? longitude,
    String? status,
  }) {
    trackEvent(
      'sos_activated',
      params: {
        'latitude': latitude,
        'longitude': longitude,
        'status': status ?? 'active',
        'user_action': true,
      },
    );
  }

  /// تتبع إلغاء SOS
  void trackSosCancelled() {
    trackEvent(
      'sos_cancelled',
      params: {
        'user_action': true,
      },
    );
  }

  /// تتبع فتح حالة إسعاف أولى
  void trackFirstAidViewed(String caseId, String caseTitle) {
    trackEvent(
      'first_aid_viewed',
      params: {
        'case_id': caseId,
        'case_title': caseTitle,
        'category': 'first_aid',
      },
    );
  }

  /// تتبع فتح حالة كارثة
  void trackDisasterViewed(String disasterId, String disasterTitle) {
    trackEvent(
      'disaster_viewed',
      params: {
        'disaster_id': disasterId,
        'disaster_title': disasterTitle,
        'category': 'disaster',
      },
    );
  }

  /// تتبع إكمال دليل تفاعلي
  void trackTutorialCompleted() {
    trackEvent(
      'tutorial_completed',
      params: {
        'completion_status': 'finished',
      },
    );
  }

  /// تتبع تخطي دليل
  void trackTutorialSkipped() {
    trackEvent(
      'tutorial_skipped',
      params: {
        'completion_status': 'skipped',
      },
    );
  }

  /// تتبع تحديث الملف الشخصي
  void trackProfileUpdated({
    String? bloodType,
    bool? emergencyContactAdded,
    bool? medicalHistoryAdded,
  }) {
    trackEvent(
      'profile_updated',
      params: {
        'blood_type': bloodType,
        'emergency_contact_added': emergencyContactAdded ?? false,
        'medical_history_added': medicalHistoryAdded ?? false,
      },
    );
  }

  /// تتبع بدء التطبيق
  void trackAppLaunched({String? launchSource}) {
    trackEvent(
      'app_launched',
      params: {
        'launch_source': launchSource ?? 'cold_start',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// تتبع إغلاق التطبيق
  void trackAppClosed() {
    trackEvent(
      'app_closed',
      params: {
        'session_end': DateTime.now().toIso8601String(),
      },
    );
  }

  /// تتبع خطأ
  void trackError(
    String errorType,
    String errorMessage, {
    String? stackTrace,
  }) {
    trackEvent(
      'error_occurred',
      params: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
      },
    );
  }

  /// تتبع تحميل صفحة
  void trackPageView(String pageName) {
    trackEvent(
      'page_view',
      params: {
        'page_name': pageName,
      },
    );
  }

  /// تتبع نقرة زر
  void trackButtonClick(String buttonName, {String? context}) {
    trackEvent(
      'button_clicked',
      params: {
        'button_name': buttonName,
        'context': context,
      },
    );
  }

  /// تتبع حدث بحث
  void trackSearch(String query, {int? resultsCount}) {
    trackEvent(
      'search_performed',
      params: {
        'query': query,
        'results_count': resultsCount ?? 0,
      },
    );
  }

  /// الحصول على جميع الأحداث
  List<AnalyticsEvent> getEvents({int? limit}) {
    final events = List<AnalyticsEvent>.from(_events);
    if (limit != null && limit > 0) {
      return events.sublist(
        (events.length - limit).clamp(0, events.length),
      );
    }
    return events;
  }

  /// الحصول على الأحداث من نوع معين
  List<AnalyticsEvent> getEventsByName(String eventName) {
    return _events
        .where((event) => event.eventName == eventName)
        .toList();
  }

  /// الحصول على الأحداث من فترة زمنية معينة
  List<AnalyticsEvent> getEventsByTimeRange(DateTime start, DateTime end) {
    return _events
        .where((event) =>
            event.timestamp.isAfter(start) &&
            event.timestamp.isBefore(end))
        .toList();
  }

  /// البحث عن أحداث
  List<AnalyticsEvent> searchEvents(String query) {
    return _events
        .where((event) =>
            event.eventName.toLowerCase().contains(query.toLowerCase()) ||
            (event.params?.toString().toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  /// حذف جميع الأحداث
  void clearEvents() {
    _events.clear();
  }

  /// حذف الأحداث الأقدم من فترة زمنية معينة
  void clearEventsOlderThan(Duration duration) {
    final cutoffTime = DateTime.now().subtract(duration);
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffTime));
  }

  /// الحصول على إحصائيات الأحداث
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final event in _events) {
      stats[event.eventName] = (stats[event.eventName] ?? 0) + 1;
    }
    return stats;
  }

  /// تصدير الأحداث كـ JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _events.map((event) => event.toJson()).toList();
  }

  /// تصدير الأحداث كـ CSV
  String exportAsCSV() {
    final buffer = StringBuffer();
    buffer.writeln('EventName,Timestamp,Params');

    for (final event in _events) {
      buffer.writeln(
        '"${event.eventName}",'
        '"${event.timestamp.toIso8601String()}",'
        '"${(event.params?.toString() ?? '').replaceAll('"', '""')}"',
      );
    }

    return buffer.toString();
  }

  /// الحصول على عدد الأحداث
  int getEventCount() => _events.length;

  /// الحصول على آخر n من الأحداث
  List<AnalyticsEvent> getLastEvents(int count) {
    if (_events.isEmpty) return [];
    final startIndex = (_events.length - count).clamp(0, _events.length);
    return _events.sublist(startIndex);
  }

  /// طباعة ملخص الإحصائيات
  void printSummary() {
    final stats = getStatistics();
    // Get summary of events
    stats.entries.map((e) => '${e.key}: ${e.value}').toList();
  }

  /// الحصول على أكثر الأحداث حدوثاً
  List<MapEntry<String, int>> getTopEvents({int limit = 5}) {
    final stats = getStatistics();
    final sorted = stats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  /// الحصول على معدل حدوث حدث معين
  double getEventFrequency(String eventName) {
    if (_events.isEmpty) return 0.0;
    final count = _events.where((e) => e.eventName == eventName).length;
    return count / _events.length * 100;
  }

  /// إيقاف خدمة التحليلات
  Future<void> dispose() async {
    clearEvents();
  }
}

/// مثيل عام لـ AnalyticsService للاستخدام السريع
final analytics = AnalyticsService();
