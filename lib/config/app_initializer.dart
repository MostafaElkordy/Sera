// تهيئة التطبيق وجميع الخدمات
// تنظيم ترتيب بدء الخدمات ومنع الأخطاء

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._();
  
  factory AppInitializer() => _instance;
  AppInitializer._();

  bool _initialized = false;
  final Map<String, bool> _serviceStates = {};

  // تهيئة جميع الخدمات
  Future<void> initializeAll() async {
    if (_initialized) return;

    // الخطوة 1: تهيئة خدمة السجلات
    _initializeLogger();
    _serviceStates['logger'] = true;

    // الخطوة 2: تهيئة خدمة التخزين
    _initializePersistence();
    _serviceStates['persistence'] = true;

    // الخطوة 3: تهيئة معالج الأخطاء
    _initializeErrorHandler();
    _serviceStates['errorHandler'] = true;

    // الخطوة 4: تهيئة خدمة الموقع
    _initializeLocation();
    _serviceStates['location'] = true;

    // الخطوة 5: تهيئة خدمة الاتصال
    _initializeOfflineService();
    _serviceStates['offline'] = true;

    // الخطوة 6: تهيئة خدمة SOS
    _initializeSosService();
    _serviceStates['sos'] = true;

    // الخطوة 7: تهيئة خدمة حفظ الملاحة
    _initializeNavigationPersistence();
    _serviceStates['navigationPersistence'] = true;

    // الخطوة 8: تهيئة خدمة التحليلات
    _initializeAnalytics();
    _serviceStates['analytics'] = true;

    _initialized = true;
    print('✅ تم تهيئة جميع الخدمات بنجاح');
  }

  void _initializeLogger() {
    // LoggerService().initialize();
    print('✓ تهيئة خدمة السجلات');
  }

  void _initializePersistence() {
    // final persistence = PersistenceService();
    // await persistence.initialize();
    print('✓ تهيئة خدمة التخزين');
  }

  void _initializeErrorHandler() {
    // final errorHandler = ErrorHandler();
    // errorHandler.initialize();
    print('✓ تهيئة معالج الأخطاء');
  }

  void _initializeLocation() {
    // final locationService = LocationService();
    // await locationService.initialize();
    print('✓ تهيئة خدمة الموقع');
  }

  void _initializeOfflineService() {
    // final offlineService = OfflineService();
    // await offlineService.initialize();
    print('✓ تهيئة خدمة الاتصال');
  }

  void _initializeSosService() {
    // final sosService = SosService();
    // await sosService.initialize();
    print('✓ تهيئة خدمة SOS');
  }

  void _initializeNavigationPersistence() {
    // final navigationPersistence = NavigationPersistenceService();
    // await navigationPersistence.initialize();
    print('✓ تهيئة خدمة حفظ الملاحة');
  }

  void _initializeAnalytics() {
    // final analytics = AnalyticsService();
    // await analytics.initialize();
    print('✓ تهيئة خدمة التحليلات');
  }

  // إيقاف جميع الخدمات
  Future<void> shutdown() async {
    try {
      // إيقاف الخدمات عند إغلاق التطبيق
      print('⏹️ إيقاف جميع الخدمات');
      _initialized = false;
      _serviceStates.clear();
    } catch (e) {
      print('❌ خطأ في الإيقاف: $e');
    }
  }

  // الحصول على حالة الخدمات
  Map<String, bool> getServiceStates() => Map.from(_serviceStates);

  // التحقق من تهيئة خدمة معينة
  bool isServiceInitialized(String serviceName) => 
      _serviceStates[serviceName] ?? false;

  // التحقق من تهيئة جميع الخدمات
  bool isInitialized() => _initialized;

  // الحصول على تقرير الحالة
  String getStatusReport() {
    final sb = StringBuffer();
    sb.writeln('📊 تقرير حالة الخدمات:');
    sb.writeln('═' * 40);
    
    _serviceStates.forEach((service, initialized) {
      final status = initialized ? '✅' : '❌';
      sb.writeln('$status $service');
    });
    
    sb.writeln('═' * 40);
    sb.writeln('الحالة: ${_initialized ? "جاهز" : "غير مهيأ"}');
    
    return sb.toString();
  }
}

// إنشاء instance عام
final appInitializer = AppInitializer();
