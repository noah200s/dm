import 'package:flutter/material.dart';
import 'design_system.dart';

/// ثيم التطبيق الموحد
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // الألوان الأساسية
      primarySwatch: _createMaterialColor(AppDesignSystem.primaryColor),
      primaryColor: AppDesignSystem.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppDesignSystem.primaryColor,
        secondary: AppDesignSystem.secondaryColor,
        surface: AppDesignSystem.surfaceColor,
        background: AppDesignSystem.backgroundColor,
        error: AppDesignSystem.errorColor,
      ),
      
      // الخطوط
      fontFamily: 'Cairo',
      textTheme: _textTheme,
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppDesignSystem.headingSM.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      
      // الكاردات
      // cardTheme: CardThemeData(
      //   color: AppDesignSystem.surfaceColor,
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG),
      //     side: BorderSide(
      //       color: AppDesignSystem.borderColor,
      //       width: 1,
      //     ),
      //   ),
      //   margin: EdgeInsets.zero,
      // ),
      
      // الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppDesignSystem.primaryButtonStyle,
      ),
      
      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppDesignSystem.outlineButtonStyle,
      ),
      
      // أزرار النص
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppDesignSystem.primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
          borderSide: const BorderSide(color: AppDesignSystem.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
          borderSide: const BorderSide(color: AppDesignSystem.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
          borderSide: const BorderSide(
            color: AppDesignSystem.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
          borderSide: const BorderSide(color: AppDesignSystem.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spaceMD,
          vertical: AppDesignSystem.spaceMD,
        ),
        labelStyle: const TextStyle(
          color: AppDesignSystem.textSecondary,
          fontFamily: 'Cairo',
        ),
        hintStyle: const TextStyle(
          color: AppDesignSystem.textMuted,
          fontFamily: 'Cairo',
        ),
      ),
      
      // أيقونات
      iconTheme: const IconThemeData(
        color: AppDesignSystem.textSecondary,
      ),
      
      // الفواصل
      dividerTheme: const DividerThemeData(
        color: AppDesignSystem.dividerColor,
        thickness: 1,
      ),
      
      // مفاتيح التبديل
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppDesignSystem.primaryColor;
          }
          return AppDesignSystem.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppDesignSystem.primaryColor.withOpacity(0.3);
          }
          return AppDesignSystem.borderColor;
        }),
      ),
      
      // مربعات الاختيار
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppDesignSystem.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(
          color: AppDesignSystem.borderColor,
          width: 2,
        ),
      ),
      
      // أشرطة التقدم
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppDesignSystem.primaryColor,
      ),
      
      // الخلفية العامة
      scaffoldBackgroundColor: AppDesignSystem.backgroundColor,
      
      // القوائم المنبثقة
      popupMenuTheme: PopupMenuThemeData(
        color: AppDesignSystem.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
        ),
        elevation: 8,
      ),
      
      // أشرطة التمرير
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
          AppDesignSystem.primaryColor.withOpacity(0.5),
        ),
        trackColor: MaterialStateProperty.all(
          AppDesignSystem.borderColor,
        ),
        radius: const Radius.circular(AppDesignSystem.radiusSM),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppDesignSystem.headingXL,
      displayMedium: AppDesignSystem.headingLG,
      displaySmall: AppDesignSystem.headingMD,
      headlineLarge: AppDesignSystem.headingLG,
      headlineMedium: AppDesignSystem.headingMD,
      headlineSmall: AppDesignSystem.headingSM,
      titleLarge: AppDesignSystem.headingMD,
      titleMedium: AppDesignSystem.headingSM,
      titleSmall: AppDesignSystem.bodyLG,
      bodyLarge: AppDesignSystem.bodyLG,
      bodyMedium: AppDesignSystem.bodyMD,
      bodySmall: AppDesignSystem.bodySM,
      labelLarge: AppDesignSystem.bodyMD,
      labelMedium: AppDesignSystem.bodySM,
      labelSmall: AppDesignSystem.caption,
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
