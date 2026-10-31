import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTokens.s8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: obscure ? 1 : maxLines,
          enabled: enabled,
          autofocus: autofocus,
          validator: validator,
          autofillHints: autofillHints,
          style: AppTextStyles.bodyL,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: AppTokens.iconList),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
