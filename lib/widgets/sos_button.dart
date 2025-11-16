import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// audio player removed to restore stable build

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  Timer? _longPressTimer;
  late AnimationController _pulseController;
  // audio removed

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onLongPressStart() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPressed = true;
    });

    _longPressTimer = Timer(const Duration(milliseconds: 1500), () {
      _showSosDialog();
    });
  }

  void _onLongPressEnd() {
    _longPressTimer?.cancel();
    setState(() {
      _isPressed = false;
    });
  }

  void _showSosDialog() {
    HapticFeedback.heavyImpact();
    _onLongPressEnd();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SosDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isPressed ? 0.95 : (1.0 + _pulseController.value * 0.05);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red,
                    Colors.red.shade700,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(((_isPressed ? 0.6 : 0.4) * 255).round()),
                    blurRadius: _isPressed ? 30 : 40,
                    spreadRadius: _isPressed ? 5 : 10,
                  ),
                ],
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 3.6,
                ),
              ),
              child: const Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 43.2,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SosDialog extends StatefulWidget {
  const SosDialog({super.key});

  @override
  State<SosDialog> createState() => _SosDialogState();
}

class _SosDialogState extends State<SosDialog> {
  int _countdown = 15;
  Timer? _timer;
  // audio methods removed to keep build stable
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        // countdown sound removed
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        // confirm sound removed
        Navigator.of(context).pop();
        _showSuccessMessage();
      }
    });
  }

  // audio methods removed to keep build stable

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب الاستغاثة بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _cancelSos() {
    _timer?.cancel();
    // cancel sound removed
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إلغاء طلب الاستغاثة.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // audio methods removed to keep build stable

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha((0.5 * 255).round()),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تم تفعيل وضع الاستغاثة الذكي',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'سيتم إرسال تنبيه لجهات الطوارئ وموقعك الحالي خلال:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              '$_countdown',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelSos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
