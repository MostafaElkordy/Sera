// دمج SOS مع واجهات التطبيق
// توثيق وأمثلة على دمج SOS في الشاشات

class SosIntegrationGuide {
  static const String INTEGRATION_DOCUMENTATION = '''
╔════════════════════════════════════════════════════════════════════╗
║                  SOS INTEGRATION GUIDE                            ║
╚════════════════════════════════════════════════════════════════════╝

🎯 كيفية استخدام SosActivationManager:

1️⃣ تفعيل SOS:
   final result = await sosActivationManager.activateSos(
     userMessage: 'رسالة الطوارئ',
     includeLocation: true,
     playSound: true,
     saveToHistory: true,
   );
   
   if (result.success) {
     // عرض رسالة النجاح
   } else {
     // عرض رسالة الخطأ: result.error
   }

2️⃣ إلغاء SOS:
   final result = await sosActivationManager.cancelCurrentSos();

3️⃣ الحصول على SOS الحالي:
   final currentSos = sosActivationManager.getCurrentSos();
   if (currentSos != null) {
     print('SOS نشط: \${currentSos.id}');
   }

4️⃣ التحقق من وجود SOS نشط:
   if (sosActivationManager.hasActiveSos()) {
     // يوجد SOS نشط
   }

5️⃣ تسجيل callback لتتبع التغييرات:
   sosActivationManager.registerCallback((result) async {
     print('SOS Status: \${result.success}');
   });

📱 المزامجة مع زر SOS:

في SosButton:
- الضغط الطويل (1500ms) → عرض حوار تأكيد
- زر تأكيد → استدعاء activateSos()
- زر إلغاء → استدعاء cancelCurrentSos()

💬 الحصول على الموقع:

await locationService.getCurrentLocation()
  .then((location) => {
    latitude: location?.latitude,
    longitude: location?.longitude,
  });

🔊 تشغيل الأصوات:

await audioService.playSosAlert(); // صوت SOS المستمر
await audioService.playSuccess();  // صوت النجاح
await audioService.playError();    // صوت الخطأ

📝 حفظ السجل:

السجل يُحفظ تلقائياً في:
- persistence.addSosToHistory()
- sosService.getSosHistory()

📊 الإحصائيات:

sosService.getSosStatistics() → {
  'total_alerts': int,
  'active_alerts': int,
  'resolved_alerts': int,
  'failed_alerts': int,
  'current_active': string,
}

🔄 إعادة محاولة:

await sosService.retryOperation(sosId);

⚠️ معالجة الأخطاء:

try {
  final result = await sosActivationManager.activateSos();
  if (!result.success) {
    // خطأ في التفعيل: result.error
  }
} catch (e) {
  // استثناء غير متوقع
}

✅ شيك لست التكامل:

☐ تم استيراد SosActivationManager
☐ تم استيراد LocationService
☐ تم استيراد AudioService
☐ تم استيراد NotificationService
☐ تم ربط SOS button مع activateSos()
☐ تم عرض حوار التأكيد
☐ تم معالجة الأخطاء
☐ تم تسجيل callbacks
☐ تم اختبار على الجهاز
☐ تم التحقق من الصوت والاهتزاز
''';

  static void printGuide() {
    print(INTEGRATION_DOCUMENTATION);
  }

  static Map<String, dynamic> getIntegrationChecklist() {
    return {
      'sos_activation_manager': 'implemented ✓',
      'sos_service': 'implemented ✓',
      'location_service': 'implemented ✓',
      'audio_service': 'implemented ✓',
      'notification_service': 'implemented ✓',
      'sos_button': 'needs ui update',
      'home_screen': 'needs sos button binding',
      'error_handling': 'implemented ✓',
      'logging': 'implemented ✓',
      'testing': 'ready for qa',
    };
  }

  static const String USAGE_EXAMPLE = '''
// Example: SOS Button Integration

class SosButton extends StatefulWidget {
  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  bool _isHolding = false;
  DateTime? _pressStartTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onSosLongPressStart(),
      onLongPressEnd: (_) => _onSosLongPressEnd(),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _onSosPressed(context),
        child: const Icon(Icons.emergency),
      ),
    );
  }

  void _onSosLongPressStart() {
    _pressStartTime = DateTime.now();
    _isHolding = true;
  }

  void _onSosLongPressEnd() {
    _isHolding = false;
    
    final duration = DateTime.now().difference(_pressStartTime!);
    if (duration.inMilliseconds >= 1500) {
      _showSosConfirmation(context);
    }
  }

  void _onSosPressed(BuildContext context) {
    _showSosConfirmation(context);
  }

  Future<void> _showSosConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد SOS'),
        content: const Text('هل تريد تفعيل تنبيه الطوارئ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await sosActivationManager.activateSos();
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    }
  }
}
''';
}

void main() {
  SosIntegrationGuide.printGuide();
  
  print('\n📋 Integration Checklist:');
  SosIntegrationGuide.getIntegrationChecklist().forEach((task, status) {
    print('  ☐ $task: $status');
  });
  
  print('\n💻 Example Code:');
  print(SosIntegrationGuide.USAGE_EXAMPLE);
}
