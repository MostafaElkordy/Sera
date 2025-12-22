import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationState {
  final List<String> stack;
  final Map<String, dynamic> selectedData;
  final DateTime? lastActivityTime;

  NavigationState({
    required this.stack,
    required this.selectedData,
    this.lastActivityTime,
  });

  Map<String, dynamic> toMap() => {
        'stack': stack,
        'selectedData': selectedData,
        'lastActivityTime': lastActivityTime?.toIso8601String(),
      };

  factory NavigationState.fromMap(Map<String, dynamic> map) => NavigationState(
        stack: List<String>.from(map['stack'] as List),
        selectedData: Map<String, dynamic>.from(map['selectedData'] as Map),
        lastActivityTime: map['lastActivityTime'] != null
            ? DateTime.parse(map['lastActivityTime'] as String)
            : null,
      );
}

class NavigationPersistenceService {
  static final NavigationPersistenceService _instance =
      NavigationPersistenceService._internal();

  factory NavigationPersistenceService() => _instance;
  NavigationPersistenceService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  NavigationState? _currentState;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    // Restore current state
    final savedState = getNavigationState();
    if (savedState != null) {
      _currentState = savedState;
    }

    _isInitialized = true;
  }

  Future<void> saveNavigationStack(List<String> stack) async {
    _currentState = NavigationState(
      stack: stack,
      selectedData: _currentState?.selectedData ?? {},
      lastActivityTime: DateTime.now(),
    );
    await _prefs?.setString('nav_stack', jsonEncode(stack));
    await saveNavigationState(_currentState!);
  }

  List<String> loadNavigationStack() {
    final jsonString = _prefs?.getString('nav_stack');
    if (jsonString == null) return [];
    try {
      return List<String>.from(jsonDecode(jsonString));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSelectedData(Map<String, dynamic> data) async {
    _currentState = NavigationState(
      stack: _currentState?.stack ?? [],
      selectedData: data,
      lastActivityTime: DateTime.now(),
    );
    await _prefs?.setString('selected_data', jsonEncode(data));
    await saveNavigationState(_currentState!);
  }

  Map<String, dynamic> getSelectedData() {
    final jsonString = _prefs?.getString('selected_data');
    if (jsonString == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLastActivityTime() async {
    await _prefs?.setString(
        'last_activity_time', DateTime.now().toIso8601String());
  }

  DateTime? getLastActivityTime() {
    final time = _prefs?.getString('last_activity_time');
    return time != null ? DateTime.parse(time) : null;
  }

  Future<void> saveNavigationState(NavigationState state) async {
    _currentState = state;
    await _prefs?.setString('nav_state', jsonEncode(state.toMap()));
  }

  NavigationState? getNavigationState() {
    final jsonString = _prefs?.getString('nav_state');
    if (jsonString == null) return _currentState;
    try {
      return NavigationState.fromMap(jsonDecode(jsonString));
    } catch (_) {
      return _currentState;
    }
  }

  Future<void> saveNavigationHistory(
      String page, Map<String, dynamic> data) async {
    final history = getNavigationHistory();
    history.add({
      'page': page,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (history.length > 50) history.removeAt(0);
    await _prefs?.setString('nav_history', jsonEncode(history));
  }

  List<Map<String, dynamic>> getNavigationHistory() {
    final jsonString = _prefs?.getString('nav_history');
    if (jsonString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
    _currentState = null;
    _isInitialized = false;
  }

  bool isInitialized() => _isInitialized;

  NavigationState? get currentState => _currentState;
}
