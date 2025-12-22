import 'package:flutter/widgets.dart';

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  // استخدام النسب المئوية للعرض (مثلاً 50% من عرض الشاشة)
  static double w(double percent) {
    return blockSizeHorizontal * percent;
  }

  // استخدام النسب المئوية للطول
  static double h(double percent) {
    return blockSizeVertical * percent;
  }

  // حجم خط متجاوب (يحافظ على التنسيق)
  static double sp(double size) {
    // معادلة بسيطة: نقسم العرض على 3 للنماذج القياسية (مثل iPhone 11)
    // 3.0 is a scaling factor approximation
    return blockSizeHorizontal * (size / 3.6);
  }
}
