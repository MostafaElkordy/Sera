import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_analysis_provider.dart';

/// Camera Analysis Screen for Disasters
/// Real-time camera analysis with AI guidance
class CameraAnalysisScreen extends StatefulWidget {
  final String disasterType;
  final String disasterTitle;

  const CameraAnalysisScreen({
    super.key,
    required this.disasterType,
    required this.disasterTitle,
  });

  @override
  State<CameraAnalysisScreen> createState() => _CameraAnalysisScreenState();
}

class _CameraAnalysisScreenState extends State<CameraAnalysisScreen> {
  bool _isAnalysisActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    final provider = context.read<CameraAnalysisProvider>();
    await provider.initialize(widget.disasterType);
  }

  Future<void> _toggleAnalysis() async {
    final provider = context.read<CameraAnalysisProvider>();

    if (_isAnalysisActive) {
      await provider.stopAnalysis();
      setState(() => _isAnalysisActive = false);
    } else {
      await provider.startDisasterAnalysis();
      setState(() => _isAnalysisActive = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.disasterTitle),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<CameraAnalysisProvider>().stopAnalysis();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<CameraAnalysisProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'جاري تهيئة الكاميرا...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeCamera,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Camera Preview
              if (provider.controller != null)
                Positioned.fill(
                  child: CameraPreview(provider.controller!),
                ),

              // Analysis overlay grid
              if (_isAnalysisActive)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AnalysisOverlayPainter(),
                  ),
                ),

              // Active analysis indicator
              if (provider.isAnalyzing)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'التحليل نشط',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Analysis Panel
              if (provider.currentAnalysis != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 140,
                  child: _AnalysisPanel(
                    analysis: provider.currentAnalysis!,
                    isAnalyzing: provider.isAnalyzing,
                  ),
                ),

              // Control Panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ControlPanel(
                  isAnalysisActive: _isAnalysisActive,
                  onToggleAnalysis: _toggleAnalysis,
                  onCaptureAndAnalyze: () => provider.captureAndAnalyze(),
                  onSwitchCamera: () => provider.switchCamera(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Analysis panel showing AI results
class _AnalysisPanel extends StatelessWidget {
  final String analysis;
  final bool isAnalyzing;

  const _AnalysisPanel({
    required this.analysis,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnalyzing ? Colors.orange : Colors.white.withAlpha(75),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isAnalyzing ? Icons.radar : Icons.check_circle,
                  color: isAnalyzing ? Colors.orange : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isAnalyzing ? 'جاري التحليل...' : 'نتيجة التحليل',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              analysis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Control panel at bottom
class _ControlPanel extends StatelessWidget {
  final bool isAnalysisActive;
  final VoidCallback onToggleAnalysis;
  final VoidCallback onCaptureAndAnalyze;
  final VoidCallback onSwitchCamera;

  const _ControlPanel({
    required this.isAnalysisActive,
    required this.onToggleAnalysis,
    required this.onCaptureAndAnalyze,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main toggle button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onToggleAnalysis,
                icon: Icon(
                  isAnalysisActive ? Icons.stop : Icons.play_arrow,
                  size: 28,
                ),
                label: Text(
                  isAnalysisActive ? 'إيقاف التحليل' : 'بدء التحليل',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAnalysisActive ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCaptureAndAnalyze,
                    icon: const Icon(Icons.camera),
                    label: const Text('التقاط'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSwitchCamera,
                    icon: const Icon(Icons.flip_camera_ios),
                    label: const Text('تبديل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay painter for analysis grid
class _AnalysisOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw 3x3 grid
    for (int i = 1; i < 3; i++) {
      // Horizontal lines
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
      // Vertical lines
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
    }

    // Outer frame
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..color = Colors.orange.withAlpha(125),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
