import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class BlackBoxService {
  static final BlackBoxService _instance = BlackBoxService._internal();
  factory BlackBoxService() => _instance;
  BlackBoxService._internal();

  List<CameraDescription> _cameras = [];
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _cameras = await availableCameras();
      _isInitialized = true;
    } catch (e) {
      debugPrint('BlackBox init error: $e');
    }
  }

  Future<List<String>> startEvidenceCapture() async {
    List<String> evidencePaths = [];

    try {
      // 1. Start Audio Recording (10 seconds)
      // Note: We start it and let it run, returning the path immediately effectively,
      // but usually we want to capture images while audio records.
      // For this implementation, we will act fast.

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Photos
      if (_cameras.isNotEmpty) {
        // Try Back Camera
        final backCam = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
        String? backPhoto = await _takePhoto(backCam, '$timestamp\_back.jpg');
        if (backPhoto != null) evidencePaths.add(backPhoto);

        // Try Front Camera
        final frontCam = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
        // Only take if different from first one or if we specifically found a front one
        if (frontCam != backCam) {
          String? frontPhoto =
              await _takePhoto(frontCam, '$timestamp\_front.jpg');
          if (frontPhoto != null) evidencePaths.add(frontPhoto);
        }
      }

      // Audio
      final audioPath = '${dir.path}/$timestamp\_audio.m4a';
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: audioPath);
        // We let it record for 10 seconds?
        // Logic: The caller might want to stop it later, or we wait here.
        // User requested "10 seconds automatic".
        await Future.delayed(const Duration(seconds: 10));
        await _audioRecorder.stop();
        evidencePaths.add(audioPath);
      }
    } catch (e) {
      debugPrint('BlackBox Capture Error: $e');
    }

    return evidencePaths;
  }

  Future<String?> _takePhoto(CameraDescription camera, String fileName) async {
    CameraController? controller;
    try {
      controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      // Capture
      final file = await controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final savedPath = '${dir.path}/$fileName';
      await file.saveTo(savedPath);

      await controller.dispose();
      return savedPath;
    } catch (e) {
      debugPrint('Photo Error: $e');
      await controller?.dispose();
      return null;
    }
  }
}

final blackBoxService = BlackBoxService();
