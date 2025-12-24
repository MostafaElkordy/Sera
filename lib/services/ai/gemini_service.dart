import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

/// Gemini AI Service for SERA App
/// Uses secure API key loading via --dart-define
class GeminiService {
  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GeminiService._();

  GenerativeModel? _model;
  GenerativeModel? _visionModel;
  bool _isInitialized = false;

  // Secure API Key loading
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  bool get isInitialized => _isInitialized;

  /// Initialize Gemini models
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_apiKey.isEmpty) {
      debugPrint('⚠️ GEMINI_API_KEY not provided via --dart-define');
      debugPrint('   Run: flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY');
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
      );

      _visionModel = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: _apiKey,
      );

      _isInitialized = true;
      debugPrint('✅ GeminiService initialized successfully');

      // Auto-discover valid model
      await _configureBestAvailableModel();
    } catch (e) {
      debugPrint('❌ GeminiService initialization failed: $e');
    }
  }

  Future<void> _configureBestAvailableModel() async {
    try {
      debugPrint('🔍 Auto-discovering best Gemini model...');
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonData = jsonDecode(responseBody);
        final models = jsonData['models'] as List;

        // Find best text model
        String? bestTextModel;

        // First pass: Prefer 1.5 Flash
        for (var m in models) {
          final name = m['name'].toString().replaceFirst('models/', '');
          if (name.contains('1.5-flash') &&
              m['supportedGenerationMethods'].contains('generateContent')) {
            bestTextModel = name;
            break;
          }
        }

        // Second pass: Any Gemini Pro or similar
        if (bestTextModel == null) {
          for (var m in models) {
            final name = m['name'].toString().replaceFirst('models/', '');
            if (name.contains('gemini') &&
                m['supportedGenerationMethods'].contains('generateContent')) {
              bestTextModel = name;
              break;
            }
          }
        }

        if (bestTextModel != null) {
          debugPrint('✅ Auto-selected model: $bestTextModel');
          _model = GenerativeModel(model: bestTextModel, apiKey: _apiKey);
          _visionModel = GenerativeModel(model: bestTextModel, apiKey: _apiKey);
        } else {
          debugPrint('⚠️ No specific gemini model found in list');
        }
      }
    } catch (e) {
      debugPrint('❌ Error auto-discovering models: $e');
    }
  }

  /// Get emergency guidance with conversation context
  Future<String> getEmergencyGuidance({
    required String emergencyType,
    String? userMessage,
    String? patientAge,
    List<String>? conversationHistory,
  }) async {
    if (!_isInitialized || _model == null) {
      return _getOfflineGuidance(emergencyType);
    }

    try {
      final prompt = _buildEmergencyPrompt(
        emergencyType: emergencyType,
        userMessage: userMessage,
        patientAge: patientAge,
        history: conversationHistory,
      );

      final response = await _model!.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 30));

      return response.text ?? 'عذراً، لم أتمكن من الحصول على رد';
    } catch (e) {
      debugPrint('❌ Gemini Error Detailed: $e');

      // Handle Quota/Rate Limit Errors Gracefully
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('429') ||
          errorStr.contains('quota') ||
          errorStr.contains('resource exhausted')) {
        return 'عذراً، لقد تجاوزنا حد الاستخدام المسموح للدقيقة. أرجوك انتظر دقيقة وسأكون معاك تاني.';
      }

      if (e is GenerativeAIException) {
        debugPrint('❌ Gemini API Message: ${e.message}');
      }
      return "${_getOfflineGuidance(emergencyType)}\n\n[خطأ تقني: $e]";
    }
  }

  /// Analyze medical image
  Future<String> analyzeMedicalImage({
    required File imageFile,
    required String emergencyType,
    String? additionalContext,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return 'عذراً، خدمة تحليل الصور غير متاحة حالياً';
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = _buildMedicalImagePrompt(
        emergencyType: emergencyType,
        context: additionalContext,
      );

      final response = await _visionModel!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]).timeout(const Duration(seconds: 30));

      return response.text ?? 'لم أتمكن من تحليل الصورة';
    } catch (e) {
      debugPrint('❌ Image analysis error: $e');
      return 'حدث خطأ في تحليل الصورة. يرجى المحاولة مرة أخرى.';
    }
  }

  /// Analyze disaster scene
  Future<String> analyzeDisasterScene({
    required File imageFile,
    required String disasterType,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return 'عذراً، خدمة تحليل الصور غير متاحة حالياً';
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = _buildDisasterAnalysisPrompt(disasterType);

      final response = await _visionModel!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]).timeout(const Duration(seconds: 30));

      return response.text ?? 'لم أتمكن من تحليل الموقف';
    } catch (e) {
      debugPrint('❌ Disaster analysis error: $e');
      return 'حدث خطأ في تحليل الموقف';
    }
  }

  /// Analyze video frame for real-time guidance
  Future<String> analyzeVideoFrame({
    required Uint8List frameBytes,
    required String scenarioType,
    String? previousGuidance,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return 'جاري التحليل...';
    }

    try {
      final prompt = '''
أنت مساعد طوارئ ذكي. تقوم بتحليل لقطة فيديو مباشرة في حالة $scenarioType.
${previousGuidance != null ? 'الإرشاد السابق: $previousGuidance' : ''}

حلل الصورة وقدم:
1. تقييم سريع للوضع الحالي
2. أي مخاطر فورية ظاهرة
3. إرشادات قصيرة وواضحة للخطوة التالية

كن موجزاً ومباشراً (2-3 جمل فقط).
''';

      final response = await _visionModel!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', frameBytes),
        ])
      ]).timeout(const Duration(seconds: 30));

      return response.text ?? 'تحليل...';
    } catch (e) {
      debugPrint('❌ Frame analysis error: $e');
      return 'تحليل...';
    }
  }

  // ===== Private Helper Methods =====

  String _buildEmergencyPrompt({
    required String emergencyType,
    String? userMessage,
    String? patientAge,
    List<String>? history,
  }) {
    return '''
أنت "سيرا"، مساعد طوارئ صوتي ذكي ومتعاطف. الحالة: $emergencyType.
${patientAge != null ? 'عمر المصاب: $patientAge' : ''}
${history != null && history.isNotEmpty ? 'سياق سابق:\n${history.join('\n')}' : ''}
${userMessage != null ? 'المستخدم يقول (صوتياً): $userMessage' : ''}

دورك: أنت مسعف مصري خبير تتحدث عبر الهاتف.
1. 🗣️ **تكلم باللهجة المصرية البسيطة والمطمئنة.** (مثلاً: "ما تقلقش، أنا معاك"، "إيه اللي حصل؟").
2. 🚫 **ممنوع تقول "أنا نصي" أو "أنا أكتب".** أنت مساعد صوتي فقط.
3. 🛑 لا تسرد خطوات طويلة. اسأل سؤال واحد وتانتظر الرد.
4. 🕵️ ابدأ بالتقييم: "هو واعي؟"، "بيتنفس؟".
5. ⚡ إجاباتك قصيرة جداً (جملة واحدة) عشان الصوت يكون سريع.

مثال:
المستخدم: "إلحقني أخويا وقع"
أنت: "ما تقلقش أنا معاك. هو واعي وبيرد عليك؟"
''';
  }

  String _buildMedicalImagePrompt({
    required String emergencyType,
    String? context,
  }) {
    return '''
أنت طبيب طوارئ متخصص. تقوم بتقييم أولي لحالة مصاب في حالة: $emergencyType.
${context != null ? 'معلومات إضافية: $context' : ''}

حلل الصورة وقدم:
1. **التقييم الأولي**: ماذا ترى في الصورة؟
2. **درجة الخطورة**: (بسيطة/متوسطة/خطيرة)
3. **الإجراءات الفورية**: خطوات واضحة ومرقمة
4. **علامات التحذير**: متى يجب الاتصال بالإسعاف فوراً

استخدم لغة عربية بسيطة وواضحة.

⚠️ تنبيه: هذا تقييم أولي فقط وليس بديلاً عن الفحص الطبي.
''';
  }

  String _buildDisasterAnalysisPrompt(String disasterType) {
    return '''
أنت خبير سلامة في حالات الكوارث. تقوم بتحليل موقف في حالة: $disasterType.

حلل الصورة بعناية وقدم:
1. **تقييم المخاطر**: ما هي المخاطر الظاهرة في الصورة؟
2. **المسارات الآمنة**: حدد الممرات التي تبدو آمنة
3. **إرشادات فورية**: 3-4 خطوات واضحة
4. **نصائح عامة للسلامة**

استخدم لغة عربية واضحة ومباشرة. ركز على السلامة أولاً.
''';
  }

  /// Offline fallback guidance
  String _getOfflineGuidance(String emergencyType) {
    final Map<String, String> offlineGuidance = {
      'اختناق': '''
1. اطلب المساعدة واتصل بالإسعاف فوراً (997)
2. إذا كان المصاب واعياً: قم بمناورة هيمليك
3. اضغط بقوة على البطن من الخلف للأعلى
4. كرر حتى يخرج الجسم الغريب
5. إذا فقد الوعي: ابدأ الإنعاش القلبي
''',
      'نزيف': '''
1. اضغط مباشرة على الجرح بقطعة قماش نظيفة
2. ارفع العضو المصاب فوق مستوى القلب
3. حافظ على الضغط المستمر لمدة 10-15 دقيقة
4. لا تزل القماش حتى لو تشبع بالدم
5. اتصل بالإسعاف للنزيف الشديد
''',
      'حريق': '''
1. غادر المبنى فوراً من أقرب مخرج
2. ابق منخفضاً تحت الدخان
3. لا تستخدم المصعد أبداً
4. اختبر الأبواب قبل فتحها
5. اتصل بالدفاع المدني (998)
''',
      'زلزال': '''
1. ابتعد عن النوافذ والأثاث الثقيل
2. اختبئ تحت طاولة متينة أو في زاوية
3. غطِّ رأسك ورقبتك بيديك
4. ابق في مكانك حتى يتوقف الاهتزاز
5. بعد التوقف: اخرج بحذر وتجنب المباني المتضررة
''',
    };

    return offlineGuidance[emergencyType] ??
        'اتصل بالإسعاف فوراً على 997 واتبع تعليمات المسعفين.';
  }
}
