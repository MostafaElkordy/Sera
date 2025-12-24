import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_config.dart';

/// Voice Service for SERA App
/// Handles Speech-to-Text and Text-to-Speech
class VoiceService {
  static VoiceService? _instance;
  static VoiceService get instance => _instance ??= VoiceService._();

  VoiceService._();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  // Callbacks
  Function(String)? onSpeechResult;
  Function(String)? onError;
  Function(bool)? onListeningStateChanged;
  Function(bool)? onSpeakingStateChanged;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  bool get isBusy => _isListening || _isSpeaking;

  /// Initialize voice services
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        onError?.call('صلاحية الميكروفون مرفوضة');
        return false;
      }

      // Initialize Speech to Text
      final sttAvailable = await _speechToText.initialize(
        onError: (error) =>
            onError?.call('خطأ في التعرف على الصوت: ${error.errorMsg}'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );

      if (!sttAvailable) {
        onError?.call('ميزة التعرف على الصوت غير متاحة');
        return false;
      }

      // Initialize Text to Speech
      // Try Egyptian Arabic first, then Saudi, then generic
      List<String> priorityLocales = ["ar-EG", "ar-SA", "ar"];
      bool languageSet = false;

      for (var locale in priorityLocales) {
        var isAvailable = await _flutterTts.isLanguageAvailable(locale);
        debugPrint('🔊 Checking Locale $locale: $isAvailable');
        if (isAvailable == true) {
          await _flutterTts.setLanguage(locale);
          debugPrint('✅ TTS Language set to: $locale');
          languageSet = true;
          break;
        }
      }

      if (!languageSet) {
        debugPrint(
            '⚠️ No Arabic TTS found in preferred list. Trying system default.');
      }

      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakingStateChanged?.call(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakingStateChanged?.call(false);
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        onSpeakingStateChanged?.call(false);
        onError?.call('خطأ في القراءة: $msg');
      });

      _isInitialized = true;
      debugPrint('✅ VoiceService initialized successfully');
      return true;
    } catch (e) {
      onError?.call('خطأ في التهيئة: $e');
      debugPrint('❌ VoiceService initialization failed: $e');
      return false;
    }
  }

  /// Start listening to user speech
  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) return;

    // Stop speaking if active
    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          onSpeechResult?.call(result.recognizedWords);
        },
        localeId: AppConfig.sttLocaleId,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
          autoPunctuation: true,
        ),
        pauseFor: const Duration(seconds: 2), // Auto-stop after 2s silence
      );

      _isListening = true;
      onListeningStateChanged?.call(true);
    } catch (e) {
      onError?.call('خطأ في بدء الاستماع: $e');
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    } catch (e) {
      onError?.call('خطأ في إيقاف الاستماع: $e');
    }
  }

  /// Speak text aloud
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    // Stop listening if active
    if (_isListening) {
      await stopListening();
    }

    // Stop previous speech
    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      onError?.call('خطأ في القراءة: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingStateChanged?.call(false);
    } catch (e) {
      debugPrint('خطأ في إيقاف القراءة: $e');
    }
  }

  /// Cleanup
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _isInitialized = false;
  }
}
