// Error Boundary Widget
// واجهة احتياطية توضح رسائل خطأ آمنة عند حدوث مشاكل عرضية

import 'package:flutter/material.dart';

class ErrorBoundaryData {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onHome;
  final String? errorCode;
  final DateTime timestamp;

  ErrorBoundaryData({
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onHome,
    this.errorCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ErrorBoundary extends StatelessWidget {
  final ErrorBoundaryData errorData;
  final bool isDev;

  const ErrorBoundary({
    Key? key,
    required this.errorData,
    this.isDev = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        title: const Text('حدث خطأ'),
        backgroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الخطأ
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),

              // عنوان الخطأ
              Text(
                errorData.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // رسالة الخطأ
              Text(
                errorData.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              // معلومات الخطأ (للمطورين فقط)
              if (isDev && errorData.details != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade700,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات التطوير:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (errorData.errorCode != null)
                        Text(
                          'الكود: ${errorData.errorCode}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                      if (errorData.errorCode != null)
                        const SizedBox(height: 4),
                      Text(
                        'الوقت: ${errorData.timestamp}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        errorData.details ?? 'لا توجد تفاصيل إضافية',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // الأزرار
              Column(
                children: [
                  if (errorData.onRetry != null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: errorData.onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('حاول مرة أخرى'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (errorData.onRetry != null && errorData.onHome != null)
                    const SizedBox(height: 12),
                  if (errorData.onHome != null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: errorData.onHome,
                        icon: const Icon(Icons.home),
                        label: const Text('العودة للرئيسية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (errorData.onRetry == null && errorData.onHome == null)
                    const Text(
                      'يرجى إعادة تشغيل التطبيق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 189, 189, 189),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget للقبض على الأخطاء
class SafeScreen extends StatefulWidget {
  final Widget child;
  final bool isDev;
  final VoidCallback? onHomePressed;

  const SafeScreen({
    Key? key,
    required this.child,
    this.isDev = false,
    this.onHomePressed,
  }) : super(key: key);

  @override
  State<SafeScreen> createState() => _SafeScreenState();
}

class _SafeScreenState extends State<SafeScreen> {
  ErrorBoundaryData? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorBoundary(
        errorData: _error!,
        isDev: widget.isDev,
      );
    }

    return ErrorListener(
      onError: (error) {
        setState(() {
          _error = error;
        });
      },
      onRetry: () {
        setState(() {
          _error = null;
        });
      },
      child: widget.child,
    );
  }
}

// InheritedWidget للتقاط الأخطاء
class ErrorListener extends InheritedWidget {
  final Function(ErrorBoundaryData) onError;
  final VoidCallback onRetry;

  const ErrorListener({
    Key? key,
    required this.onError,
    required this.onRetry,
    required Widget child,
  }) : super(key: key, child: child);

  static ErrorListener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ErrorListener>();
  }

  @override
  bool updateShouldNotify(ErrorListener oldWidget) {
    return onError != oldWidget.onError || onRetry != oldWidget.onRetry;
  }

  void reportError(ErrorBoundaryData error) {
    onError(error);
  }
}

// دالة مساعدة للإبلاغ عن خطأ
void reportError(
  BuildContext context,
  String title,
  String message, {
  String? details,
  VoidCallback? onRetry,
  String? errorCode,
}) {
  final errorListener = ErrorListener.of(context);
  if (errorListener != null) {
    errorListener.reportError(
      ErrorBoundaryData(
        title: title,
        message: message,
        details: details,
        onRetry: onRetry,
        errorCode: errorCode,
      ),
    );
  }
}
