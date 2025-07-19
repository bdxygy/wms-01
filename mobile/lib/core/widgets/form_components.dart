import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';

/// Form components for the WMS application
/// Provides consistent form field styles and validation

/// Standard text form field
class WMSTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final FocusNode? focusNode;

  const WMSTextFormField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: WMSTypography.formLabel,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          focusNode: focusNode,
          style: WMSTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: WMSTypography.formHint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.errorRed, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.errorRed, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.textDisabled),
            ),
            filled: true,
            fillColor: enabled 
                ? Theme.of(context).colorScheme.surface
                : WMSColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorStyle: WMSTypography.formError,
          ),
        ),
      ],
    );
  }
}

/// Dropdown form field
class WMSDropdownFormField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const WMSDropdownFormField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: WMSTypography.formLabel,
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: WMSTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: WMSTypography.formHint,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.errorRed, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.errorRed, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WMSColors.textDisabled),
            ),
            filled: true,
            fillColor: enabled 
                ? Theme.of(context).colorScheme.surface
                : WMSColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorStyle: WMSTypography.formError,
          ),
        ),
      ],
    );
  }
}

/// Switch form field
class WMSSwitchFormField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final bool enabled;

  const WMSSwitchFormField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        label,
        style: WMSTypography.bodyMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: WMSTypography.bodySmall.copyWith(
                color: WMSColors.textSecondary,
              ),
            )
          : null,
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: WMSColors.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// Checkbox form field
class WMSCheckboxFormField extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final FormFieldValidator<bool>? validator;
  final String? subtitle;
  final bool enabled;

  const WMSCheckboxFormField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.validator,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(
                label,
                style: WMSTypography.bodyMedium,
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle!,
                      style: WMSTypography.bodySmall.copyWith(
                        color: WMSColors.textSecondary,
                      ),
                    )
                  : null,
              value: state.value ?? false,
              onChanged: enabled 
                  ? (bool? newValue) {
                      state.didChange(newValue);
                      onChanged?.call(newValue);
                    }
                  : null,
              activeColor: WMSColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: WMSTypography.formError,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Radio button group form field
class WMSRadioGroupFormField<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<WMSRadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  const WMSRadioGroupFormField({
    super.key,
    this.label,
    this.value,
    required this.options,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: WMSTypography.formLabel,
              ),
              const SizedBox(height: 8),
            ],
            ...options.map((option) => RadioListTile<T>(
              title: Text(
                option.label,
                style: WMSTypography.bodyMedium,
              ),
              subtitle: option.subtitle != null
                  ? Text(
                      option.subtitle!,
                      style: WMSTypography.bodySmall.copyWith(
                        color: WMSColors.textSecondary,
                      ),
                    )
                  : null,
              value: option.value,
              groupValue: state.value,
              onChanged: enabled 
                  ? (T? newValue) {
                      state.didChange(newValue);
                      onChanged?.call(newValue);
                    }
                  : null,
              activeColor: WMSColors.primaryBlue,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            )),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: WMSTypography.formError,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Radio option data class
class WMSRadioOption<T> {
  final T value;
  final String label;
  final String? subtitle;

  const WMSRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

/// Date picker form field
class WMSDateFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final FormFieldValidator<DateTime>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final Widget? prefixIcon;

  const WMSDateFormField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return WMSTextFormField(
      label: label,
      hint: hint,
      controller: TextEditingController(
        text: value != null 
            ? '${value!.day}/${value!.month}/${value!.year}'
            : '',
      ),
      readOnly: true,
      enabled: enabled,
      prefixIcon: prefixIcon ?? const Icon(Icons.calendar_today),
      onTap: enabled ? () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (pickedDate != null) {
          onChanged?.call(pickedDate);
        }
      } : null,
      validator: validator != null 
          ? (String? text) => validator!(value)
          : null,
    );
  }
}

/// Time picker form field
class WMSTimeFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?>? onChanged;
  final FormFieldValidator<TimeOfDay>? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const WMSTimeFormField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return WMSTextFormField(
      label: label,
      hint: hint,
      controller: TextEditingController(
        text: value != null 
            ? value!.format(context)
            : '',
      ),
      readOnly: true,
      enabled: enabled,
      prefixIcon: prefixIcon ?? const Icon(Icons.access_time),
      onTap: enabled ? () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onChanged?.call(pickedTime);
        }
      } : null,
      validator: validator != null 
          ? (String? text) => validator!(value)
          : null,
    );
  }
}