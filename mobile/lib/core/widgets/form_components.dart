import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_colors.dart';
import '../theme/typography.dart';
import '../utils/imei_utils.dart';
import '../providers/app_provider.dart';
import '../routing/app_router.dart';
import '../utils/scanner_launcher.dart';

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
              borderSide:
                  const BorderSide(color: WMSColors.primaryBlue, width: 2),
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
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          isExpanded: true, // This helps prevent overflow
          style: WMSTypography.bodyMedium.copyWith(
            color: enabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          iconEnabledColor: Theme.of(context).colorScheme.onSurface,
          iconDisabledColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: WMSTypography.formHint.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
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
              borderSide:
                  const BorderSide(color: WMSColors.primaryBlue, width: 2),
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
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        text:
            value != null ? '${value!.day}/${value!.month}/${value!.year}' : '',
      ),
      readOnly: true,
      enabled: enabled,
      prefixIcon: prefixIcon ?? const Icon(Icons.calendar_today),
      onTap: enabled
          ? () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (pickedDate != null) {
                onChanged?.call(pickedDate);
              }
            }
          : null,
      validator: validator != null ? (String? text) => validator!(value) : null,
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
        text: value != null ? value!.format(context) : '',
      ),
      readOnly: true,
      enabled: enabled,
      prefixIcon: prefixIcon ?? const Icon(Icons.access_time),
      onTap: enabled
          ? () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
              );
              if (pickedTime != null) {
                onChanged?.call(pickedTime);
              }
            }
          : null,
      validator: validator != null ? (String? text) => validator!(value) : null,
    );
  }
}

/// Photo picker form field
class WMSPhotoFormField extends StatelessWidget {
  final String? label;
  final String? imageUrl;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final VoidCallback? onImagePicked;

  const WMSPhotoFormField({
    super.key,
    this.label,
    this.imageUrl,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: imageUrl,
      validator: validator,
      builder: (FormFieldState<String> state) {
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
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      state.hasError ? WMSColors.errorRed : WMSColors.outline,
                  width: state.hasError ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: state.value != null && state.value!.isNotEmpty
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            state.value!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(context);
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: enabled
                                ? () {
                                    state.didChange(null);
                                    onChanged?.call(null);
                                  }
                                : null,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.5),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: enabled ? onImagePicked : null,
                      borderRadius: BorderRadius.circular(12),
                      child: _buildPlaceholder(context),
                    ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: WMSColors.surfaceVariant,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48,
            color: WMSColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add photo',
            style: WMSTypography.bodyMedium.copyWith(
              color: WMSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic IMEI array form field
class WMSImeiArrayFormField extends StatefulWidget {
  final String? label;
  final List<String> initialImeis;
  final ValueChanged<List<String>>? onChanged;
  final FormFieldValidator<List<String>>? validator;
  final bool enabled;
  final bool allowScanning;

  const WMSImeiArrayFormField({
    super.key,
    this.label,
    this.initialImeis = const [],
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.allowScanning = true,
  });

  @override
  State<WMSImeiArrayFormField> createState() => _WMSImeiArrayFormFieldState();
}

class _WMSImeiArrayFormFieldState extends State<WMSImeiArrayFormField> {
  late List<TextEditingController> _controllers;
  late List<String> _imeis;

  @override
  void initState() {
    super.initState();
    setState(() {
      _imeis = List.from(widget.initialImeis);

      print('📱 IMEIs Form: $_imeis');

      if (_imeis.isEmpty) {
        _imeis = [''];
      }

      _controllers =
          _imeis.map((imei) => TextEditingController(text: imei)).toList();
    });
  }

  @override
  void didUpdateWidget(covariant WMSImeiArrayFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _imeis = List.from(widget.initialImeis);

      if (_imeis.isEmpty) {
        _imeis = [''];
      }

      _controllers =
          _imeis.map((imei) => TextEditingController(text: imei)).toList();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addImeiField() {
    setState(() {
      _controllers.add(TextEditingController());
      _imeis.add('');
      _notifyChange();
    });
  }

  void _removeImeiField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
        _imeis.removeAt(index);
        _notifyChange();
      });
    }
  }

  void _notifyChange() {
    final validImeis = _imeis.where((imei) => imei.trim().isNotEmpty).toList();
    widget.onChanged?.call(validImeis);
  }

  void _scanImei(int index) {
    if (!widget.allowScanning) return;

    ScannerLauncher.forImeiEntry(
      context,
      title: 'Scan IMEI Barcode',
      subtitle: 'Scan the IMEI barcode on the device',
      onImeiScanned: (imei) {
        setState(() {
          _controllers[index].text = imei;
          _imeis[index] = imei;
          _notifyChange();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: _imeis,
      validator: widget.validator,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Row(
                children: [
                  Text(
                    widget.label!,
                    style: WMSTypography.formLabel,
                  ),
                  const Spacer(),
                  Text(
                    '${_imeis.where((imei) => imei.trim().isNotEmpty).length} IMEI(s)',
                    style: WMSTypography.bodySmall.copyWith(
                      color: WMSColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...List.generate(_controllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: WMSTextFormField(
                        controller: _controllers[index],
                        hint: 'Enter IMEI ${index + 1}',
                        keyboardType: TextInputType.number,
                        enabled: widget.enabled,
                        onChanged: (value) {
                          _imeis[index] = value;
                          _notifyChange();
                          state.didChange(_imeis);
                        },
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            // Only validate non-empty IMEIs
                            if (!ImeiUtils.isValidImei(value.trim())) {
                              return 'Invalid IMEI';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.allowScanning && widget.enabled)
                      IconButton(
                        onPressed: () => _scanImei(index),
                        icon: const Icon(Icons.qr_code_scanner),
                        color: WMSColors.primaryBlue,
                        tooltip: 'Scan IMEI',
                      ),
                    if (_controllers.length > 1)
                      IconButton(
                        onPressed: widget.enabled
                            ? () => _removeImeiField(index)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: WMSColors.errorRed,
                        tooltip: 'Remove IMEI',
                      ),
                  ],
                ),
              );
            }),
            if (widget.enabled)
              TextButton.icon(
                onPressed: _addImeiField,
                icon: const Icon(Icons.add),
                label: const Text('Add IMEI'),
              ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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

/// Currency input form field with formatting
class WMSCurrencyFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final double? initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<double?>? onChanged;
  final bool enabled;

  const WMSCurrencyFormField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<WMSCurrencyFormField> createState() => _WMSCurrencyFormFieldState();
}

class _WMSCurrencyFormFieldState extends State<WMSCurrencyFormField> {
  late TextEditingController _controller;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(
        text: widget.initialValue?.toStringAsFixed(2) ?? '',
      );
      _isControllerOwned = true;
    }
  }

  @override
  void dispose() {
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return WMSTextFormField(
      label: widget.label,
      hint: widget.hint,
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: widget.enabled,
      prefixText: appProvider.currency.symbol,
      validator: widget.validator,
      onChanged: (value) {
        final parsedValue = double.tryParse(value);
        widget.onChanged?.call(parsedValue);
      },
    );
  }
}
