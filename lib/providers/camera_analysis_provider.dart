import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../services/ai/gemini_service.dart';
import '../services/ai/camera_analysis_service.dart';
import '../services/ai/voice_service.dart';

/// Camera Analysis Provider for SERA App
/// Manages camera state and disaster scene analysis
class CameraAnalysisProvider extends ChangeNotifier {
  final CameraAnalysisService _cameraService = CameraAnalysisService.instance;
  final GeminiService _geminiService = GeminiService.instance;
  final VoiceService _voiceService = VoiceService.instance;

  // State
  String? _currentAnalysis;
  Uint8List? _lastFrame;
  bool _isAnalyzing = false;
  bool _isInitialized = false;
  String? _errorMessage;
  List<String> _analysisHistory = [];
  String _currentDisasterType = '';

  // Getters
  CameraController? get controller => _cameraService.controller;
  String? get currentAnalysis => _currentAnalysis;
  Uint8List? get lastFrame => _lastFrame;
  bool get isAnalyzing => _isAnalyzing;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  List<String> get analysisHistory => _analysisHistory;

  CameraAnalysisProvider() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _cameraService.onFrameAnalyzed = (frame, analysis) {
      _lastFrame = frame;
      _currentAnalysis = analysis;
      _analysisHistory.add(analysis);
      notifyListeners();

      // Speak the analysis
      _voiceService.speak(analysis);
    };

    _cameraService.onAnalysisStateChanged = (isAnalyzing) {
      _isAnalyzing = isAnalyzing;
      notifyListeners();
    };

    _cameraService.onError = (error) {
      _errorMessage = error;
      notifyListeners();
    };
  }

  /// Initialize camera and services
  Future<bool> initialize(String disasterType) async {
    _currentDisasterType = disasterType;
    _errorMessage = null;

    // Initialize Gemini
    await _geminiService.initialize();

    // Initialize Voice for spoken feedback
    await _voiceService.initialize();

    // Initialize Camera
    final initialized = await _cameraService.initialize();
    _isInitialized = initialized;
    notifyListeners();

    if (initialized) {
      // Welcome message
      await _voiceService.speak(
        'حرّك الكاميرا ببطء لتحليل المكان. اضغط على زر البدء عندما تكون جاهزاً.',
      );
    }

    return initialized;
  }

  /// Start camera preview
  Future<void> startCamera() async {
    await _cameraService.startCamera();
    notifyListeners();
  }

  /// Start continuous disaster analysis
  Future<void> startDisasterAnalysis() async {
    _analysisHistory.clear();

    await _voiceService.speak('بدء التحليل. حرّك الكاميرا ببطء.');

    await _cameraService.startContinuousAnalysis(
      analyzeCallback: (frameBytes) async {
        return await _geminiService.analyzeVideoFrame(
          frameBytes: frameBytes,
          scenarioType: _currentDisasterType,
          previousGuidance: _currentAnalysis,
        );
      },
      interval: const Duration(seconds: 3),
    );
  }

  /// Stop analysis
  Future<void> stopAnalysis() async {
    _cameraService.stopContinuousAnalysis();
    await _voiceService.speak('تم إيقاف التحليل');
    notifyListeners();
  }

  /// Capture and analyze a single frame
  Future<String?> captureAndAnalyze() async {
    final imageFile = await _cameraService.captureImage();
    if (imageFile != null) {
      _currentAnalysis = await _geminiService.analyzeDisasterScene(
        imageFile: imageFile,
        disasterType: _currentDisasterType,
      );
      notifyListeners();

      // Speak the analysis
      await _voiceService.speak(_currentAnalysis!);

      return _currentAnalysis;
    }
    return null;
  }

  /// Switch camera
  Future<void> switchCamera() async {
    await _cameraService.switchCamera();
    notifyListeners();
  }

  /// Clear analysis
  void clearAnalysis() {
    _currentAnalysis = null;
    _analysisHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
