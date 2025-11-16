# دليل البداية السريعة ⚡

## تشغيل التطبيق في 5 دقائق

### الخطوة 1️⃣: التأكد من Flutter
```bash
flutter --version
# يجب أن تكون النسخة 3.0.0 أو أحدث
```

إذا لم يكن لديك Flutter:
- [تحميل Flutter](https://flutter.dev/docs/get-started/install)
- اتبع التعليمات حسب نظام التشغيل

### الخطوة 2️⃣: إنشاء المشروع
```bash
# إنشاء مشروع جديد
flutter create sera_emergency

# الدخول للمشروع
cd sera_emergency
```

### الخطوة 3️⃣: نسخ الملفات

#### أ. استبدل `pubspec.yaml`
احذف محتوى الملف الموجود وضع هذا:
```yaml
name: sera_emergency
description: تطبيق ذكي للطوارئ والإسعافات الأولية
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  provider: ^6.1.1
  go_router: ^12.1.3
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

#### ب. أنشئ المجلدات
```bash
cd lib
mkdir models providers screens widgets
cd ..
```

#### ج. انسخ الملفات
ضع كل ملف في مكانه الصحيح:

```
lib/
├── main.dart                          ← انسخ main.dart هنا
├── models/
│   ├── first_aid_case.dart            ← انسخ هنا
│   └── disaster_case.dart             ← انسخ هنا
├── providers/
│   └── navigation_provider.dart       ← انسخ هنا
├── screens/
│   ├── home_screen.dart               ← انسخ هنا
│   ├── first_aid_screen.dart          ← انسخ هنا
│   ├── first_aid_detail_screen.dart   ← انسخ هنا
│   ├── disasters_screen.dart          ← انسخ هنا
│   └── disaster_detail_screen.dart    ← انسخ هنا
└── widgets/
    └── sos_button.dart                ← انسخ هنا
```

### الخطوة 4️⃣: تحميل المكتبات
```bash
flutter pub get
```

### الخطوة 5️⃣: تشغيل التطبيق
```bash
# على محاكي Android/iOS
flutter run

# أو اختر جهاز معين
flutter devices          # لعرض الأجهزة المتاحة
flutter run -d <device>  # للتشغيل على جهاز محدد
```

---

## استكشاف الأخطاء الشائعة 🔍

### ❌ خطأ: "No devices found"
**الحل**:
```bash
# للأندرويد: افتح محاكي من Android Studio
# أو صِل هاتفك وفعّل USB Debugging

# للـ iOS (Mac فقط):
open -a Simulator
```

### ❌ خطأ: "Package not found"
**الحل**:
```bash
flutter clean
flutter pub get
```

### ❌ خطأ: "Dart SDK version conflict"
**الحل**:
```bash
flutter upgrade
```

### ❌ الخطوط لا تعمل
**الحل**: اجعل التطبيق يعمل أولاً بدون خطوط، ثم أضفها لاحقاً:
1. احذف قسم `fonts` من pubspec.yaml
2. run `flutter pub get`

---

## اختبار سريع ✅

بعد تشغيل التطبيق، تحقق من:

- [ ] الشاشة الرئيسية تظهر بشكل صحيح
- [ ] زر "الإسعافات الأولية" يعمل
- [ ] زر "التعامل مع الكوارث" يعمل  
- [ ] زر SOS ينبض
- [ ] الضغط المطول على SOS يفتح نافذة العد التنازلي
- [ ] زر الرجوع يعمل في كل صفحة

---

## التعديل السريع 🎨

### تغيير اللون الأساسي
في `lib/main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.red,  // غيّر هنا
  // ...
)
```

### إضافة حالة إسعاف
في `lib/models/first_aid_case.dart`، أضف في `FirstAidData.cases`:
```dart
FirstAidCase(
  id: 'my_case',
  title: 'حالتي الجديدة',
  description: 'وصف مختصر',
  icon: Icons.healing,
  color: Colors.green,
  steps: [
    'الخطوة 1',
    'الخطوة 2',
  ],
),
```

### تغيير نص زر SOS
في `lib/widgets/sos_button.dart`:
```dart
child: const Text(
  'طوارئ',  // غيّر النص هنا
  style: TextStyle(
    fontSize: 48,
    // ...
  ),
),
```

---

## بناء APK للتوزيع 📦

### للاختبار (Debug)
```bash
flutter build apk --debug
# الملف في: build/app/outputs/flutter-apk/app-debug.apk
```

### للنشر (Release)
```bash
flutter build apk --release
# الملف في: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (للـ Play Store)
```bash
flutter build appbundle --release
# الملف في: build/app/outputs/bundle/release/app-release.aab
```

---

## نقل APK للهاتف 📱

### الطريقة 1: عبر USB
```bash
# وصّل الهاتف وفعّل USB Debugging
flutter install
```

### الطريقة 2: عبر الملف مباشرة
1. انتقل للمسار: `build/app/outputs/flutter-apk/`
2. انسخ `app-release.apk` للهاتف
3. ثبّته من مدير الملفات

---

## الخطوات التالية 🚀

بعد أن يعمل التطبيق:

1. **أضف الخطوط** (اختياري):
   - حمّل Cairo من Google Fonts
   - ضعها في مجلد `fonts/`
   - فعّلها في pubspec.yaml

2. **أضف أيقونة التطبيق**:
   ```bash
   flutter pub add flutter_launcher_icons
   ```

3. **أضف Splash Screen**:
   ```bash
   flutter pub add flutter_native_splash
   ```

4. **جرّب على جهاز حقيقي**:
   - أفضل من المحاكي
   - اختبر الأداء والسلاسة

---

## موارد مفيدة 📚

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design Icons](https://api.flutter.dev/flutter/material/Icons-class.html)

---

## الدعم والمساعدة 💬

### مشكلة في الكود؟
1. راجع الـ console للأخطاء
2. ابحث في Stack Overflow
3. اسأل في مجتمع Flutter العربي

### أفكار للتحسين؟
- أضف database محلية (sqflite)
- دمج GPS للموقع الفعلي
- أضف مساعد صوتي (speech_to_text)
- أضف إشعارات (flutter_local_notifications)

---

## Checklist المطور الجديد ✓

قبل البدء بالتطوير:
- [ ] تثبيت Flutter و Android Studio/VS Code
- [ ] تشغيل `flutter doctor` بنجاح
- [ ] إنشاء المشروع
- [ ] نسخ جميع الملفات
- [ ] تشغيل التطبيق بنجاح
- [ ] فهم بنية المشروع (راجع PROJECT_STRUCTURE.md)
- [ ] قراءة README.md للمعلومات الكاملة

---

🎉 **مبروك! تطبيقك الآن يعمل**

ابدأ بالتجربة والتعديل، والأهم: استمتع بالتطوير! 💙