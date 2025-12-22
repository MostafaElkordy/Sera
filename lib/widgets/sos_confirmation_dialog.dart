// حوار تأكيد SOS مع عداد تنازلي

import 'package:flutter/material.dart';
import 'dart:async';

class SosConfirmationDialog extends StatefulWidget {
  final String? locationText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final int countdownSeconds;

  const SosConfirmationDialog({
    Key? key,
    this.locationText,
    required this.onConfirm,
    required this.onCancel,
    this.countdownSeconds = 15,
  }) : super(key: key);

  @override
  State<SosConfirmationDialog> createState() => _SosConfirmationDialogState();
}

class _SosConfirmationDialogState extends State<SosConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;

    // إعداد الرسم المتحرك
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // بدء العداد التنازلي
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer.cancel();
        widget.onConfirm();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade700, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة SOS المتحركة
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // العنوان
            const Text(
              'تأكيد تنبيه الطوارئ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // الرسالة
            Text(
              'سيتم إرسال طلب المساعدة لجهات الاتصال الطارئة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 20),

            // معلومات الموقع
            if (widget.locationText != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.locationText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // العداد التنازلي
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade700),
              ),
              child: Column(
                children: [
                  const Text(
                    'سيتم الإرسال خلال',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 224, 224, 224),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_remainingSeconds ثانية',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // الأزرار
            Row(
              children: [
                // زر الإلغاء
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      widget.onCancel();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),

                // زر التأكيد
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      widget.onConfirm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('تأكيد'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // تحذير
            Text(
              'لا تقم بإلغاء التنبيه إلا إذا كنت بأمان',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// دالة مساعدة لعرض حوار SOS
Future<bool?> showSosConfirmationDialog(
  BuildContext context, {
  String? locationText,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
  int countdownSeconds = 15,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SosConfirmationDialog(
      locationText: locationText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      countdownSeconds: countdownSeconds,
    ),
  );
}
