import 'package:flutter/material.dart';

class FirstAidCase {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;
  final Color color;

  const FirstAidCase({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.color,
  });
}

class FirstAidData {
  static final List<FirstAidCase> cases = [
    FirstAidCase(
      id: 'cpr',
      title: 'الإنعاش القلبي الرئوي (CPR)',
      description: 'إنعاش قلبي رئوي',
      icon: Icons.favorite,
      color: Colors.red,
      steps: [
        'تأكد من أمان المكان.',
        'تحقق من وعي المصاب واستجابته.',
        'اطلب المساعدة واتصل بالإسعاف فوراً.',
        'ابدأ 30 ضغطة على الصدر بعمق 5 سم.',
        'أعط نفسين إنقاذيين.',
        'استمر في تكرار الضغطات والأنفاس حتى وصول المساعدة.',
      ],
    ),
    FirstAidCase(
      id: 'choking',
      title: 'الاختناق',
      description: 'الأختناق',
      icon: Icons.warning_amber,
      color: Colors.orange,
      steps: [
        'شجع المصاب على السعال بقوة.',
        'قم بتنفيذ 5 ضربات على الظهر بين لوحي الكتف.',
        'إذا لم يخرج الجسم العالق، قم بـ 5 ضغطات على البطن (الأختناق).',
        'كرر الخطوات حتى يخرج الجسم أو يفقد المصاب وعيه.',
      ],
    ),
    FirstAidCase(
      id: 'fainting',
      title: 'الإغماء',
      description: 'فقدان الوعي',
      icon: Icons.personal_injury,
      color: Colors.purple,
      steps: [
        'اجعل المصاب يستلقي على ظهره.',
        'ارفع ساقيه فوق مستوى القلب.',
        'فك أي ملابس ضيقة حول الرقبة.',
        'تأكد من أنه يتنفس بشكل طبيعي.',
      ],
    ),
    FirstAidCase(
      id: 'drowning',
      title: 'الغرق',
      description: 'الغرق',
      icon: Icons.pool,
      color: Colors.blue,
      steps: [
        'أخرج الشخص من الماء بأمان.',
        'تحقق من التنفس. إذا لم يكن يتنفس، اطلب المساعدة وابدأ الإنعاش القلبي الرئوي.',
        'إذا كان يتنفس، ضعه في وضعية الغرق.',
        'قم بتغطيته لتدفئته حتى وصول الإسعاف.',
      ],
    ),
  ];

  static FirstAidCase? getCaseById(String id) {
    try {
      return cases.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
