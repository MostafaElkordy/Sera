import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';
import '../utils/screen_utils.dart';

class SosButton extends StatefulWidget {
  final double? size;

  const SosButton({super.key, this.size});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SosProvider>(context);
    // Increase default size slightly if it was too small, but ScreenUtils.w(40) assumes certain scaling.
    // Assuming w(40) is logical relative width. Let's keep existing size base to avoid breaking layout,
    // but the new design might need to differ slightly in internal proportions.
    final buttonSize = widget.size ??
        ScreenUtils.w(
            50); // Increased slightly for better visibility of inner text
    final isPressed = sosProvider.isCountingDown; // Active state

    return GestureDetector(
      onLongPressStart: (_) {
        HapticFeedback.mediumImpact();
        sosProvider.startSosSequence();
        _showCountdownDialog(context);
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale =
              isPressed ? 0.95 : (1.0 + _pulseController.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // The "Border" is actually the background container
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFD32F2F), // Red 700
                    Color(0xFFB71C1C), // Red 900
                  ],
                  stops: [0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: isPressed ? 0.6 : 0.3),
                    blurRadius: buttonSize * 0.3,
                    spreadRadius: buttonSize * 0.05,
                  ),
                ],
              ),
              // This padding creates the visual "thickness" of the red border
              padding: EdgeInsets.all(buttonSize * 0.18),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Inner white circle
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: buttonSize * 0.32,
                      color: const Color(0xFFC62828),
                    ),
                    SizedBox(height: buttonSize * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: buttonSize * 0.03,
                          vertical: buttonSize * 0.005),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.red.shade900, width: 1),
                        borderRadius: BorderRadius.circular(buttonSize * 0.1),
                      ),
                      child: Text(
                        'Press & Hold',
                        style: TextStyle(
                          fontSize: buttonSize * 0.035,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCountdownDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => const SosCountdownDialog(),
    );
  }
}

class SosCountdownDialog extends StatefulWidget {
  const SosCountdownDialog({super.key});

  @override
  State<SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<SosCountdownDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SosProvider>(
      builder: (context, provider, child) {
        // --- Logic to Handle State Changes ---
        // We use SchedulerBinding to avoid setState during build errors
        if (provider.isIdle) {
          // If became idle (cancelled or finished), close dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              // Check if it was a cancellation to show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء إرسال الاستغاثة'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        } else if (provider.state == SosState.sending ||
            provider.state == SosState.finished) {
          // Sequence finished successfully
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال نداء الاستغاثة بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تم تفعيل وضع الاستغاثة',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'سيتم إرسال تنبيه استغاثة لجهات الطوارئ وموقعك الحالي خلال:',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Countdown Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: 1.0 - provider.progress, // Inverse progress
                        strokeWidth: 8,
                        color: Colors.red,
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${provider.countdownValue}',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        const Text(
                          'ثانية',
                          style:
                              TextStyle(fontSize: 12, color: Colors.redAccent),
                        )
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.cancelSosSequence();
                      // Dialog auto-closes due to listener above
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إلغاء الآن',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
