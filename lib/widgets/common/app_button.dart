import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// أنواع الأزرار
enum AppButtonType { primary, secondary, outline, text }

/// حجم الزر
enum AppButtonSize { small, medium, large }

/// زر موحد للتطبيق
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final padding = _getPadding();
    final fontSize = _getFontSize();

    Widget buttonChild = _buildButtonContent(fontSize);

    if (fullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            padding: MaterialStateProperty.all(padding),
          ),
          child: buttonChild,
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            padding: MaterialStateProperty.all(padding),
          ),
          child: buttonChild,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            padding: MaterialStateProperty.all(padding),
          ),
          child: buttonChild,
        );
    }
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AppButtonType.primary:
        return AppDesignSystem.primaryButtonStyle.copyWith(
          backgroundColor: backgroundColor != null
              ? MaterialStateProperty.all(backgroundColor)
              : null,
          foregroundColor: textColor != null
              ? MaterialStateProperty.all(textColor)
              : null,
        );
      case AppButtonType.secondary:
        return AppDesignSystem.secondaryButtonStyle.copyWith(
          backgroundColor: backgroundColor != null
              ? MaterialStateProperty.all(backgroundColor)
              : null,
          foregroundColor: textColor != null
              ? MaterialStateProperty.all(textColor)
              : null,
        );
      case AppButtonType.outline:
        return AppDesignSystem.outlineButtonStyle.copyWith(
          foregroundColor: textColor != null
              ? MaterialStateProperty.all(textColor)
              : null,
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: textColor ?? AppDesignSystem.primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spaceMD,
          vertical: AppDesignSystem.spaceSM,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spaceLG,
          vertical: AppDesignSystem.spaceMD,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spaceXL,
          vertical: AppDesignSystem.spaceLG,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDesignSystem.fontSizeSM;
      case AppButtonSize.medium:
        return AppDesignSystem.fontSizeMD;
      case AppButtonSize.large:
        return AppDesignSystem.fontSizeLG;
    }
  }

  Widget _buildButtonContent(double fontSize) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.outline || type == AppButtonType.text
                    ? AppDesignSystem.primaryColor
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppDesignSystem.spaceSM),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: AppDesignSystem.spaceSM),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
    );
  }
}

/// زر أيقونة
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size ?? 40,
      height: size ?? 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppDesignSystem.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppDesignSystem.primaryColor,
          size: (size ?? 40) * 0.5,
        ),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
