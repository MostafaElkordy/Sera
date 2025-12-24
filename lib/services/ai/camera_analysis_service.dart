import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_config.dart';

/// Camera Analysis Service for SERA App
/// Handles camera capture and image processing for AI analysis
class CameraAnalysisService {
  static CameraAnalysisService? _instance;
  static CameraAnalysisService get instance =>
      _instance ??= CameraAnalysisService._();

  CameraAnalysisService._();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  Timer? _analysisTimer;

  bool _isAnalyzing = false;
  bool _isInitialized = false;

  // Callbacks
  Function(Uint8List frame, String analysis)? onFrameAnalyzed;
  Function(String error)? onError;
  Function(bool)? onAnalysisStateChanged;

  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  CameraController? get controller => _controller;

  /// Initialize camera
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        onError?.call('صلاحية الكاميرا مرفوضة');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        onError?.call('لا توجد كاميرات متاحة');
        return false;
      }

      // Use back camera by default
      final camera = _cameras!.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;

      debugPrint('✅ CameraAnalysisService initialized successfully');
      return true;
    } catch (e) {
      onError?.call('خطأ في تهيئة الكاميرا: $e');
      debugPrint('❌ CameraAnalysisService initialization failed: $e');
      return false;
    }
  }

  /// Start camera preview
  Future<void> startCamera() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Capture a single image
  Future<File?> captureImage() async {
    if (!_isInitialized || _controller == null) {
      onError?.call('الكاميرا غير مهيئة');
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return File(image.path);
    } catch (e) {
      onError?.call('خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  /// Start continuous analysis (for disaster scenarios)
  Future<void> startContinuousAnalysis({
    required Future<String> Function(Uint8List) analyzeCallback,
    Duration interval = AppConfig.analysisInterval,
  }) async {
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    onAnalysisStateChanged?.call(true);

    _analysisTimer = Timer.periodic(interval, (timer) async {
      if (!_isAnalyzing) {
        timer.cancel();
        return;
      }

      try {
        final imageFile = await captureImage();
        if (imageFile == null) return;

        final imageBytes = await imageFile.readAsBytes();
        final compressedBytes = await _compressImage(imageBytes);

        final analysis = await analyzeCallback(compressedBytes);

        onFrameAnalyzed?.call(compressedBytes, analysis);

        // Delete temp file
        await imageFile.delete();
      } catch (e) {
        debugPrint('خطأ في التحليل المستمر: $e');
      }
    });
  }

  /// Stop continuous analysis
  void stopContinuousAnalysis() {
    _isAnalyzing = false;
    _analysisTimer?.cancel();
    _analysisTimer = null;
    onAnalysisStateChanged?.call(false);
  }

  /// Compress image for API
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize if too large
      if (image.width > 800 || image.height > 800) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
        );
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    } catch (e) {
      debugPrint('خطأ في ضغط الصورة: $e');
      return imageBytes;
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      onError?.call('لا توجد كاميرا أخرى متاحة');
      return;
    }

    final currentIndex = _cameras!.indexOf(_controller!.description);
    final newIndex = (currentIndex + 1) % _cameras!.length;

    await dispose();

    _controller = CameraController(
      _cameras![newIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  /// Cleanup
  Future<void> dispose() async {
    stopContinuousAnalysis();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
