import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// تخطيط متجاوب موحد
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor ?? AppDesignSystem.backgroundColor,
      child: Padding(
        padding: padding ?? EdgeInsets.all(
          AppDesignSystem.getResponsivePadding(context),
        ),
        child: child,
      ),
    );
  }
}

/// شبكة متجاوبة
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? forceColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = AppDesignSystem.spaceMD,
    this.runSpacing = AppDesignSystem.spaceMD,
    this.forceColumns,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? AppDesignSystem.getGridColumns(context);
    final aspectRatio = childAspectRatio ?? AppDesignSystem.getCardAspectRatio(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// صف متجاوب
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = AppDesignSystem.spaceMD,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // في الشاشات الصغيرة، حول إلى عمود
    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: child,
        )).toList(),
      );
    }

    // في الشاشات الكبيرة، استخدم صف
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < children.length - 1 ? spacing : 0,
            ),
            child: child,
          ),
        );
      }).toList(),
    );
  }
}

/// حاوية متجاوبة
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 1200,
      ),
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}

/// قسم الصفحة
class PageSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? action;

  const PageSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDesignSystem.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: AppDesignSystem.headingLG.copyWith(
                        fontSize: AppDesignSystem.getResponsiveFontSize(
                          context,
                          AppDesignSystem.fontSize2XL,
                        ),
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
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: AppDesignSystem.spaceLG),
          ],
          Container(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// شريط التطبيق المتجاوب
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppDesignSystem.headingSM.copyWith(
          color: foregroundColor ?? Colors.white,
          fontSize: AppDesignSystem.getResponsiveFontSize(
            context,
            AppDesignSystem.fontSizeLG,
          ),
        ),
      ),
      backgroundColor: backgroundColor ?? AppDesignSystem.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
