# SERA - تطبيق الطوارئ الذكي 🚑

تطبيق موبايل شامل للإسعافات الأولية والتعامل مع الكوارث، تم تطويره باستخدام Flutter.

## المميزات الرئيسية ✨

### 1. الإسعافات الأولية
- إرشادات خطوة بخطوة للحالات الطارئة
- الإنعاش القلبي الرئوي (CPR)
- التعامل مع الاختناق
- إسعاف حالات الإغماء
- التعامل مع حالات الغرق

### 2. التعامل مع الكوارث
- دليل شامل للحرائق
- إرشادات الزلازل
- التعامل مع السيول والفيضانات

### 3. نظام SOS الذكي
- زر استغاثة بضغطة مطولة (1.5 ثانية)
- عد تنازلي 15 ثانية للإلغاء
- إرسال موقع تلقائي لجهات الطوارئ
- تأثيرات بصرية وصوتية للتنبيه

### 4. واجهة المستخدم
- دعم كامل للغة العربية (RTL)
- تصميم عصري وسهل الاستخدام
- انتقالات سلسة بين الشاشات
- تأثيرات بصرية احترافية

## متطلبات التشغيل 📋

- Flutter SDK 3.0.0 أو أحدث
- Dart SDK 3.0.0 أو أحدث
- Android Studio / VS Code
- جهاز Android أو iOS للتجربة

## هيكل المشروع 📁

```
lib/
├── main.dart                          # نقطة البداية
├── models/
│   ├── first_aid_case.dart            # نموذج بيانات الإسعافات الأولية
│   └── disaster_case.dart             # نموذج بيانات الكوارث
├── providers/
│   └── navigation_provider.dart       # إدارة التنقل والحالة
├── screens/
│   ├── home_screen.dart               # الشاشة الرئيسية
│   ├── first_aid_screen.dart          # شاشة الإسعافات الأولية
│   ├── first_aid_detail_screen.dart   # تفاصيل الإسعاف
│   ├── disasters_screen.dart          # شاشة الكوارث
│   └── disaster_detail_screen.dart    # تفاصيل الكارثة
└── widgets/
    └── sos_button.dart                # زر الاستغاثة
```

## خطوات التثبيت 🔧

### 1. تثبيت Flutter
```bash
# للتحقق من تثبيت Flutter
flutter doctor
```

### 2. إنشاء المشروع
```bash
# إنشاء مشروع جديد
flutter create sera_emergency

# الانتقال للمجلد
cd sera_emergency
```

### 3. نسخ الملفات
- انسخ محتوى `pubspec.yaml` المرفق
- أنشئ المجلدات المذكورة في هيكل المشروع
- انسخ جميع ملفات `.dart` في أماكنها الصحيحة

### 4. تحميل الخطوط (اختياري)
```bash
# أنشئ مجلد fonts في الجذر
mkdir fonts

# ضع خطوط Cairo فيه:
# - Cairo-Regular.ttf
# - Cairo-SemiBold.ttf
# - Cairo-Bold.ttf
```

يمكنك تحميل خط Cairo من Google Fonts:
https://fonts.google.com/specimen/Cairo

### 5. تثبيت المكتبات
```bash
flutter pub get
```

### 6. تشغيل التطبيق
```bash
# على محاكي Android
flutter run

# على محاكي iOS (Mac فقط)
flutter run -d ios

# بناء APK للأندرويد
flutter build apk --release

# بناء App Bundle
flutter build appbundle --release
```

## المكتبات المستخدمة 📦

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6        # أيقونات iOS
  flutter_svg: ^2.0.9            # دعم SVG
  provider: ^6.1.1               # إدارة الحالة
  go_router: ^12.1.3             # التنقل المتقدم
  intl: ^0.19.0                  # دعم اللغات
```

## التخصيص والتطوير 🎨

### إضافة حالة إسعاف جديدة
في `models/first_aid_case.dart`:
```dart
FirstAidCase(
  id: 'burns',
  title: 'الحروق',
  description: 'التعامل مع الحروق',
  icon: Icons.local_fire_department,
  color: Colors.orange,
  steps: [
    'الخطوة 1: ...',
    'الخطوة 2: ...',
  ],
),
```

### إضافة كارثة جديدة
في `models/disaster_case.dart`:
```dart
DisasterCase(
  id: 'hurricane',
  title: 'الأعاصير',
  description: 'التعامل مع الأعاصير',
  icon: Icons.tornado,
  color: Colors.grey,
  steps: [
    DisasterStep(
      icon: Icons.home,
      text: 'ابق في المنزل...',
    ),
  ],
),
```

### تغيير الألوان
في `main.dart`:
```dart
theme: ThemeData(
  scaffoldBackgroundColor: const Color(0xFF1F2937),
  primarySwatch: Colors.blue,
  // ... المزيد من التخصيصات
)
```

## المزايا المستقبلية 🚀

- [ ] تكامل مع GPS لإرسال الموقع الفعلي
- [ ] مساعد صوتي ذكي باستخدام AI
- [ ] قاعدة بيانات محلية لحفظ الحالات المفضلة
- [ ] دعم لغات إضافية
- [ ] وضع الطوارئ بدون إنترنت
- [ ] تكامل مع أرقام الطوارئ المحلية
- [ ] فيديوهات توضيحية للإسعافات
- [ ] اختبارات تفاعلية للمستخدمين

## الاختبار 🧪

```bash
# تشغيل الاختبارات
flutter test

# اختبار الأداء
flutter run --profile

# تحليل الكود
flutter analyze
```

## البناء والنشر 📱

### Android
```bash
# بناء APK
flutter build apk --release

# بناء App Bundle (للنشر على Play Store)
flutter build appbundle --release
```

### iOS
```bash
# بناء IPA (يتطلب Mac)
flutter build ios --release
```

## استكشاف الأخطاء 🔍

### خطأ في الخطوط
إذا لم تعمل الخطوط، يمكنك:
1. حذف قسم fonts من `pubspec.yaml`
2. سيستخدم التطبيق الخط الافتراضي

### مشاكل RTL
تأكد من:
```dart
MaterialApp(
  locale: const Locale('ar', 'AE'),
  // ...
)
```

### مشاكل التبعيات
```bash
# تنظيف المشروع
flutter clean

# إعادة تثبيت المكتبات
flutter pub get
```

## الترخيص 📄

هذا المشروع مفتوح المصدر ومتاح للاستخدام التعليمي والتجاري.

## التواصل والدعم 💬

لأي استفسارات أو مشاكل:
- افتح Issue على GitHub
- راسلنا عبر البريد الإلكتروني

## ملاحظات مهمة ⚠️

1. **هذا التطبيق تعليمي**: لا يغني عن التدريب المهني في الإسعافات الأولية
2. **الطوارئ الحقيقية**: في حالات الطوارئ الفعلية، اتصل بالرقم المحلي للطوارئ
3. **المسؤولية**: المطور غير مسؤول عن أي استخدام خاطئ للإرشادات

## شكر خاص 🙏

- فريق Flutter للأدوات الرائعة
- Google Fonts لخط Cairo الجميل
- المجتمع العربي للمطورين

---

صنع بـ ❤️ لخدمة المجتمع

**SERA** - Saving Emergency Response Assistant