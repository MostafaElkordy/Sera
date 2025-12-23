import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../providers/navigation_provider.dart';
import '../services/persistence_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // --- Controllers & State ---

  // Tab 1: Personal
  final _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDob;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _profileImagePath;

  // Tab 2: Medical
  String _selectedBloodType = 'غير محدد';
  List<String> _selectedDiseases = [];
  List<String> _medications = [];
  List<String> _medicalDirectives = [];

  // Doctor
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();

  // Insurance
  String? _insuranceType;
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();

  // Tab 3: Contacts
  List<Map<String, String>> _emergencyContacts = [];

  // Lists
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

  final List<String> _commonDirectives = [
    'متبرع بالأعضاء',
    'لا تقم بالإنعاش القلبي (DNR)',
    'يوجد جهاز تنظيم ضربات القلب',
    'لدي زرعة شريحة معدنية',
    'حامل',
    'تواصل مع الطبيب المعالج فوراً',
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
      // Personal
      _nameController.text = data['name'] ?? '';
      _selectedGender = data['gender'];
      if (data['dob'] != null && data['dob'].isNotEmpty) {
        _selectedDob = DateTime.parse(data['dob']);
      }
      _weightController.text = data['weight'] ?? '';
      _heightController.text = data['height'] ?? '';
      _profileImagePath = data['imagePath'];

      // Medical
      _selectedBloodType = data['bloodType'] ?? 'غير محدد';
      if (!_bloodTypes.contains(_selectedBloodType))
        _selectedBloodType = 'غير محدد';

      String medicalHistory = data['medicalHistory'] ?? '';
      if (medicalHistory.isNotEmpty) {
        _selectedDiseases =
            medicalHistory.split(',').where((e) => e.isNotEmpty).toList();
      }

      _medications = List<String>.from(data['medications'] ?? []);
      _medicalDirectives = List<String>.from(data['medicalDirectives'] ?? []);

      _doctorNameController.text = data['doctorName'] ?? '';
      _doctorPhoneController.text = data['doctorPhone'] ?? '';

      _insuranceType = data['insuranceType'];
      _insuranceProviderController.text = data['insuranceProvider'] ?? '';
      _insurancePolicyController.text = data['insurancePolicy'] ?? '';

      // Contacts
      _emergencyContacts = List.from(contacts);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await PersistenceService().saveUserData({
        // Personal
        'name': _nameController.text,
        'gender': _selectedGender, // Logic in service must handle null
        'dob': _selectedDob?.toIso8601String() ?? '',
        'weight': _weightController.text,
        'height': _heightController.text,
        'imagePath': _profileImagePath,

        // Medical
        'bloodType': _selectedBloodType,
        'medicalHistory': _selectedDiseases.join(','),
        'medications': _medications,
        'medicalDirectives': _medicalDirectives,
        'doctorName': _doctorNameController.text,
        'doctorPhone': _doctorPhoneController.text,
        'insuranceType': _insuranceType, // Logic in service must handle null
        'insuranceProvider': _insuranceProviderController.text,
        'insurancePolicy': _insurancePolicyController.text,
      });

      await PersistenceService().setEmergencyContacts(_emergencyContacts);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم حفظ الملف الشخصي بنجاح'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("Save error: $e");
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // --- Actions ---

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImagePath = image.path);
    }
  }

  Future<void> _pickContact() async {
    try {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            setState(() {
              _emergencyContacts.add({
                'name': fullContact.displayName,
                'phone': fullContact.phones.first.number,
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking contact: $e");
    }
  }

  // --- Logic Helpers ---

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return "$age سنة";
  }

  void _addToList(List<String> list, String item) {
    if (item.isNotEmpty && !list.contains(item)) {
      setState(() => list.add(item));
    }
  }

  void _showAddDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: "أدخل النص هنا")),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("إلغاء")),
                ElevatedButton(
                    onPressed: () {
                      onAdd(controller.text);
                      Navigator.pop(ctx);
                    },
                    child: const Text("إضافة")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => navProvider.goBack(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: theme.colorScheme.primary),
              onPressed: _isSaving ? null : _saveProfile,
            )
          ],
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "بياناتي"),
              Tab(text: "السجل الطبي"),
              Tab(text: "جهات الاتصال"),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              _buildPersonalTab(theme),
              _buildMedicalTab(theme),
              _buildContactsTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  // --- Tabs ---

  Widget _buildPersonalTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!))
                  : null,
              child: _profileImagePath == null
                  ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[400])
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text("اضغط لتغيير الصورة",
              style: TextStyle(color: theme.hintColor, fontSize: 12)),
          const SizedBox(height: 24),
          _buildTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: Icons.person,
              theme: theme,
              required: true),
          const SizedBox(height: 16),
          _buildDropdown(
              label: "النوع",
              value: _selectedGender,
              items: ["ذكر", "أنثى"],
              onChanged: (v) => setState(() => _selectedGender = v!),
              icon: Icons.wc,
              theme: theme),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now());
              if (picked != null) setState(() => _selectedDob = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "تاريخ الميلاد",
                filled: true,
                prefixIcon: Icon(Icons.calendar_today,
                    color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              child: Text(
                _selectedDob == null
                    ? "اختر التاريخ"
                    : "${intl.DateFormat('yyyy-MM-dd').format(_selectedDob!)}\n${_calculateAge(_selectedDob!)}",
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      controller: _weightController,
                      label: "الوزن (kg)",
                      icon: Icons.monitor_weight,
                      theme: theme,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(
                      controller: _heightController,
                      label: "الطول (cm)",
                      icon: Icons.height,
                      theme: theme,
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 32),
          _buildSaveButton(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMedicalTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("المعلومات الأساسية", theme),
          const SizedBox(height: 8),
          _buildDropdown(
            label: 'فصيلة الدم',
            value: _selectedBloodType,
            items: _bloodTypes,
            onChanged: (val) => setState(() => _selectedBloodType = val!),
            icon: Icons.bloodtype,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildMultiSelect(
              title: "أمراض مزمنة أو حساسية",
              items: _selectedDiseases,
              options: _commonDiseases,
              onAdd: (item) => _addToList(_selectedDiseases, item),
              onRemove: (item) =>
                  setState(() => _selectedDiseases.remove(item)),
              theme: theme),
          const SizedBox(height: 24),
          _buildSectionTitle("الأدوية", theme),
          _buildListEditor(
              items: _medications,
              placeholder: "أدخل اسم الدواء",
              onAdd: (med) => _addToList(_medications, med),
              onRemove: (med) => setState(() => _medications.remove(med)),
              theme: theme),
          const SizedBox(height: 24),
          _buildSectionTitle("الوصايا الطبية", theme),
          _buildMultiSelect(
              title: "اختر وصية طبية",
              items: _medicalDirectives,
              options: _commonDirectives,
              onAdd: (item) => _addToList(_medicalDirectives, item),
              onRemove: (item) =>
                  setState(() => _medicalDirectives.remove(item)),
              theme: theme),
          const SizedBox(height: 24),
          _buildSectionTitle("الطبيب المعالج", theme),
          _buildTextField(
              controller: _doctorNameController,
              label: "اسم الطبيب",
              icon: Icons.local_hospital,
              theme: theme),
          const SizedBox(height: 8),
          _buildTextField(
              controller: _doctorPhoneController,
              label: "رقم هاتف الطبيب",
              icon: Icons.phone,
              theme: theme,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          _buildSectionTitle("التأمين الطبي", theme),
          _buildDropdown(
              label: "نوع التأمين",
              value: _insuranceType,
              items: ["تأمين صحي حكومي", "تأمين صحي خاص"],
              onChanged: (v) => setState(() => _insuranceType = v),
              icon: Icons.verified_user,
              theme: theme),
          const SizedBox(height: 8),
          _buildTextField(
              controller: _insuranceProviderController,
              label: "اسم الجهة / الشركة",
              icon: Icons.apartment,
              theme: theme),
          const SizedBox(height: 8),
          _buildTextField(
              controller: _insurancePolicyController,
              label: "الرقم التأميني",
              icon: Icons.card_membership,
              theme: theme),
          const SizedBox(height: 32),
          _buildSaveButton(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContactDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('إدراج يدوي'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickContact,
                  icon: const Icon(Icons.contacts),
                  label: const Text('جهات الاتصال'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_emergencyContacts.isEmpty)
            Center(
                child: Text("لا توجد جهات اتصال",
                    style: TextStyle(color: theme.hintColor)))
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _emergencyContacts.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _emergencyContacts.removeAt(oldIndex);
                  _emergencyContacts.insert(newIndex, item);
                });
              },
              itemBuilder: (ctx, i) {
                final contact = _emergencyContacts[i];
                return Card(
                  key: ValueKey(contact['phone'] ?? "$i"), // Unique key
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading:
                        CircleAvatar(child: Text(contact['name']?[0] ?? "?")),
                    title: Text(contact['name'] ?? ""),
                    subtitle: Text(contact['phone'] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              setState(() => _emergencyContacts.removeAt(i)),
                        ),
                        const Icon(Icons.drag_handle, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 32),
          _buildSaveButton(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveProfile,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save),
        label: Text(_isSaving ? "جاري الحفظ..." : "حفظ التغييرات"),
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(title,
        style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: required ? (v) => v!.isEmpty ? "مطلوب" : null : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required ThemeData theme,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (value != null && items.contains(value)) ? value : null,
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMultiSelect({
    required String title,
    required List<String> items,
    required List<String> options,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: title,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("اختر لإضافة عنصر"),
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val == 'أخرى') {
                  _showAddDialog("إضافة عنصر جديد", onAdd);
                } else if (val != null) {
                  onAdd(val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items
              .map((e) => Chip(
                    label: Text(e),
                    onDeleted: () => onRemove(e),
                  ))
              .toList(),
        )
      ],
    );
  }

  Widget _buildListEditor({
    required List<String> items,
    required String placeholder,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required ThemeData theme,
  }) {
    final controller = TextEditingController();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: placeholder,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none)),
            )),
            IconButton(
              icon: Icon(Icons.add_circle,
                  color: theme.colorScheme.primary, size: 30),
              onPressed: () {
                onAdd(controller.text);
                controller.clear();
              },
            )
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items
              .map((e) => Chip(
                    label: Text(e),
                    onDeleted: () => onRemove(e),
                  ))
              .toList(),
        )
      ],
    );
  }

  void _showContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("إضافة جهة اتصال"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "الاسم")),
                  TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: "الهاتف"),
                      keyboardType: TextInputType.phone),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("إلغاء")),
                ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty &&
                          phoneCtrl.text.isNotEmpty) {
                        setState(() => _emergencyContacts.add(
                            {'name': nameCtrl.text, 'phone': phoneCtrl.text}));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("حفظ")),
              ],
            ));
  }
}
