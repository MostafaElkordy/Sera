import 'package:flutter/material.dart';
import '../models/first_aid_case.dart';
import '../models/disaster_case.dart';

enum NavigationPage {
  home,
  firstAid,
  firstAidDetail,
  disasters,
  disasterDetail,
}

class NavigationProvider extends ChangeNotifier {
  final List<NavigationPage> _pageStack = [NavigationPage.home];
  FirstAidCase? selectedFirstAidCase;
  DisasterCase? selectedDisaster;

  NavigationPage get currentPage => _pageStack.last;

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
    }
  }

  void navigateTo(NavigationPage page) {
    if (_pageStack.isEmpty || _pageStack.last != page) {
      _pageStack.add(page);
      notifyListeners();
    }
  }

  void navigateToFirstAidDetail(FirstAidCase caseData) {
    selectedFirstAidCase = caseData;
    navigateTo(NavigationPage.firstAidDetail);
  }

  void navigateToDisasterDetail(DisasterCase disaster) {
    selectedDisaster = disaster;
    navigateTo(NavigationPage.disasterDetail);
  }

  void goBack() {
    if (_pageStack.length > 1) {
      _pageStack.removeLast();
      notifyListeners();
    }
  }

  void resetToHome() {
    _pageStack.clear();
    _pageStack.add(NavigationPage.home);
    selectedFirstAidCase = null;
    selectedDisaster = null;
    notifyListeners();
  }
}
