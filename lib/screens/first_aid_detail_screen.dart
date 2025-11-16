import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/first_aid_case.dart';
import '../providers/navigation_provider.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final FirstAidCase caseData;

  const FirstAidDetailScreen({
    super.key,
    required this.caseData,
  });

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(navProvider.getPageTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => navProvider.goBack(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Card
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      caseData.color,
                      caseData.color.withAlpha((0.7 * 255).round()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      caseData.icon,
                      size: 54.4,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      caseData.title,
                      style: const TextStyle(
                        fontSize: 20.4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Steps
              ...caseData.steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StepCard(
                    stepNumber: entry.key + 1,
                    stepText: entry.value,
                    color: caseData.color,
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // AI Assistant Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                    color: Colors.blue.withAlpha((0.3 * 255).round()),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'تفاعل مع المساعد الذكي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha((0.5 * 255).round()),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اضغط واسأل: "ماذا أفعل الآن؟"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String stepText;
  final Color color;

  const _StepCard({
    required this.stepNumber,
    required this.stepText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Remove HTML tags from the text
    final cleanText = stepText.replaceAll(RegExp(r'<[^>]*>'), '');

    return Container(
      padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                cleanText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
