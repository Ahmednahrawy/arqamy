import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final bool? isObscureText;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final Function(String?) validator;
  final String? labelText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Function()? onEditingComplete;
  final TextDirection? textDirection;

  const AppTextFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    required this.validator,
    this.labelText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return TextFormField(
      textDirection: textDirection,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: colors.primary, width: 1.3),
              borderRadius: BorderRadius.circular(16.sp),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: colors.outline, width: 1.3),
              borderRadius: BorderRadius.circular(16.sp),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 1.3),
          borderRadius: BorderRadius.circular(16.sp),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 1.3),
          borderRadius: BorderRadius.circular(16.sp),
        ),
        hintStyle: hintStyle ??
            theme.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        fillColor: backgroundColor ?? colors.surface,
        filled: true,
      ),
      obscureText: isObscureText ?? false,
      style: inputTextStyle ?? theme.textTheme.bodyMedium,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: labelText == 'عدد العبوات'
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      validator: (value) {
        return validator(value);
      },
    );
  }
}
