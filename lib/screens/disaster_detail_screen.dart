import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/disaster_case.dart';
import '../providers/navigation_provider.dart';

class DisasterDetailScreen extends StatelessWidget {
  final DisasterCase disasterData;

  const DisasterDetailScreen({
    super.key,
    required this.disasterData,
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
                      disasterData.color,
                      disasterData.color.withAlpha((0.7 * 255).round()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      disasterData.icon,
                      size: 54.4,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      disasterData.title,
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
              ...disasterData.steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DisasterStepCard(
                    step: step,
                    color: disasterData.color,
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Camera Analysis Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal,
                      Colors.teal.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withAlpha((0.4 * 255).round()),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري تحليل البيئة المحيطة باستخدام الكاميرا...'),
                          backgroundColor: Colors.teal,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'استخدم الكاميرا لتحليل الموقف',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisasterStepCard extends StatelessWidget {
  final DisasterStep step;
  final Color color;

  const _DisasterStepCard({
    required this.step,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
              color: color.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              step.icon,
              size: 26,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step.text,
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
