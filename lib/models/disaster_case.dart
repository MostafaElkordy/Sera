import 'package:flutter/material.dart';

class DisasterCase {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<DisasterStep> steps;
  final Color color;

  const DisasterCase({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.color,
  });
}

class DisasterStep {
  final IconData icon;
  final String text;

  const DisasterStep({
    required this.icon,
    required this.text,
  });
}

class DisasterData {
  static final List<DisasterCase> disasters = [
    DisasterCase(
      id: 'fire',
      title: 'التصرف عند نشوب حريق',
      description: 'حريق',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      steps: [
        DisasterStep(
          icon: Icons.door_front_door,
          text: 'حافظ على هدوئك وحاول إخلاء المبنى فوراً.',
        ),
        DisasterStep(
          icon: Icons.visibility_off,
          text: 'إذا كان هناك دخان، انخفض وازحف على الأرض.',
        ),
        DisasterStep(
          icon: Icons.back_hand,
          text: 'قبل فتح أي باب، تحسس حرارته بظهر يدك.',
        ),
        DisasterStep(
          icon: Icons.phone,
          text: 'اتصل بخدمات الطوارئ بعد الخروج لمكان آمن.',
        ),
      ],
    ),
    DisasterCase(
      id: 'earthquake',
      title: 'التصرف أثناء الزلزال',
      description: 'زلزال',
      icon: Icons.home_repair_service,
      color: Colors.brown,
      steps: [
        DisasterStep(
          icon: Icons.shield,
          text: 'انخفض أرضاً، احتمى تحت طاولة متينة، وتمسك بها.',
        ),
        DisasterStep(
          icon: Icons.window,
          text: 'ابتعد عن النوافذ والجدران الخارجية.',
        ),
        DisasterStep(
          icon: Icons.directions_car,
          text: 'إذا كنت في سيارة، توقف في مكان آمن وابق بداخلها.',
        ),
      ],
    ),
    DisasterCase(
      id: 'floods',
      title: 'التصرف عند حدوث فيضان',
      description: 'سيول',
      icon: Icons.water,
      color: Colors.cyan,
      steps: [
        DisasterStep(
          icon: Icons.terrain,
          text: 'انتقل إلى مكان مرتفع فوراً.',
        ),
        DisasterStep(
          icon: Icons.power,
          text: 'لا تلمس المعدات الكهربائية إذا كنت مبتلاً.',
        ),
        DisasterStep(
          icon: Icons.directions_walk,
          text: 'تجنب المشي أو السباحة في مياه الفيضانات.',
        ),
      ],
    ),
  ];

  static DisasterCase? getDisasterById(String id) {
    try {
      return disasters.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
