import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// كارد موحد للتطبيق
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool elevated;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevated = false,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = elevated 
        ? AppDesignSystem.elevatedCardDecoration
        : AppDesignSystem.cardDecoration;
    
    final finalDecoration = backgroundColor != null
        ? decoration.copyWith(color: backgroundColor)
        : decoration;
    
    final finalDecorationWithRadius = borderRadius != null
        ? finalDecoration.copyWith(
            borderRadius: BorderRadius.circular(borderRadius!),
          )
        : finalDecoration;

    Widget cardWidget = Container(
      margin: margin,
      decoration: finalDecorationWithRadius,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDesignSystem.spaceMD),
        child: child,
      ),
    );

    if (onTap != null) {
      cardWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDesignSystem.radiusLG,
        ),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// كارد إحصائية
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.spaceSM),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppDesignSystem.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppDesignSystem.primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.spaceMD),
          Text(
            value,
            style: AppDesignSystem.headingLG.copyWith(
              fontSize: AppDesignSystem.getResponsiveFontSize(
                context, 
                AppDesignSystem.fontSize2XL,
              ),
            ),
          ),
          const SizedBox(height: AppDesignSystem.spaceXS),
          Text(
            title,
            style: AppDesignSystem.bodySM,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// كارد قائمة
class ListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const ListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppDesignSystem.spaceMD),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppDesignSystem.spaceMD),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.bodyMD.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDesignSystem.spaceXS),
                  Text(
                    subtitle!,
                    style: AppDesignSystem.bodySM,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDesignSystem.spaceMD),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// كارد فارغ
class EmptyCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: AppDesignSystem.textMuted,
            ),
            const SizedBox(height: AppDesignSystem.spaceMD),
          ],
          Text(
            title,
            style: AppDesignSystem.headingSM,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDesignSystem.spaceXS),
            Text(
              subtitle!,
              style: AppDesignSystem.bodySM,
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDesignSystem.spaceMD),
            action!,
          ],
        ],
      ),
    );
  }
}
