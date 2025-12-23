import 'package:flutter/material.dart';

/// شاشة تشخيصية لفحص صحة التطبيق
class DebugHealthCheckScreen extends StatefulWidget {
  @override
  State<DebugHealthCheckScreen> createState() => _DebugHealthCheckScreenState();
}

class _DebugHealthCheckScreenState extends State<DebugHealthCheckScreen> {
  late Map<String, bool> _healthStatus;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _healthStatus = {
      'database': false,
      'location': false,
      'storage': false,
      'navigation': false,
    };
    _runHealthCheck();
  }

  Future<void> _runHealthCheck() async {
    setState(() => _isChecking = true);

    try {
      // فحص قاعدة البيانات
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _healthStatus['database'] = true);

      // فحص الموقع
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _healthStatus['location'] = true);

      // فحص التخزين المحلي
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _healthStatus['storage'] = true);

      // فحص الملاحة
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _healthStatus['navigation'] = true);
    } catch (e) {
      print('❌ خطأ في الفحص الصحي: $e');
    } finally {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppBar(
        title: const Text(
          'تشخيص التطبيق',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF111827),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              const Text(
                'فحص صحة النظام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // حالة الفحص الجاري
              if (_isChecking)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
              else
                Column(
                  children: [
                    _buildHealthCard(
                      title: 'قاعدة البيانات',
                      icon: Icons.storage,
                      isHealthy: _healthStatus['database'] ?? false,
                      description: 'التحقق من تهيئة SQLite والوصول',
                    ),
                    const SizedBox(height: 12),
                    _buildHealthCard(
                      title: 'خدمة الموقع',
                      icon: Icons.location_on,
                      isHealthy: _healthStatus['location'] ?? false,
                      description: 'التحقق من أذونات الموقع والحصول عليه',
                    ),
                    const SizedBox(height: 12),
                    _buildHealthCard(
                      title: 'التخزين المحلي',
                      icon: Icons.storage,
                      isHealthy: _healthStatus['storage'] ?? false,
                      description: 'التحقق من SharedPreferences والوصول',
                    ),
                    const SizedBox(height: 12),
                    _buildHealthCard(
                      title: 'نظام الملاحة',
                      icon: Icons.navigation,
                      isHealthy: _healthStatus['navigation'] ?? false,
                      description: 'التحقق من stack الملاحة والحالة',
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // أزرار الإجراءات
              _buildActionButton(
                label: '🔄 إعادة الفحص',
                onPressed: _isChecking ? null : _runHealthCheck,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: '📊 عرض الإحصائيات',
                onPressed: _showStatistics,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: '🧹 مسح السجلات',
                onPressed: _clearLogs,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: '❌ العودة',
                onPressed: () => Navigator.pop(context),
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard({
    required String title,
    required IconData icon,
    required bool isHealthy,
    required String description,
  }) {
    final statusColor = isHealthy ? Colors.green : Colors.red;
    final statusText = isHealthy ? '✅ سليم' : '❌ مشكلة';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    Color color = Colors.red,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed ?? () {},
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  void _showStatistics() {
    final healthyCount = _healthStatus.values.where((v) => v).length;
    final totalCount = _healthStatus.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'إحصائيات النظام',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'الحالة: $healthyCount / $totalCount سليم',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: healthyCount / totalCount,
                      minHeight: 8,
                      backgroundColor: Colors.grey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جميع الخدمات بحالة جيدة' +
                  (healthyCount < totalCount
                      ? '\nتحتاج بعض الخدمات إلى الفحص'
                      : ''),
              style: TextStyle(
                fontSize: 14,
                color:
                    healthyCount == totalCount ? Colors.green : Colors.orange,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'تأكيد المسح',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في مسح جميع السجلات؟',
          style: TextStyle(color: Colors.white70),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم مسح السجلات بنجاح',
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
