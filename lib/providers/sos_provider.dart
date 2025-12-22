import 'dart:async';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/audio_service.dart';
import '../services/black_box_service.dart';
import '../services/location_service.dart';
import '../services/persistence_service.dart';

enum SosState { idle, countdown, sending, active, finished }

class SosProvider extends ChangeNotifier {
  // --- State ---
  SosState _state = SosState.idle;
  int _countdownValue = AppConfig.sosCountdownDuration;
  Timer? _countdownTimer;
  double _progress = 0.0;

  // --- Services ---
  final BlackBoxService _blackBoxService = BlackBoxService();
  final PersistenceService _persistence = PersistenceService();
  // LocationService and AudioService are static/singletons usually

  // --- Getters ---
  SosState get state => _state;
  int get countdownValue => _countdownValue;
  double get progress => _progress;
  bool get isIdle => _state == SosState.idle;
  bool get isCountingDown => _state == SosState.countdown;

  // --- Actions ---

  /// Start the SOS sequence (called on long press start)
  void startSosSequence() {
    if (_state != SosState.idle) return;

    _state = SosState.countdown;
    _countdownValue = AppConfig.sosCountdownDuration;
    _progress = 0.0;
    notifyListeners();

    // Start Audio Alert
    audioService.playSosAlert();

    // Start Timer
    _countdownTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _progress += 0.1 / AppConfig.sosCountdownDuration;

      // Update integer countdown every second
      if ((_progress * AppConfig.sosCountdownDuration).toInt() >
          (AppConfig.sosCountdownDuration - _countdownValue)) {
        _countdownValue--;
        if (_countdownValue > 0) {
          // Beep every second
          audioService.playClick();
          // If vibration is needed per second:
          // HapticFeedback.selectionClick();
        }
      }

      if (_progress >= 1.0) {
        _triggerSos(); // Timer finished -> ACTION
      } else {
        notifyListeners();
      }
    });
  }

  /// Cancel sequence (called on user release before completion)
  void cancelSosSequence() {
    if (_state == SosState.countdown) {
      _countdownTimer?.cancel();
      _state = SosState.idle;
      _progress = 0.0;
      _countdownValue = AppConfig.sosCountdownDuration;
      audioService.stopAll();
      notifyListeners();
    }
  }

  /// The main action when countdown completes
  Future<void> _triggerSos() async {
    _countdownTimer?.cancel();
    _state = SosState.sending;
    notifyListeners();

    try {
      // 1. Get Location
      LocationData? position = await locationService.getCurrentLocation();
      String mapLink = position != null
          ? "https://maps.google.com/?q=${position.latitude},${position.longitude}"
          : "الموقع غير متاح";

      // 2. Prepare Message
      final contacts = await _persistence.getEmergencyContacts();
      if (contacts.isEmpty) {
        _finishSos(false);
        return;
      }

      final String message = "SOS! أحتاج مساعدة عاجلة.\nموقعي: $mapLink";
      final String recipients = contacts.map((e) => e['phone']).join(',');

      // 3. Start Black Box (Evidence)
      await _blackBoxService.startEvidenceCapture().then((evidencePaths) {
        _persistence.addSosToHistory({
          'timestamp': DateTime.now().toIso8601String(),
          'latitude': position?.latitude,
          'longitude': position?.longitude,
          'evidence': evidencePaths,
          'synced': false,
        });
      });

      // 4. Send SMS
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }

      _finishSos(true);
    } catch (e) {
      debugPrint("SOS Error: $e");
      _finishSos(false);
    }
  }

  void _finishSos(bool success) {
    _state = SosState.idle;
    _progress = 0.0;
    audioService.stopAll();
    notifyListeners();
  }
}
