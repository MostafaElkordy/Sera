import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/first_aid_screen.dart';
import 'screens/first_aid_detail_screen.dart';
import 'screens/disasters_screen.dart';
import 'screens/disaster_detail_screen.dart';
import 'providers/navigation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1F2937),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const SeraEmergencyApp());
}

class SeraEmergencyApp extends StatelessWidget {
  const SeraEmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: MaterialApp(
        title: 'SERA - تطبيق الطوارئ الذكي',
        debugShowCheckedModeBanner: false,
        
        // RTL Support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'AE'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ar', 'AE'),
        
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1F2937),
          cardColor: const Color(0xFF374151),
          fontFamily: 'Cairo',
          
          // App Bar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF111827),
            elevation: 4,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        Widget currentScreen;
        
        switch (navProvider.currentPage) {
          case NavigationPage.home:
            currentScreen = const HomeScreen();
            break;
          case NavigationPage.firstAid:
            currentScreen = const FirstAidScreen();
            break;
          case NavigationPage.firstAidDetail:
            currentScreen = FirstAidDetailScreen(
              caseData: navProvider.selectedFirstAidCase!,
            );
            break;
          case NavigationPage.disasters:
            currentScreen = const DisastersScreen();
            break;
          case NavigationPage.disasterDetail:
            currentScreen = DisasterDetailScreen(
              disasterData: navProvider.selectedDisaster!,
            );
            break;
        }
        
        // Return the current screen directly. Using a custom PopScope caused
        // gesture/navigation issues — rebuilds happen via Consumer on notifyListeners.
        return currentScreen;
      },
    );
  }
}
