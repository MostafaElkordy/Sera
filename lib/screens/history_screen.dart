import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/navigation_provider.dart';
import '../services/persistence_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PersistenceService _persistence = PersistenceService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _persistence.getSosHistory();
    setState(() {
      _history = List.from(history.reversed); // أحدث أولاً
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int index, Map<String, dynamic> item) async {
    // 1. Delete files from disk if any
    if (item['evidence'] != null) {
      final List<dynamic> paths = item['evidence'];
      for (var path in paths) {
        try {
          final file = File(path.toString());
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting file: $e');
        }
      }
    }

    setState(() {
      _history.removeAt(index);
    });

    // Save updated list back to persistence (reversing to match storage order: Oldest -> Newest)
    await _persistence.saveSosHistory(_history.reversed.toList());
  }

  Future<void> _clearAll() async {
    await _persistence.clearSosHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('سجل الطوارئ', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => navProvider.goBack(),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState(theme)
              : _buildHistoryList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            'لا يوجد سجل للطوارئ',
            style: TextStyle(fontSize: 18, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final date =
            DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
        final evidence = item['evidence'] as List<dynamic>? ?? [];

        return Dismissible(
          key: Key(item['timestamp'] ?? index.toString()),
          background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.delete, color: Colors.white)),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteItem(index, item),
          child: Card(
            color: theme.cardColor,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side:
                  BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                child: const Icon(Icons.warning, color: Colors.red),
              ),
              title: Text('SOS Alert',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}',
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7))),
                  if (evidence.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file,
                              color: theme.colorScheme.primary, size: 16),
                          const SizedBox(width: 4),
                          Text('${evidence.length} ملفات أدلة',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: item['synced'] == true
                  ? const Icon(Icons.cloud_done, color: Colors.green)
                  : const Icon(Icons.cloud_off, color: Colors.orange),
              children: [
                if (evidence.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الأدلة الموثقة:',
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: evidence.map((path) {
                            final isAudio = path.toString().endsWith('.m4a');
                            return ActionChip(
                              backgroundColor: theme.colorScheme.secondary
                                  .withValues(alpha: 0.1),
                              avatar: Icon(isAudio ? Icons.mic : Icons.image,
                                  size: 16, color: theme.colorScheme.secondary),
                              label: Text(isAudio ? 'تسجيل صوتي' : 'صورة',
                                  style: TextStyle(
                                      color: theme.colorScheme.secondary)),
                              onPressed: () => _shareFile(path.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                if (item['latitude'] != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                        'الموقع: ${item['latitude']}, ${item['longitude']}',
                        style: TextStyle(color: theme.hintColor)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareFile(String path) async {
    final file = XFile(path);
    // ignore: deprecated_member_use
    await Share.shareXFiles([file], text: 'الدليل الموثق من تطبيق SERA');
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل أنت متأكد من مسح جميع السجلات؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _clearAll();
              },
              child: const Text('مسح', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
