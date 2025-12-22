import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../screens/disaster_detail_screen.dart';
import '../screens/disasters_screen.dart';
import '../screens/first_aid_detail_screen.dart';
import '../screens/first_aid_screen.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  static const routeName = '/main';

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        // Handle back button on Android
        return PopScope(
          canPop: !navProvider.canGoBack(),
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              navProvider.goBack();
            }
          },
          child: Builder(
            builder: (context) {
              switch (navProvider.currentPage) {
                case NavigationPage.home:
                  return const HomeScreen();
                case NavigationPage.firstAid:
                  return const FirstAidScreen();
                case NavigationPage.firstAidDetail:
                  return FirstAidDetailScreen(
                    caseData: navProvider.selectedFirstAidCase!,
                  );
                case NavigationPage.disasters:
                  return const DisastersScreen();
                case NavigationPage.disasterDetail:
                  return DisasterDetailScreen(
                    disasterData: navProvider.selectedDisaster!,
                  );
                case NavigationPage.profile:
                  return const ProfileScreen();
                case NavigationPage.history:
                  return const HistoryScreen();
                case NavigationPage.settings:
                  return const SettingsScreen();
              }
            },
          ),
        );
      },
    );
  }
}
