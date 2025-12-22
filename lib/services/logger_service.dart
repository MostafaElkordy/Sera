/// تصنيفات مستويات السجل
enum LogLevel {
  debug,    // معلومات تصحيح
  info,     // معلومات عامة
  warning,  // تحذيرات
  error,    // أخطاء
  critical, // أخطاء حرجة
}

/// فئة تمثل إدخال واحد في السجل
class LogEntry {
  final String level;
  final String message;
  final DateTime timestamp;
  final String? stackTrace;
  final String? context;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] [$level] $message${context != null ? ' ($context)' : ''}';
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'stackTrace': stackTrace,
    'context': context,
  };
}

/// خدمة التسجيل المركزية للتطبيق
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  
  final List<LogEntry> _logs = [];
  bool _isInitialized = false;
  static const int _maxLogRecords = 1000;
  static const bool _enableDebugLogging = true;

  factory LoggerService() => _instance;
  
  LoggerService._internal();

  /// تهيئة خدمة السجل
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      info('🚀 تطبيق SERA بدأ التشغيل');
      _isInitialized = true;
    } catch (e) {
      _log(LogLevel.critical, 'فشل تهيئة خدمة السجل: $e');
    }
  }

  /// تسجيل رسالة معلومات
  void info(String message, {String? context}) {
    _log(LogLevel.info, message, context: context);
  }

  /// تسجيل رسالة تصحيح
  void debug(String message, {String? context}) {
    if (_enableDebugLogging) {
      _log(LogLevel.debug, message, context: context);
    }
  }

  /// تسجيل رسالة تحذير
  void warning(String message, {String? context}) {
    _log(LogLevel.warning, message, context: context);
  }

  /// تسجيل رسالة خطأ
  void error(String message, {String? context, StackTrace? stackTrace}) {
    _log(
      LogLevel.error,
      message,
      context: context,
      stackTrace: stackTrace?.toString(),
    );
  }

  /// تسجيل رسالة خطأ حرج
  void critical(String message, {String? context, StackTrace? stackTrace}) {
    _log(
      LogLevel.critical,
      message,
      context: context,
      stackTrace: stackTrace?.toString(),
    );
  }

  /// دالة داخلية لتسجيل الرسائل
  void _log(
    LogLevel level,
    String message, {
    String? context,
    String? stackTrace,
  }) {
    final entry = LogEntry(
      level: level.name.toUpperCase(),
      message: message,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      context: context,
    );

    _logs.add(entry);

    // طباعة إلى الكونسول
    _printToConsole(entry);

    // حذف السجلات القديمة إذا تجاوزت الحد الأقصى
    if (_logs.length > _maxLogRecords) {
      _logs.removeRange(0, _logs.length - _maxLogRecords);
    }
  }

  /// طباعة السجل إلى الكونسول مع ألوان (إن أمكن)
  void _printToConsole(LogEntry entry) {
    String emoji = '';
    switch (entry.level) {
      case 'DEBUG':
        emoji = '🔍';
        break;
      case 'INFO':
        emoji = 'ℹ️';
        break;
      case 'WARNING':
        emoji = '⚠️';
        break;
      case 'ERROR':
        emoji = '❌';
        break;
      case 'CRITICAL':
        emoji = '🔴';
        break;
      default:
        emoji = '📝';
    }

    print('$emoji ${entry.toString()}');
    if (entry.stackTrace != null) {
      print('Stack Trace:\n${entry.stackTrace}');
    }
  }

  /// الحصول على جميع السجلات
  List<LogEntry> getLogs({int? limit}) {
    final logs = List<LogEntry>.from(_logs);
    if (limit != null && limit > 0) {
      return logs.sublist(
        (logs.length - limit).clamp(0, logs.length),
      );
    }
    return logs;
  }

  /// الحصول على السجلات من نوع معين
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs
        .where((log) => log.level == level.name.toUpperCase())
        .toList();
  }

  /// الحصول على السجلات من فترة زمنية معينة
  List<LogEntry> getLogsByTimeRange(DateTime start, DateTime end) {
    return _logs
        .where((log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end))
        .toList();
  }

  /// البحث عن سجلات تحتوي على كلمة معينة
  List<LogEntry> searchLogs(String query) {
    return _logs
        .where((log) =>
            log.message.toLowerCase().contains(query.toLowerCase()) ||
            (log.context?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  /// حذف جميع السجلات
  void clearLogs() {
    _logs.clear();
    info('تم حذف جميع السجلات');
  }

  /// حذف السجلات الأقدم من فترة زمنية معينة
  void clearLogsOlderThan(Duration duration) {
    final cutoffTime = DateTime.now().subtract(duration);
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffTime));
    info('تم حذف السجلات الأقدم من $duration');
  }

  /// حذف السجلات من نوع معين
  void clearLogsByLevel(LogLevel level) {
    _logs.removeWhere((log) => log.level == level.name.toUpperCase());
    info('تم حذف سجلات من نوع ${level.name}');
  }

  /// الحصول على إحصائيات السجلات
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final entry in _logs) {
      stats[entry.level] = (stats[entry.level] ?? 0) + 1;
    }
    return stats;
  }

  /// تصدير السجلات كـ JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _logs.map((log) => log.toJson()).toList();
  }

  /// تصدير السجلات كـ CSV
  String exportAsCSV() {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Level,Message,Context,StackTrace');
    
    for (final log in _logs) {
      buffer.writeln(
        '"${log.timestamp.toIso8601String()}",'
        '"${log.level}",'
        '"${log.message.replaceAll('"', '""')}",'
        '"${(log.context ?? '').replaceAll('"', '""')}",'
        '"${(log.stackTrace ?? '').replaceAll('"', '""')}"',
      );
    }
    
    return buffer.toString();
  }

  /// الحصول على عدد السجلات
  int getLogCount() => _logs.length;

  /// الحصول على آخر n من السجلات
  List<LogEntry> getLastLogs(int count) {
    if (_logs.isEmpty) return [];
    final startIndex = (_logs.length - count).clamp(0, _logs.length);
    return _logs.sublist(startIndex);
  }

  /// تسجيل معلومات الحدث المهمة
  void logEvent(String eventName, {Map<String, dynamic>? data}) {
    final message = '📌 Event: $eventName';
    final context = data != null ? data.toString() : null;
    info(message, context: context);
  }

  /// تسجيل خطأ الملاحة
  void logNavigation(String from, String to) {
    info('🔄 Navigation: $from → $to', context: 'Navigation');
  }

  /// تسجيل خطأ API
  void logApiError(String endpoint, int? statusCode, String? errorMsg) {
    error(
      'API Error: $endpoint (Status: $statusCode)',
      context: 'API',
      stackTrace: StackTrace.current,
    );
  }

  /// تسجيل خطأ قاعدة البيانات
  void logDatabaseError(String operation, String? errorMsg) {
    error(
      'Database Error: $operation - $errorMsg',
      context: 'Database',
      stackTrace: StackTrace.current,
    );
  }

  /// تسجيل خطأ الموقع
  void logLocationError(String? errorMsg) {
    warning(
      'Location Error: $errorMsg',
      context: 'Location',
    );
  }

  /// طباعة ملخص السجلات
  void printSummary() {
    final stats = getStatistics();
    print('''
╔════════════════════════════════════════╗
║          LOG SUMMARY                   ║
╚════════════════════════════════════════╝
Total Logs: ${getLogCount()}
${stats.entries.map((e) => '${e.key}: ${e.value}').join('\n')}
    ''');
  }

  /// إيقاف خدمة السجل وتنظيف الموارد
  Future<void> dispose() async {
    try {
      info('❌ تطبيق SERA تم إيقافه');
      // يمكن إضافة عمليات حفظ إضافية هنا
    } catch (e) {
      print('❌ خطأ في إيقاف خدمة السجل: $e');
    }
  }
}

/// مثيل عام لـ LoggerService للاستخدام السريع
final logger = LoggerService();
