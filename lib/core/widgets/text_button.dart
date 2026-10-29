import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback onPressed;
  const AppTextButton({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonHeight,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final button = TextButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? colors.primary,
        ),
        padding: WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 12,
            vertical: verticalPadding ?? 14,
          ),
        ),
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(0, buttonHeight ?? 0),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(double.infinity, buttonHeight ?? double.infinity),
        ),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          buttonText,
          style: textStyle,
        ),
      ),
    );
    return buttonHeight == null
        ? button
        : SizedBox(height: buttonHeight, child: button);
  }
}
