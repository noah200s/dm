import 'package:flutter/material.dart';

/// نظام التصميم الموحد لتطبيق إدارة الطبيب
class AppDesignSystem {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF6c547b);
  static const Color secondaryColor = Color(0xFFea7884);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFD69E2E);
  static const Color infoColor = Color(0xFF3182CE);
  
  // الألوان الرمادية
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEDF2F7);
  
  // أحجام الخطوط
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeMD = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  
  // المسافات
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;
  
  // نصف الأقطار
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusFull = 999.0;
  
  // الظلال
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // أنماط النصوص
  static const TextStyle headingXL = TextStyle(
    fontSize: fontSize3XL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle headingLG = TextStyle(
    fontSize: fontSize2XL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle headingMD = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle headingSM = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodyLG = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodyMD = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodySM = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: FontWeight.normal,
    color: textMuted,
    fontFamily: 'Cairo',
  );
  
  // أنماط الأزرار
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMD),
    ),
    textStyle: const TextStyle(
      fontSize: fontSizeMD,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMD),
    ),
    textStyle: const TextStyle(
      fontSize: fontSizeMD,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
  );
  
  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMD),
    ),
    textStyle: const TextStyle(
      fontSize: fontSizeMD,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
  );
  
  // أنماط الكاردات
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusLG),
    boxShadow: shadowSM,
    border: Border.all(color: borderColor, width: 1),
  );
  
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusLG),
    boxShadow: shadowMD,
  );
  
  // أنماط حقول الإدخال
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMD,
        vertical: spaceMD,
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontFamily: 'Cairo',
      ),
      hintStyle: const TextStyle(
        color: textMuted,
        fontFamily: 'Cairo',
      ),
    );
  }
  
  // نظام الشبكة المتجاوب
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Desktop large
    if (width >= 992) return 3;  // Desktop
    if (width >= 768) return 2;  // Tablet
    return 1; // Mobile
  }
  
  static double getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 768) return 1.2; // Desktop/Tablet
    return 0.8; // Mobile
  }
  
  // المسافات المتجاوبة
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return spaceXL;
    if (width >= 768) return spaceLG;
    return spaceMD;
  }
  
  // أحجام الخطوط المتجاوبة
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return baseFontSize * 1.1;
    if (width < 600) return baseFontSize * 0.9;
    return baseFontSize;
  }
}
