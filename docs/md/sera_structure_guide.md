# بنية المشروع التفصيلية 📂

## هيكل الملفات الكامل

```
sera_emergency/
│
├── android/                      # ملفات الأندرويد
├── ios/                          # ملفات iOS
├── web/                          # ملفات الويب
├── test/                         # ملفات الاختبار
│
├── fonts/                        # الخطوط (اختياري)
│   ├── Cairo-Regular.ttf
│   ├── Cairo-SemiBold.ttf
│   └── Cairo-Bold.ttf
│
├── assets/                       # الأصول (اختياري)
│   ├── images/
│   └── icon.png
│
├── lib/                          # الكود الأساسي
│   │
│   ├── main.dart                 # نقطة الدخول الرئيسية
│   │   ├── SeraEmergencyApp      # Widget التطبيق الرئيسي
│   │   └── MainNavigator         # مدير التنقل
│   │
│   ├── models/                   # نماذج البيانات
│   │   ├── first_aid_case.dart
│   │   │   ├── FirstAidCase      # نموذج حالة الإسعاف
│   │   │   └── FirstAidData      # بيانات الإسعافات
│   │   │
│   │   └── disaster_case.dart
│   │       ├── DisasterCase      # نموذج الكارثة
│   │       ├── DisasterStep      # خطوة الكارثة
│   │       └── DisasterData      # بيانات الكوارث
│   │
│   ├── providers/                # إدارة الحالة
│   │   └── navigation_provider.dart
│   │       ├── NavigationPage    # enum الصفحات
│   │       └── NavigationProvider # Provider التنقل
│   │
│   ├── screens/                  # الشاشات
│   │   ├── home_screen.dart
│   │   │   └── HomeScreen        # الشاشة الرئيسية
│   │   │
│   │   ├── first_aid_screen.dart
│   │   │   ├── FirstAidScreen    # شاشة الإسعافات
│   │   │   └── _FirstAidCard     # بطاقة الإسعاف
│   │   │
│   │   ├── first_aid_detail_screen.dart
│   │   │   ├── FirstAidDetailScreen  # تفاصيل الإسعاف
│   │   │   └── _StepCard         # بطاقة الخطوة
│   │   │
│   │   ├── disasters_screen.dart
│   │   │   ├── DisastersScreen   # شاشة الكوارث
│   │   │   └── _DisasterCard     # بطاقة الكارثة
│   │   │
│   │   └── disaster_detail_screen.dart
│   │       ├── DisasterDetailScreen  # تفاصيل الكارثة
│   │       └── _DisasterStepCard # بطاقة خطوة الكارثة
│   │
│   └── widgets/                  # Widgets قابلة لإعادة الاستخدام
│       └── sos_button.dart
│           ├── SosButton         # زر SOS
│           └── SosDialog         # نافذة SOS
│
├── pubspec.yaml                  # تبعيات المشروع
├── README.md                     # دليل المشروع
├── PROJECT_STRUCTURE.md          # هذا الملف
└── .gitignore                    # ملفات Git المستبعدة

```

## شرح تفصيلي للملفات

### 1. main.dart
**الوظيفة**: نقطة البداية للتطبيق
**المكونات**:
- `SeraEmergencyApp`: Widget رئيسي للتطبيق
- `MainNavigator`: يدير التنقل بين الشاشات
- إعدادات RTL واللغة العربية
- Theme configuration

**الاستخدامات**:
```dart
void main() {
  runApp(const SeraEmergencyApp());
}
```

---

### 2. models/first_aid_case.dart
**الوظيفة**: يحتوي على بيانات حالات الإسعافات الأولية

**الكلاسات**:
```dart
class FirstAidCase {
  final String id;           // معرف فريد
  final String title;        // العنوان
  final String description;  // الوصف المختصر
  final IconData icon;       // الأيقونة
  final List<String> steps;  // الخطوات
  final Color color;         // اللون المميز
}
```

**البيانات المتوفرة**:
- CPR (الإنعاش القلبي الرئوي)
- Choking (الاختناق)
- Fainting (الإغماء)
- Drowning (الغرق)

---

### 3. models/disaster_case.dart
**الوظيفة**: يحتوي على بيانات الكوارث

**الكلاسات**:
```dart
class DisasterCase {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<DisasterStep> steps;
  final Color color;
}

class DisasterStep {
  final IconData icon;  // أيقونة الخطوة
  final String text;    // نص الخطوة
}
```

**البيانات المتوفرة**:
- Fire (الحرائق)
- Earthquake (الزلازل)
- Floods (السيول)

---

### 4. providers/navigation_provider.dart
**الوظيفة**: إدارة التنقل والحالة

**الوظائف الرئيسية**:
```dart
class NavigationProvider extends ChangeNotifier {
  void navigateTo(NavigationPage page)          // الانتقال لصفحة
  void navigateToFirstAidDetail(FirstAidCase)   // فتح تفاصيل إسعاف
  void navigateToDisasterDetail(DisasterCase)   // فتح تفاصيل كارثة
  void goBack()                                  // الرجوع للخلف
  void resetToHome()                             // العودة للرئيسية
  String getPageTitle()                          // عنوان الصفحة الحالية
}
```

**Stack System**:
يستخدم نظام Stack للتنقل السلس بين الشاشات

---

### 5. screens/home_screen.dart
**الوظيفة**: الشاشة الرئيسية للتطبيق

**المكونات**:
- شعار التطبيق (SERA)
- زر الإسعافات الأولية
- زر التعامل مع الكوارث
- زر SOS الذكي

**التصميم**:
- Gradient buttons
- Shadow effects
- Responsive layout

---

### 6. screens/first_aid_screen.dart
**الوظيفة**: عرض جميع حالات الإسعافات الأولية

**التخطيط**:
- Grid 2x2
- بطاقات تفاعلية
- Scale animation عند الضغط

**_FirstAidCard**:
- Widget فرعي للبطاقة الواحدة
- تأثيرات hover و tap
- Animation controller

---

### 7. screens/first_aid_detail_screen.dart
**الوظيفة**: عرض تفاصيل حالة إسعاف معينة

**المكونات**:
- Title card بلون الحالة
- قائمة الخطوات المرقمة
- بطاقة المساعد الذكي
- زر الميكروفون

**_StepCard**:
- عرض كل خطوة بشكل منظم
- ترقيم مرئي
- تنسيق نص محسّن

---

### 8. screens/disasters_screen.dart
**الوظيفة**: عرض أنواع الكوارث

**مشابه لـ first_aid_screen**:
- نفس التخطيط Grid
- نفس نظام التفاعل
- ألوان مختلفة

---

### 9. screens/disaster_detail_screen.dart
**الوظيفة**: عرض تفاصيل كارثة معينة

**المكونات**:
- Title card
- خطوات مع أيقونات
- زر تحليل البيئة بالكاميرا

**_DisasterStepCard**:
- عرض الخطوة مع أيقونتها
- تصميم مميز عن FirstAid

---

### 10. widgets/sos_button.dart
**الوظيفة**: زر الاستغاثة التفاعلي

**SosButton**:
```dart
class SosButton extends StatefulWidget {
  - AnimationController للنبض
  - Long press detection (1.5 ثانية)
  - HapticFeedback
  - Shadow و gradient effects
}
```

**SosDialog**:
```dart
class SosDialog extends StatefulWidget {
  - عد تنازلي 15 ثانية
  - زر الإلغاء
  - إرسال تلقائي عند انتهاء العد
  - تأثيرات مرئية
}
```

---

### 11. pubspec.yaml
**الوظيفة**: إدارة التبعيات والإعدادات

**التبعيات الرئيسية**:
```yaml
dependencies:
  provider: ^6.1.1      # State management
  go_router: ^12.1.3    # Navigation
  flutter_svg: ^2.0.9   # SVG support
  intl: ^0.19.0         # Internationalization
```

**Assets**:
```yaml
fonts:
  - family: Cairo
    fonts:
      - asset: fonts/Cairo-Regular.ttf
      - asset: fonts/Cairo-SemiBold.ttf
        weight: 600
      - asset: fonts/Cairo-Bold.ttf
        weight: 700
```

---

## مسار البيانات (Data Flow)

```
User Tap
    ↓
Widget (Screen)
    ↓
NavigationProvider.navigateTo()
    ↓
notifyListeners()
    ↓
MainNavigator rebuilds
    ↓
New Screen displayed
```

---

## مسار الحالة (State Flow)

```
NavigationProvider
    ↓
_pageStack: List<NavigationPage>
    ↓
currentPage: NavigationPage
    ↓
Consumer<NavigationProvider> في MainNavigator
    ↓
عرض الشاشة المناسبة
```

---

## التعديلات المستقبلية المقترحة

### 1. إضافة قاعدة بيانات محلية
```
lib/
├── services/
│   └── database_service.dart
└── models/
    └── saved_case.dart
```

### 2. إضافة ملفات صوتية
```
assets/
└── sounds/
    ├── sos_alert.mp3
    └── notification.mp3
```

### 3. إضافة صور توضيحية
```
assets/
└── images/
    ├── cpr_illustration.png
    ├── choking_steps.png
    └── ...
```

### 4. إضافة API للطوارئ
```
lib/
├── services/
│   ├── emergency_api.dart
│   └── location_service.dart
└── models/
    └── emergency_contact.dart
```

---

## نصائح للتطوير

### 1. إضافة Widget جديد
- ضعه في `lib/widgets/` إذا كان قابل لإعادة الاستخدام
- ضعه داخل Screen إذا كان خاصاً بها

### 2. إضافة Screen جديدة
- أضف الـ enum في NavigationProvider
- أنشئ ملف في `screens/`
- أضفها في MainNavigator switch

### 3. إضافة بيانات جديدة
- حدّث Model في `models/`
- أضف البيانات في Data class
- لا تنسى update الـ UI

### 4. تحسين الأداء
- استخدم `const` حيثما أمكن
- تجنب rebuild غير ضرورية
- استخدم `ListView.builder` للقوائم الطويلة

---

## الاختبارات المقترحة

```
test/
├── widget_test/
│   ├── sos_button_test.dart
│   ├── home_screen_test.dart
│   └── ...
├── unit_test/
│   ├── navigation_provider_test.dart
│   └── models_test.dart
└── integration_test/
    └── app_test.dart
```

---

هذا الدليل يساعدك على فهم بنية المشروع بالكامل وكيفية التعديل عليه! 🚀