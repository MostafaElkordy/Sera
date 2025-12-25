import 'package:flutter/material.dart';
import '../models/first_aid_case.dart';
import '../models/disaster_case.dart';
import '../services/persistence_service.dart';

enum NavigationPage {
  home,
  firstAid,
  firstAidDetail,
  disasters,
  disasterDetail,
  profile,
  history,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  final List<NavigationPage> _pageStack = [NavigationPage.home];
  FirstAidCase? selectedFirstAidCase;
  DisasterCase? selectedDisaster;
  final PersistenceService _persistenceService = PersistenceService();
  static const int _maxStackDepth = 20;

  NavigationProvider() {
    _restoreState();
  }

  Future<void> _restoreState() async {
    if (!_persistenceService.isInitialized()) {
      await _persistenceService.init();
    }

    final stackStrings = _persistenceService.loadNavigationStack();
    if (stackStrings.isNotEmpty) {
      _pageStack.clear();
      for (var s in stackStrings) {
        // Convert string to enum
        try {
          final page = NavigationPage.values.firstWhere((e) => e.name == s);
          _pageStack.add(page);
        } catch (_) {}
      }
      if (_pageStack.isEmpty) _pageStack.add(NavigationPage.home);
      notifyListeners();
    }
  }

  Future<void> _saveState() async {
    final stackStrings = _pageStack.map((p) => p.name).toList();
    await _persistenceService.saveNavigationStack(stackStrings);
  }

  NavigationPage get currentPage {
    if (_pageStack.isEmpty) {
      _pageStack.add(NavigationPage.home);
      return NavigationPage.home;
    }
    return _pageStack.last;
  }

  bool canGoBack() => _pageStack.length > 1;

  String getPageTitle() {
    switch (currentPage) {
      case NavigationPage.home:
        return 'الرئيسية';
      case NavigationPage.firstAid:
        return 'الإسعافات الأولية';
      case NavigationPage.firstAidDetail:
        return 'تفاصيل الحالة';
      case NavigationPage.disasters:
        return 'التعامل مع الكوارث';
      case NavigationPage.disasterDetail:
        return 'إرشادات الكارثة';
      case NavigationPage.profile:
        return 'الملف الشخصي';
      case NavigationPage.history:
        return 'سجل الطوارئ';
      case NavigationPage.settings:
        return 'الإعدادات';
    }
  }

  bool _validateNavigation(NavigationPage page) {
    if (_pageStack.isEmpty) {
      _pageStack.add(NavigationPage.home);
      return true;
    }

    if (_pageStack.last == page) {
      return false;
    }

    if (_pageStack.length >= _maxStackDepth) {
      _pageStack.removeAt(0);
    }

    return true;
  }

  void navigateTo(NavigationPage page) {
    try {
      if (_validateNavigation(page)) {
        _pageStack.add(page);
        notifyListeners();
        _saveState();
      }
    } catch (e) {
      _pageStack.clear();
      _pageStack.add(NavigationPage.home);
      notifyListeners();
      _saveState();
    }
  }

  void navigateToFirstAidDetail(FirstAidCase? caseData) {
    if (caseData == null) {
      navigateTo(NavigationPage.firstAid);
      return;
    }
    selectedFirstAidCase = caseData;
    navigateTo(NavigationPage.firstAidDetail);
  }

  void navigateToDisasterDetail(DisasterCase? disaster) {
    if (disaster == null) {
      navigateTo(NavigationPage.disasters);
      return;
    }
    selectedDisaster = disaster;
    navigateTo(NavigationPage.disasterDetail);
  }

  void goBack() {
    try {
      if (_pageStack.length > 1) {
        _pageStack.removeLast();
        notifyListeners();
        _saveState();
      }
    } catch (e) {
      resetToHome();
    }
  }

  void resetToHome() {
    try {
      _pageStack.clear();
      _pageStack.add(NavigationPage.home);
      selectedFirstAidCase = null;
      selectedDisaster = null;
      notifyListeners();
      _saveState();
    } catch (e) {
      // Ignore
    }
  }

  String getStackDebugInfo() {
    return 'Stack(${_pageStack.length}): ${_pageStack.map((p) => p.name).join(' > ')}';
  }

  int getStackDepth() => _pageStack.length;

  void clearSelectedData() {
    selectedFirstAidCase = null;
    selectedDisaster = null;
    notifyListeners();
  }
}
