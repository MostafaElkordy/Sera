import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/sos_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // --- Modern Dashboard Layout ---
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Using CustomScrollView for sticky headers and scrollable content
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Status & Profile)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('SERA مرحباً بك،',
                              style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontSize: 14)),
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite,
                              color: Colors.red, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('مساعدك الذكي في حالات الطوارئ',
                          style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Top Actions
                  Row(
                    children: [
                      _buildCircleBtn(
                        icon: Icons.power_settings_new,
                        onTap: () => SystemNavigator.pop(),
                        theme: theme,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildCircleBtn(
                        icon: Icons.person,
                        onTap: () =>
                            navProvider.navigateTo(NavigationPage.profile),
                        theme: theme,
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // --- Services Grid ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            context,
                            title: 'الإسعافات الأولية',
                            subtitle: 'إرشادات فورية لحالات حرجة',
                            icon: Icons.medical_services_outlined,
                            color: Colors.blueAccent,
                            onTap: () =>
                                navProvider.navigateTo(NavigationPage.firstAid),
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildServiceCard(
                            context,
                            title: 'الكوارث والآزمات',
                            subtitle: 'دليل النجاة الذكي',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orangeAccent,
                            onTap: () => navProvider
                                .navigateTo(NavigationPage.disasters),
                            theme: theme,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- History / Logs Card ---
                    _buildWideCard(
                      context,
                      title: 'سجل الطوارئ',
                      icon: Icons.history,
                      onTap: () =>
                          navProvider.navigateTo(NavigationPage.history),
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    // --- Settings Card ---
                    _buildWideCard(
                      context,
                      title: 'الإعدادات العامة',
                      icon: Icons.settings,
                      onTap: () =>
                          navProvider.navigateTo(NavigationPage.settings),
                      theme: theme,
                    ),

                    const Spacer(),

                    // 3. SOS Button Area (Hero Section)
                    Column(
                      children: [
                        const SosButton(),
                        const SizedBox(height: 12),
                        Text(
                          'اضغط مطولاً لتفعيل نداء الاستغاثة',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? color,
  }) {
    final effectiveColor = color ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: effectiveColor, size: 22),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gradient Background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11, // Smaller subtitle to fit
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final shape = theme.cardTheme.shape;
    final border =
        (shape is RoundedRectangleBorder && shape.side != BorderSide.none)
            ? Border.fromBorderSide(shape.side)
            : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
