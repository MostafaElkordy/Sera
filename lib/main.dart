import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'navigation/main_navigator.dart';
import 'providers/navigation_provider.dart';
import 'providers/sos_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
// import 'services/navigation_persistence_service.dart';
import 'services/offline_service.dart';
// import 'services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Critical Services
  // 1. Initialize Critical Services
  // Moved to SplashScreen for parallel initialization (faster launch)
  offlineService.initialize();

  // 2. Lock Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. System UI Overlay Style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SeraApp());
}

class SeraApp extends StatelessWidget {
  const SeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()..loadTheme()), // تهيئة الثيم
        ChangeNotifierProvider(create: (_) => SosProvider()), // New logic brain
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SERA',
            debugShowCheckedModeBanner: false,

            // Localization
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

            // Dynamic Theme
            theme: themeProvider.themeData, // استخدام ثيم المزود

            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              MainNavigator.routeName: (context) => const MainNavigator(),
            },
          );
        },
      ),
    );
  }
}
