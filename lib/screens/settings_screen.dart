import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../services/audio_service.dart';
import 'permissions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = false;
  bool _notificationsEnabled = true; // Used in switch
  bool _hapticEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = audioService.isAudioEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navProvider.goBack(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Appearance Section ---
          _buildSectionHeader('المظهر', theme),
          _buildContainer(
            theme: theme,
            child: Column(
              children: [
                _buildThemeRadio(
                  title: 'نهاري (Daylight)',
                  subtitle: 'وضوح عالي في الإضاءة القوية',
                  value: AppThemeType.daylight,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (val) => themeProvider.setTheme(val!),
                  icon: Icons.wb_sunny,
                  theme: theme,
                ),
                Divider(color: theme.dividerColor, height: 1),
                _buildThemeRadio(
                  title: 'مسائي (Midnight)',
                  subtitle: 'مريح للعين في الظلام',
                  value: AppThemeType.midnight,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (val) => themeProvider.setTheme(val!),
                  icon: Icons.nights_stay,
                  theme: theme,
                ),
                Divider(color: theme.dividerColor, height: 1),
                _buildThemeRadio(
                  title: 'تباين عالي (High Contrast)',
                  subtitle: 'ألوان الطوارئ (أسود وأصفر)',
                  value: AppThemeType.highContrast,
                  groupValue: themeProvider.currentTheme,
                  onChanged: (val) => themeProvider.setTheme(val!),
                  icon: Icons.visibility,
                  theme: theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('التنبيهات والصوت', theme),
          _buildSwitchTile(
            title: 'المؤثرات الصوتية',
            subtitle: 'تشغيل أصوات الإنذار والنقر',
            value: _soundEnabled,
            icon: Icons.volume_up,
            theme: theme,
            onChanged: (val) {
              setState(() => _soundEnabled = val);
              audioService.setAudioEnabled(val);
              if (val) audioService.playClick();
            },
          ),
          _buildSwitchTile(
            title: 'الاهتزاز',
            subtitle: 'الاهتزاز عند الضغط والتنبيهات',
            value: _hapticEnabled,
            icon: Icons.vibration,
            theme: theme,
            onChanged: (val) {
              setState(() => _hapticEnabled = val);
            },
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('الإشعارات', theme),
          _buildSwitchTile(
            title: 'إشعارات الطوارئ',
            subtitle: 'السماح باستقبال تنبيهات الكوارث',
            value: _notificationsEnabled, // Used here
            icon: Icons.notifications_active,
            theme: theme,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 24),

          _buildSectionHeader('الخصوصية', theme),
          _buildContainer(
            theme: theme,
            child: Column(
              children: [
                ListTile(
                  title: Text('سجل الطوارئ',
                      style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold)),
                  leading:
                      Icon(Icons.history, color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => navProvider.navigateTo(NavigationPage.history),
                ),
                // Divider removed as requested
                ListTile(
                  title: Text('إدارة الصلاحيات',
                      style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text('مراجعة وتعديل صلاحيات التطبيق',
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                          fontSize: 12)),
                  leading:
                      Icon(Icons.security, color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const PermissionsScreen(fromSettings: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('معلومات التطبيق', theme),
          _buildContainer(
            theme: theme,
            child: Column(
              children: [
                _buildInfoRow('الإصدار', AppConfig.appVersion, theme),
                Divider(color: theme.dividerColor),
                _buildInfoRow('رقم البناء', AppConfig.buildNumber, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required ThemeData theme, required Widget child}) {
    final shape = theme.cardTheme.shape;
    final border =
        (shape is RoundedRectangleBorder && shape.side != BorderSide.none)
            ? Border.fromBorderSide(shape.side)
            : null;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildThemeRadio({
    required String title,
    required String subtitle,
    required AppThemeType value,
    required AppThemeType groupValue,
    required Function(AppThemeType?) onChanged,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = value == groupValue;
    // ignore: deprecated_member_use
    return RadioListTile<AppThemeType>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
      title: Text(title,
          style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 12)),
      secondary: Icon(icon,
          color: isSelected ? theme.colorScheme.primary : theme.disabledColor),
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
    required ThemeData theme,
  }) {
    final shape = theme.cardTheme.shape;
    final border =
        (shape is RoundedRectangleBorder && shape.side != BorderSide.none)
            ? Border.fromBorderSide(shape.side)
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title,
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontSize: 12)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        activeTrackColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          Text(value,
              style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
