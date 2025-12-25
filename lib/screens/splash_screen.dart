import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/main_navigator.dart';
import '../providers/navigation_provider.dart';
import '../screens/permissions_screen.dart';
import '../utils/screen_utils.dart';
import '../services/persistence_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoScaleController;
  late AnimationController _textFadeController;
  late AnimationController _slogan1FadeController;
  late AnimationController _slogan2FadeController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _slogan1Fade;
  late Animation<double> _slogan2Fade;
  late Animation<double> _pulse;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // No long animations, just quick reveal
    _logoScaleController = AnimationController(
        duration: const Duration(milliseconds: 10), vsync: this);
    _textFadeController = AnimationController(
        duration: const Duration(milliseconds: 10), vsync: this);
    _slogan1FadeController = AnimationController(
        duration: const Duration(milliseconds: 10), vsync: this);
    _slogan2FadeController = AnimationController(
        duration: const Duration(milliseconds: 10), vsync: this);

    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true);

    // Setup animations to end immediately
    _logoScale =
        Tween<double>(begin: 1.0, end: 1.0).animate(_logoScaleController);
    _textFade =
        Tween<double>(begin: 1.0, end: 1.0).animate(_textFadeController);
    _slogan1Fade =
        Tween<double>(begin: 1.0, end: 1.0).animate(_slogan1FadeController);
    _slogan2Fade =
        Tween<double>(begin: 1.0, end: 1.0).animate(_slogan2FadeController);

    _pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start immediately
    _logoScaleController.value = 1.0;
    _textFadeController.value = 1.0;
    _slogan1FadeController.value = 1.0;
    _slogan2FadeController.value = 1.0;

    // Start initialization and timer in parallel
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Minimum Splash Duration (2 seconds)
    final minDelay = Future.delayed(const Duration(seconds: 2));

    // 2. Initialize Critical Services (Parallel)
    final servicesInit = Future.wait([
      PersistenceService().init(),
    ]);

    // Wait for BOTH to complete (Safety First)
    await Future.wait([minDelay, servicesInit]);

    if (mounted) _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    // Check has seen permissions flag
    final hasSeen = persistence.hasSeenPermissions();

    if (!mounted) return;

    if (hasSeen) {
      // User has already dealt with permissions (Agreed or Skipped) -> Go to Home
      final navProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      navProvider.resetToHome();
      Navigator.of(context).pushReplacementNamed(MainNavigator.routeName);
    } else {
      // First time -> Go to Permissions Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PermissionsScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _textFadeController.dispose();
    _slogan1FadeController.dispose();
    _slogan2FadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils().init(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E3A8A),
              const Color(0xFF1F2937),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ScaleTransition(
                scale: _logoScale,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulse.value,
                      child: Container(
                        width: ScreenUtils.w(30),
                        height: ScreenUtils.w(30),
                        padding: EdgeInsets.all(ScreenUtils.w(5)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.4),
                            width: ScreenUtils.w(0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.2),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: ScreenUtils.w(18),
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: ScreenUtils.h(4)),

              // Title SERA
              FadeTransition(
                opacity: _textFade,
                child: Text(
                  'SERA',
                  style: TextStyle(
                    fontSize: ScreenUtils.sp(56),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: ScreenUtils.w(1.5),
                    shadows: [
                      Shadow(
                        color: const Color.fromRGBO(239, 68, 68, 0.3),
                        blurRadius: 10,
                        offset: Offset(0, ScreenUtils.h(0.5)),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ScreenUtils.h(2)),

              // Slogan 1
              FadeTransition(
                opacity: _slogan1Fade,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
                  child: Text(
                    'مساعدك الذكي في حالات الطوارئ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ScreenUtils.sp(16),
                      color: Colors.grey[300],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: ScreenUtils.h(6)),

              // Slogan 2
              FadeTransition(
                opacity: _slogan2Fade,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
                  child: Text(
                    "You'll Never Be Alone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ScreenUtils.sp(18),
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: ScreenUtils.h(10)),

              // Loading Dots
              FadeTransition(
                opacity: _slogan2Fade,
                child: Column(
                  children: [
                    SizedBox(
                      width: ScreenUtils.w(15),
                      height: ScreenUtils.h(1.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLoadingDot(0),
                          SizedBox(width: ScreenUtils.w(2)),
                          _buildLoadingDot(1),
                          SizedBox(width: ScreenUtils.w(2)),
                          _buildLoadingDot(2),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.h(2)),
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        fontSize: ScreenUtils.sp(12),
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final value = (_pulseController.value + (index * 0.2)) % 1.0;
        final opacity = (1.0 - (value - 0.5).abs() * 2).clamp(0.3, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: ScreenUtils.w(2),
            height: ScreenUtils.w(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
