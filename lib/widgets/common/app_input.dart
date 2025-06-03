import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system.dart';

/// حقل إدخال موحد
class AppTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final void Function()? onTap;

  const AppTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.textInputAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onTap: onTap,
      style: AppDesignSystem.bodyMD,
      decoration: AppDesignSystem.inputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// قائمة منبثقة موحدة
class AppDropdown<T> extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: AppDesignSystem.bodyMD,
      decoration: AppDesignSystem.inputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
      dropdownColor: AppDesignSystem.surfaceColor,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
    );
  }
}

/// مفتاح تبديل موحد
class AppSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool)? onChanged;
  final Widget? leading;

  const AppSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.spaceMD),
      decoration: AppDesignSystem.cardDecoration,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppDesignSystem.primaryColor,
            activeTrackColor: AppDesignSystem.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

/// مربع اختيار موحد
class AppCheckbox extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool?)? onChanged;
  final Widget? leading;

  const AppCheckbox({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppDesignSystem.spaceMD),
        decoration: AppDesignSystem.cardDecoration,
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppDesignSystem.primaryColor,
            ),
            const SizedBox(width: AppDesignSystem.spaceSM),
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
          ],
        ),
      ),
    );
  }
}
