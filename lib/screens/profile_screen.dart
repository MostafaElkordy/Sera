import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../providers/navigation_provider.dart';
import '../services/persistence_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // No longer using a text controller for diseases, but a List
  List<String> _selectedDiseases = [];

  List<Map<String, String>> _emergencyContacts = [];
  String _selectedBloodType = 'غير محدد';
  bool _isSaving = false;

  final List<String> _bloodTypes = [
    'غير محدد',
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  final List<String> _commonDiseases = [
    'السكري',
    'ضغط الدم المرتفع',
    'الربو',
    'حساسية الصدر',
    'أمراض القلب',
    'حساسية البنسلين',
    'حساسية الطعام',
    'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = PersistenceService().getUserData();
    final contacts = PersistenceService().getEmergencyContacts();
    setState(() {
      _nameController.text = data['name'] ?? '';
      _selectedBloodType = data['bloodType'] ?? 'غير محدد';

      // Load diseases from string (comma separated)
      String medicalHistory = data['medicalHistory'] ?? '';
      if (medicalHistory.isNotEmpty) {
        _selectedDiseases =
            medicalHistory.split(',').where((e) => e.isNotEmpty).toList();
      }

      _emergencyContacts = List.from(contacts);
      if (!_bloodTypes.contains(_selectedBloodType)) {
        _selectedBloodType = 'غير محدد';
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await PersistenceService().saveUserData({
      'name': _nameController.text,
      'bloodType': _selectedBloodType,
      'medicalHistory': _selectedDiseases.join(','),
    });

    await PersistenceService().setEmergencyContacts(_emergencyContacts);

    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('تم حفظ الملف الشخصي بنجاح'),
          backgroundColor: Colors.green),
    );
  }

  Future<void> _pickContact() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);

          if (fullContact != null && fullContact.phones.isNotEmpty) {
            final name = fullContact.displayName;
            final phone = fullContact.phones.first.number;

            setState(() {
              _emergencyContacts.add({
                'name': name,
                'phone': phone,
              });
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('جهة الاتصال المختارة لا تحتوي على رقم هاتف'),
                    backgroundColor: Colors.orange),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking contact: $e');
    }
  }

  void _showContactDialog({Map<String, String>? existingContact, int? index}) {
    final theme = Theme.of(context);

    final nameCtrl =
        TextEditingController(text: existingContact?['name'] ?? '');
    final phoneCtrl =
        TextEditingController(text: existingContact?['phone'] ?? '');
    final isEditing = existingContact != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.canvasColor,
        title: Text(isEditing ? 'تعديل جهة اتصال' : 'إضافة جهة اتصال',
            style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'الاسم',
                labelStyle: TextStyle(color: theme.hintColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.dividerColor)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                labelStyle: TextStyle(color: theme.hintColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.dividerColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                setState(() {
                  if (isEditing) {
                    _emergencyContacts[index!] = {
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    };
                  } else {
                    _emergencyContacts.add({
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    });
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(isEditing ? 'حفظ' : 'إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('الملف الشخصي', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => navProvider.goBack(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: theme.colorScheme.primary),
            onPressed: _isSaving ? null : _saveProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('المعلومات الشخصية', theme),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'الاسم الكامل',
                icon: Icons.person,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('جهات اتصال الطوارئ', theme),
              const SizedBox(height: 8),
              Text(
                'سيتم إرسال رسالة الاستغاثة لهذه الأرقام',
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Contact List
              if (_emergencyContacts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('لم يتم إضافة جهات اتصال بعد',
                      style: TextStyle(color: theme.hintColor)),
                ),

              ..._emergencyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return Card(
                  color: isDark ? const Color(0xFF374151) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.1))),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: Icon(Icons.phone,
                            color: theme.colorScheme.primary, size: 20)),
                    title: Text(contact['name']!,
                        style:
                            TextStyle(color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text(contact['phone']!,
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showContactDialog(
                              existingContact: contact, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(
                              () => _emergencyContacts.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 12),
              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showContactDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('إدراج يدوي'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickContact,
                      icon: const Icon(Icons.contacts),
                      label: const Text('من الهاتف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('المعلومات الطبية', theme),
              const SizedBox(height: 16),

              // Blood Type
              Text('فصيلة الدم',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDropdown(
                label: 'اختر الفصيلة',
                value: _selectedBloodType,
                items: _bloodTypes,
                onChanged: (val) => setState(() => _selectedBloodType = val!),
                icon: Icons.bloodtype,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // Chronic Diseases Multi-select
              Text('أمراض مزمنة أو حساسية',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDiseaseMultiSelect(theme),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.hintColor),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: isDark ? const Color(0xFF374151) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) => val != null && val.isEmpty && label == 'الاسم الكامل'
          ? 'هذا الحقل مطلوب'
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
          style:
              TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDiseaseMultiSelect(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown to add
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text('أضف مرض أو حساسية...',
                  style: TextStyle(color: theme.hintColor)),
              isExpanded: true,
              icon: Icon(Icons.add_circle_outline,
                  color: theme.colorScheme.primary),
              dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
              onChanged: (val) {
                if (val != null && !_selectedDiseases.contains(val)) {
                  setState(() {
                    _selectedDiseases.add(val);
                  });
                }
              },
              items: _commonDiseases
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color)),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Selected Chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _selectedDiseases.map((disease) {
            return Chip(
              label: Text(disease, style: const TextStyle(color: Colors.white)),
              backgroundColor: theme.colorScheme.primary,
              deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () {
                setState(() {
                  _selectedDiseases.remove(disease);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
