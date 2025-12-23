import 'dart:async';
// For debugPrint
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';
import '../services/audio_service.dart';
// import '../services/black_box_service.dart'; // Removed - service deleted
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
  // final BlackBoxService _blackBoxService = BlackBoxService(); // Removed
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
    debugPrint("SOS BUTTON: Long press detected. Starting sequence...");
    if (_state != SosState.idle) {
      debugPrint("SOS BUTTON: State is not idle (${_state}), ignoring start.");
      return;
    }

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
        debugPrint("SOS TIMER: $_countdownValue");
        if (_countdownValue > 0) {
          // Beep every second
          audioService.playClick();
          // Precise vibration
          Vibration.vibrate(duration: 200);
        }
      }

      if (_progress >= 1.0) {
        debugPrint("SOS TIMER: Finished. Triggering action...");
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
    // Prevent double execution (Race condition or rapid timer/button triggers)
    if (_state == SosState.sending || _state == SosState.finished) {
      debugPrint("SOS TRIGGER: Ignored duplicate call.");
      return;
    }

    _countdownTimer?.cancel();
    _state = SosState.sending;
    notifyListeners();

    // Final long vibration to indicate action started
    Vibration.vibrate(duration: 1000);
    Fluttertoast.showToast(
      msg: "جاري بدء إجراءات الطوارئ...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );

    try {
      // 1. Get Location
      LocationData? position = await locationService.getCurrentLocation();
      // Shortened link without https:// to save characters
      // 4 decimals = ~11 meter precision, sufficient for emergency
      String mapLink = position != null
          ? "maps.google.com/?q=${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}"
          : "الموقع غير متاح";

      // 2. Get User's First Name & Gender
      String fullName = await _persistence.getUserName() ?? "مستخدم";
      String firstName = fullName.split(' ').first; // Take first name only

      String? gender = _persistence.getUserGender();
      // Logic: If "أنثى" -> "تحتاج", Else (Male/Null) -> "يحتاج"
      String verb = (gender == "أنثى") ? "تحتاج" : "يحتاج";

      // 3. Prepare Contacts
      final contacts = await _persistence.getEmergencyContacts();
      debugPrint("SOS CONFIRMATION: Found ${contacts.length} contacts.");
      contacts.forEach(
          (c) => debugPrint(" - Contact: ${c['name']} : ${c['phone']}"));

      if (contacts.isEmpty) {
        Fluttertoast.showToast(
            msg: "لم يتم إضافة جهات اتصال للطوارئ بعد!",
            backgroundColor: Colors.red);
        _finishSos(false);
        return;
      }

      // 4. Build Arabic SOS Message
      // Format: [FirstName] needs help + Pin + Location + SERA Signature
      // Optimized to fit in single SMS (under 70 chars for UCS-2)
      final String message =
          "$firstName $verb مساعدة عاجلة\n📍 $mapLink\n\nSERA Alert";

      // Clean phone numbers (remove spaces, dashes) & Format for Egypt
      final List<String> recipients = contacts
          .map((e) {
            String phone = e['phone'] ?? "";

            // Basic cleanup: keep only digits and leading +
            bool hasPlus = phone.startsWith('+');
            phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
            if (hasPlus) phone = '+' + phone;

            // STRICT MODE: Send exactly as stored (just clean garbage chars)
            // No strict E.164 enforcement to avoid altering user intention.

            return phone;
          })
          .where((p) => p.isNotEmpty)
          .toSet() // Deduplicate contacts
          .toList();

      debugPrint("SOS FINAL RECIPIENTS: $recipients");

      // DEBUG: Show user exactly who is receiving messages (names instead of numbers)
      final List<String> contactNames =
          contacts.map((c) => c['name'] ?? 'غير معروف').toList();
      Fluttertoast.showToast(
          msg: "جاري إرسال رسالة الاستغاثة إلى: ${contactNames.join(', ')}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueAccent);

      // 3. Start Black Box (Evidence) - DISABLED (service removed)
      // await _blackBoxService.startEvidenceCapture().then((evidencePaths) {
      _persistence.addSosToHistory({
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'evidence': '[]', // No evidence capture (feature removed)
        'synced': 0, // Store bool as int (0 = false)
      });
      // });

      // 4. Send SMS (Background with Telephony) - STRICT MODE
      Map<Permission, PermissionStatus> statuses = await [
        Permission.sms,
        Permission.phone, // Critical for Samsung/Dual SIM
      ].request();

      bool smsGranted = statuses[Permission.sms]?.isGranted ?? false;
      bool phoneGranted = statuses[Permission.phone]?.isGranted ?? false;

      debugPrint("SOS PERMISSIONS: SMS=$smsGranted, PHONE=$phoneGranted");

      if (!smsGranted || !phoneGranted) {
        Fluttertoast.showToast(
            msg: "يُرجى السماح بصلاحية الرسائل لإكمال الإرسال",
            backgroundColor: Colors.orange);
      }

      if (smsGranted && phoneGranted) {
        int sentCount = 0;

        // Channel for native calls
        const platform = MethodChannel('com.salma.sera/sms');

        for (var phone in recipients) {
          try {
            // Send using Native Method Channel (Slot -1 = Default)
            debugPrint("SOS NATIVE CALL: Sending to $phone (SIM -1)");
            await platform.invokeMethod('sendSms', {
              'phone': phone,
              'message': message,
              'simSlot': -1,
            });

            sentCount++;
            debugPrint("SMS Sent to $phone via Default SIM (Native) - SUCCESS");
          } catch (smsError) {
            debugPrint("Failed to send native SMS to $phone: $smsError");
          }
        }

        if (sentCount > 0) {
          Fluttertoast.showToast(
              msg: "تم إطلاق نداء الاستغاثة ($sentCount جهات)",
              backgroundColor: Colors.green,
              toastLength: Toast.LENGTH_LONG);
          _finishSos(true);
          return;
        } else {
          debugPrint("SOS FAIL: Tried to send but 0 messages passed.");
        }
      } else {
        debugPrint("SOS FAIL: Permissions denied.");
        Fluttertoast.showToast(
            msg: "لم يتم منح صلاحية الرسائل. يُرجى تفعيلها من إعدادات التطبيق",
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
      }

      // NO FALLBACK - STRICT MODE AS REQUESTED

      _finishSos(false); // Finished but maybe failed
    } catch (e) {
      debugPrint("SOS Error: $e");
      Fluttertoast.showToast(
          msg: "حدث خطأ غير متوقع: $e", backgroundColor: Colors.red);
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
