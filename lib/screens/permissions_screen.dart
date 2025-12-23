import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../navigation/main_navigator.dart';
import '../services/persistence_service.dart';

class PermissionsScreen extends StatefulWidget {
  final bool fromSettings;
  const PermissionsScreen({super.key, this.fromSettings = false});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isRequesting = false;

  // Selection states (Default: All selected)
  bool _locationSelected = true;
  bool _smsSelected = true;
  bool _contactsSelected = true;
  bool _audioSelected = true;
  bool _cameraSelected = true;
  bool _photosSelected = true; // New
  bool _selectAll = true;

  void _onSelectAllChanged(bool? value) {
    if (value == null) return;
    setState(() {
      _selectAll = value;
      _locationSelected = value;
      _smsSelected = value;
      _contactsSelected = value;
      _audioSelected = value;
      _cameraSelected = value;
      _photosSelected = value;
    });
  }

  void _updateSelectAllState() {
    setState(() {
      _selectAll = _locationSelected &&
          _smsSelected &&
          _contactsSelected &&
          _audioSelected &&
          _cameraSelected &&
          _photosSelected;
    });
  }

  Future<void> _requestSelectedPermissions() async {
    setState(() => _isRequesting = true);

    List<Permission> permissionsToRequest = [];

    if (_locationSelected) permissionsToRequest.add(Permission.location);
    if (_smsSelected) permissionsToRequest.add(Permission.sms);
    if (_contactsSelected) permissionsToRequest.add(Permission.contacts);
    if (_audioSelected) permissionsToRequest.add(Permission.microphone);
    if (_cameraSelected) permissionsToRequest.add(Permission.camera);

    // Request Photos/Storage
    if (_photosSelected) {
      // Requesting both handles different Android versions via permission_handler
      permissionsToRequest.add(Permission.photos);
      // Note: Permission.storage might be needed for older Androids,
      // but Permission.photos usually maps intelligently or we can add both.
      // For safety on older Androids:
      permissionsToRequest.add(Permission.storage);
    }

    // Request Phone permission for Dual SIM / SmsManager access
    permissionsToRequest.add(Permission.phone);

    // Always request notification if possible
    permissionsToRequest.add(Permission.notification);

    if (permissionsToRequest.isNotEmpty) {
      // Filter out permanently denied to avoid errors, or just request all explanation
      await permissionsToRequest.request();
    }

    setState(() => _isRequesting = false);

    _finishFlow();
  }

  void _onSkip() {
    _finishFlow();
  }

  Future<void> _finishFlow() async {
    // Mark as seen
    await persistence.setPermissionsSeen(true);

    if (!mounted) return;

    if (widget.fromSettings) {
      Navigator.of(context).pop();
    } else {
      final navProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      navProvider.resetToHome();
      Navigator.of(context).pushReplacementNamed(MainNavigator.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Icon Header
              const Icon(Icons.security, size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'إعداد صلاحيات التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'يمكنك تحديد الصلاحيات الآن، ويمكنك دائماً تغييرها لاحقاً من قسم "إعدادات التطبيق" في أي وقت.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
              ),

              // REMOVED DUPLICATE TEXT CONTAINER HERE

              const SizedBox(height: 20),

              // Select All Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  value: _selectAll,
                  onChanged: _onSelectAllChanged,
                  title: const Text(
                    'تحديد الكل',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 10),

              // Permissions List - NON-SCROLLABLE (part of main scroll)
              _buildPermissionCheckbox(
                value: _locationSelected,
                onChanged: (v) {
                  setState(() => _locationSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.location_on,
                title: 'تحديد الموقع',
                desc: 'لإرسال موقعك الدقيق للمنقذين',
              ),
              _buildPermissionCheckbox(
                value: _smsSelected,
                onChanged: (v) {
                  setState(() => _smsSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.sms,
                title: 'الرسائل النصية',
                desc: 'لإرسال نداءات الاستغاثة تلقائياً',
              ),
              _buildPermissionCheckbox(
                value: _contactsSelected,
                onChanged: (v) {
                  setState(() => _contactsSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.contacts,
                title: 'جهات الاتصال',
                desc: 'لاختيار أرقام الطوارئ من هاتفك',
              ),
              _buildPermissionCheckbox(
                value: _audioSelected,
                onChanged: (v) {
                  setState(() => _audioSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.mic,
                title: 'الميكروفون',
                desc: 'لتسجيل الصوت كدليل أثناء الخطر',
              ),
              _buildPermissionCheckbox(
                value: _cameraSelected,
                onChanged: (v) {
                  setState(() => _cameraSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.camera_alt,
                title: 'الكاميرا',
                desc: 'سيتم استخدام الكاميرا عند الضرورة لتقييم الوضع',
              ),
              _buildPermissionCheckbox(
                value: _photosSelected,
                onChanged: (v) {
                  setState(() => _photosSelected = v!);
                  _updateSelectAllState();
                },
                icon: Icons.photo_library,
                title: 'الصور والملفات',
                desc: 'لاختيار صورة الملف الشخصي من المعرض',
              ),

              const SizedBox(height: 16),

              // Buttons Row
              Row(
                children: [
                  // Agree Button (Moved to Start)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          _isRequesting ? null : _requestSelectedPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isRequesting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : const Text('موافق',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Skip Button (Moved to End)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRequesting ? null : _onSkip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تخطى',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              value ? Colors.blue.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
        checkColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, color: value ? Colors.blue : Colors.grey, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  if (desc.isNotEmpty)
                    Text(desc,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
