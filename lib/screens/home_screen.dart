import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/sos_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _toggleController;
  // toggle controller used for text toggle previously. Remove unused animation.
  bool _showSOS = true;

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // no fade animation needed now; keep toggle controller if needed later

    // Toggle every 4 seconds
    Future.delayed(const Duration(seconds: 2), _toggleText);
  }

  void _toggleText() {
    if (mounted) {
      _toggleController.forward().then((_) {
        setState(() {
          _showSOS = !_showSOS;
        });
        _toggleController.reverse();
      });
      Future.delayed(const Duration(seconds: 4), _toggleText);
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1F2937),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxH = constraints.maxHeight;
            // Responsive sizes (narrower clamps to avoid overflow on short screens)
            final logoSize = (maxH * 0.11).clamp(44.0, 84.0);
            // increase main button height by ~15% and spacing a bit
            final buttonHeight = (maxH * 0.1495).clamp(80.0, 126.0);
            final verticalGap = (maxH * 0.025).clamp(14.0, 28.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  // Top: Logo & Title - moved up
                  Container(
                    width: logoSize,
                    height: logoSize,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.08 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: logoSize * 0.6,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SERA',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You'll Never Be Alone",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[300],
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مساعدك الذكي في حالات الطوارئ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),

                  // Spacer between header and action area (move buttons slightly down)
                  SizedBox(height: verticalGap.clamp(6.0, 14.0)),

                  // Action buttons area - make scrollable when needed but keep SOS pinned
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildMainButton(
                            context: context,
                            title: 'الإسعافات الأولية',
                            subtitle: 'إرشادات فورية لحالات حرجة',
                            icon: Icons.medical_services,
                            color: Colors.blue,
                            height: buttonHeight,
                            onTap: () {
                              navProvider.navigateTo(NavigationPage.firstAid);
                            },
                          ),

                          SizedBox(height: verticalGap),

                          _buildMainButton(
                            context: context,
                            title: 'التعامل مع الكوارث',
                            subtitle: 'دليلك للنجاة في الأزمات',
                            icon: Icons.warning_amber,
                            color: Colors.orange,
                            height: buttonHeight,
                            onTap: () {
                              navProvider.navigateTo(NavigationPage.disasters);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SOS always visible at bottom
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        const Center(child: SosButton()),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط مطولاً لتفعيل الاستغاثة الذكي',
                          style: TextStyle(
                            fontSize: 12.6,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: verticalGap.clamp(6.0, 20.0)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double height,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha((0.78 * 255).round())],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha((0.35 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.white.withAlpha((0.92 * 255).round()), height: 1.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
              ],
            ),
        ),
      ),
    );
  }
}
