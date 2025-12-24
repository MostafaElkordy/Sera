import 'package:flutter/foundation.dart';
import '../services/ai/gemini_service.dart';
import '../services/ai/voice_service.dart';

/// AI Assistant Provider for SERA App
/// Manages voice assistant state and AI conversations
class AiAssistantProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService.instance;
  final VoiceService _voiceService = VoiceService.instance;

  // State
  List<ChatMessage> _messages = [];
  String _currentTranscript = '';
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _isContinuousMode = true; // Auto-listen enabled by default
  String? _errorMessage;
  String _currentEmergencyType = '';

  // Getters
  List<ChatMessage> get messages => _messages;
  String get currentTranscript => _currentTranscript;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;
  bool get isContinuousMode => _isContinuousMode;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isListening || _isSpeaking || _isProcessing;

  AiAssistantProvider() {
    _setupVoiceCallbacks();
  }

  void _setupVoiceCallbacks() {
    _voiceService.onSpeechResult = (text) {
      _currentTranscript = text;
      notifyListeners();
    };

    _voiceService.onListeningStateChanged = (isListening) {
      _isListening = isListening;
      notifyListeners();

      // Auto-Submit on Silence (Continuous Mode)
      if (!isListening && _isContinuousMode && !_isSpeaking && !_isProcessing) {
        if (_currentTranscript.isNotEmpty) {
          debugPrint(
              '🔄 Silence detected. Auto-submitting: $_currentTranscript');
          stopListeningAndProcess(); // This submits and clears transcript
        } else {
          debugPrint(
              '🔄 Silence detected (No Speech). Restarting listening...');
          // Optional: If silence but no speech, maybe ask "Are you there?" or just listen again?
          // For now, let's just listen again to keep the loop alive.
          // Warning: Be careful of infinite loops without speech.
          // startListening(); // DISABLED for now to avoid rapid quota drain on background noise.
        }
      }
    };

    _voiceService.onSpeakingStateChanged = (isSpeaking) {
      _isSpeaking = isSpeaking;
      notifyListeners();
    };

    _voiceService.onError = (error) {
      _errorMessage = error;
      notifyListeners();
    };
  }

  /// Start a new conversation for an emergency type
  Future<void> startConversation(String emergencyType) async {
    _currentEmergencyType = emergencyType;
    _messages.clear();
    _errorMessage = null;

    // Initialize services
    await _geminiService.initialize();
    await _voiceService.initialize();

    // Get initial greeting
    _isProcessing = true;
    notifyListeners();

    final greeting = await _geminiService.getEmergencyGuidance(
      emergencyType: emergencyType,
      userMessage: 'ابدأ بتحية وسؤال عن الحالة',
    );

    _messages.add(ChatMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _isProcessing = false;
    notifyListeners();

    // Speak the greeting
    await _voiceService.speak(greeting);
  }

  /// Start listening to user
  Future<void> startListening() async {
    _errorMessage = null;
    _currentTranscript = '';
    await _voiceService.startListening();
  }

  /// Stop listening and process the input
  Future<void> stopListeningAndProcess() async {
    await _voiceService.stopListening();

    if (_currentTranscript.isNotEmpty) {
      await _processUserMessage(_currentTranscript);
      _currentTranscript = '';
    }
  }

  /// Process user message and get AI response
  Future<void> _processUserMessage(String message) async {
    // Add user message
    _messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _isProcessing = true;
    notifyListeners();

    // Get AI response
    final conversationHistory = _messages
        .map((m) => '${m.isUser ? "المستخدم" : "المساعد"}: ${m.text}')
        .toList();

    final response = await _geminiService.getEmergencyGuidance(
      emergencyType: _currentEmergencyType,
      userMessage: message,
      conversationHistory: conversationHistory,
    );

    _messages.add(ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _isProcessing = false;
    notifyListeners();

    // Speak the response
    await _voiceService.speak(response);
  }

  /// Send text message (without voice)
  Future<void> sendTextMessage(String message) async {
    if (message.isEmpty) return;
    await _processUserMessage(message);
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }

  void toggleContinuousMode() {
    _isContinuousMode = !_isContinuousMode;
    notifyListeners();
    if (!_isContinuousMode) {
      _voiceService.stopListening();
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset conversation
  void reset() {
    _messages.clear();
    _currentTranscript = '';
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
