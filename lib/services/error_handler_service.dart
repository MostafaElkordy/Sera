// خدمة معالجة الأخطاء المركزية
// توفر نظام موحد لمعالجة الأخطاء والاستثناءات

import 'package:flutter/foundation.dart';

// ===== الاستثناءات المخصصة =====

class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException({
    String message = 'خطأ في الشبكة',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'NETWORK_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

class LocationException extends AppException {
  LocationException({
    String message = 'خطأ في الموقع',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'LOCATION_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

class SosException extends AppException {
  SosException({
    String message = 'خطأ في تفعيل SOS',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'SOS_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

class StorageException extends AppException {
  StorageException({
    String message = 'خطأ في التخزين',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'STORAGE_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

class ValidationException extends AppException {
  ValidationException({
    String message = 'خطأ في التحقق',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'VALIDATION_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

class TimeoutException extends AppException {
  TimeoutException({
    String message = 'انتهت المهلة الزمنية',
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'TIMEOUT_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

// ===== معالج الأخطاء =====

typedef ErrorCallback = Function(AppException exception);

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final List<ErrorCallback> _errorCallbacks = [];
  bool _initialized = false;

  void initialize() {
    _initialized = true;
  }

  // تسجيل callback للأخطاء
  void registerErrorCallback(ErrorCallback callback) {
    _errorCallbacks.add(callback);
  }

  // إلغاء تسجيل callback
  void unregisterErrorCallback(ErrorCallback callback) {
    _errorCallbacks.remove(callback);
  }

  // معالجة الخطأ
  void handleException(
    Object exception, {
    StackTrace? stackTrace,
    bool shouldRethrow = false,
  }) {
    final appException = _convertToAppException(exception, stackTrace);
    
    // تنفيذ جميع callbacks المسجلة
    for (final callback in _errorCallbacks) {
      try {
        callback(appException);
      } catch (e) {
        debugPrint('Error in callback: $e');
      }
    }

    if (shouldRethrow) {
      rethrowException(appException, stackTrace);
    }
  }

  // معالجة الخطأ بشكل آمن
  Future<T?> safeCall<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleException(error, stackTrace: stackTrace, shouldRethrow: shouldRethrow);
      return defaultValue;
    }
  }

  // إعادة رمي الاستثناء
  void rethrowException(Object exception, StackTrace? stackTrace) {
    if (exception is AppException) {
      throw exception;
    }
    if (stackTrace != null) {
      Error.throwWithStackTrace(exception, stackTrace);
    } else {
      throw exception;
    }
  }

  // الحصول على رسالة صديقة للمستخدم
  String getUserFriendlyMessage(AppException exception) {
    switch (exception.code) {
      case 'NETWORK_ERROR':
        return 'فشل الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.';
      case 'LOCATION_ERROR':
        return 'فشل في الحصول على موقعك. تحقق من أذونات الموقع.';
      case 'SOS_ERROR':
        return 'فشل في تفعيل تنبيه الطوارئ. يرجى المحاولة مرة أخرى.';
      case 'STORAGE_ERROR':
        return 'فشل في حفظ البيانات. تحقق من المساحة المتاحة.';
      case 'VALIDATION_ERROR':
        return 'البيانات المدخلة غير صحيحة.';
      case 'TIMEOUT_ERROR':
        return 'استغرقت العملية وقتاً طويلاً. يرجى المحاولة مرة أخرى.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';
    }
  }

  // تسجيل الخطأ
  void logError(AppException exception) {
    debugPrint('''
╔════════════════════════════════════╗
║         ERROR LOG                  ║
╚════════════════════════════════════╝
Time: ${exception.timestamp}
Code: ${exception.code ?? 'UNKNOWN'}
Message: ${exception.message}
Original Error: ${exception.originalError}
    ''');
  }

  // المحاولة مع إعادة المحاولة
  Future<T> tryWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    dynamic lastError;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(delay);
        }
      }
    }

    throw _convertToAppException(
      lastError,
      null,
      'فشلت العملية بعد $maxRetries محاولات',
    );
  }

  // تحويل الاستثناء إلى AppException
  AppException _convertToAppException(
    Object exception,
    StackTrace? stackTrace,
    [String? customMessage]
  ) {
    if (exception is AppException) {
      return exception;
    }

    if (exception is FormatException) {
      return ValidationException(
        message: customMessage ?? exception.message,
        error: exception,
        stackTrace: stackTrace,
      );
    }

    return AppException(
      message: customMessage ?? exception.toString(),
      originalError: exception,
      stackTrace: stackTrace,
    );
  }

  // الحصول على جميع callbacks
  List<ErrorCallback> getAllCallbacks() => List.from(_errorCallbacks);

  // مسح جميع callbacks
  void clearAllCallbacks() => _errorCallbacks.clear();

  // التحقق من التهيئة
  bool isInitialized() => _initialized;
}

// إنشاء instance عام
final errorHandler = ErrorHandler();
