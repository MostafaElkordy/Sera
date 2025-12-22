// دمج SOS مع واجهات التطبيق
// مصدر مفيد لدمج SOS Activation مع UI Components

import 'package:flutter/material.dart';

// استيراد من services
import '../services/sos_activation_manager.dart';
import '../services/audio_service.dart';

class SosIntegrationHelper {
  // دالة مساعدة لتفعيل SOS من زر
  static Future<void> activateSosFromButton(
    BuildContext context, {
    String? userMessage,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    try {
      // عرض حوار التأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text(
            'تأكيد تفعيل SOS',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'هل تريد تفعيل تنبيه الطوارئ؟\nسيتم إخطار جهات الاتصال الطارئة فوراً.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // تفعيل SOS - سيتم استدعاء sosActivationManager هنا
      onSuccess?.call();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل SOS بنجاح - يتم إخطار الطوارئ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      onFailure?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // دالة لإلغاء SOS
  static Future<void> cancelSosAlert(BuildContext context) async {
    final success = await sosActivationManager.cancelCurrentSos();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم إلغاء تنبيه SOS' : 'فشل في إلغاء SOS'),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  // دالة لعرض سجل SOS
  static void showSosHistory(BuildContext context) {
    final sosService = sosActivationManager;
    final alerts = sosService.getCurrentSos() != null
      ? [sosService.getCurrentSos()]
      : <dynamic>[];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'سجل SOS',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: alerts.isEmpty
              ? const Text(
                  'لا توجد تنبيهات SOS',
                  style: TextStyle(color: Colors.grey),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    if (alert == null) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${alert.id}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            'الحالة: ${alert.status}',
                            style: TextStyle(color: Colors.blue[300], fontSize: 11),
                          ),
                          Text(
                            'الوقت: ${alert.timestamp}',
                            style: TextStyle(color: const Color.fromARGB(255, 189, 189, 189), fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // دالة لبناء زر SOS محسّن
  static Widget buildEnhancedSosButton({
    required BuildContext context,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return ScaleTransition(
      scale: AlwaysStoppedAnimation(isActive ? 1.1 : 1.0),
      child: GestureDetector(
        onLongPress: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withValues(alpha: isActive ? 0.8 : 0.5),
                blurRadius: isActive ? 20 : 10,
                spreadRadius: isActive ? 5 : 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            heroTag: 'sos_button',
            onPressed: onPressed,
            child: const Icon(Icons.emergency, size: 32),
          ),
        ),
      ),
    );
  }

  // دالة للتحقق من وجود SOS نشط
  static bool hasActiveSos() {
    return sosActivationManager.hasActiveSos();
  }

  // دالة لاختبار الأصوات
  static Future<void> testSosSound() async {
    await audioService.playSosAlert();
  }

  // دالة لتسجيل callback لتتبع SOS
  static void onSosStatusChanged(Function(SosActivationResult) callback) {
    sosActivationManager.registerCallback((result) async {
      callback(result);
    });
  }

  // دالة للحصول على معلومات SOS الحالي
  static Map<String, dynamic> getCurrentSosInfo() {
    final current = sosActivationManager.getCurrentSos();
    if (current == null) {
      return {'active': false};
    }

    return {
      'active': true,
      'id': current.id,
      'status': current.status,
      'timestamp': current.timestamp.toIso8601String(),
      'location': current.latitude != null && current.longitude != null
          ? '${current.latitude},${current.longitude}'
          : null,
      'message': current.message,
    };
  }

  // دالة لإعادة تعيين SOS (للاختبار فقط)
  static void resetSosForTesting() {
    sosActivationManager.resetForTesting();
  }
}

// مثال على الاستخدام في Screen
class ExampleSosUsage {
  static Widget buildExample(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () {
        SosIntegrationHelper.activateSosFromButton(
          context,
          userMessage: 'ضغطت على زر SOS',
          onSuccess: () {
            print('✅ SOS activated successfully');
          },
          onFailure: () {
            print('❌ SOS activation failed');
          },
        );
      },
      child: const Icon(Icons.emergency),
    );
  }
}
