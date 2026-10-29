import 'package:flutter/material.dart';
import 'package:arqamy/config/theme/colors.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  showAppSnackBarOn(
    ScaffoldMessenger.of(context),
    message,
    isError: isError,
  );
}

void showAppSnackBarOn(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  if (!messenger.mounted) return;

  final theme = Theme.of(messenger.context);
  final semanticColors = AppSemanticColors.of(messenger.context);
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color:
                isError ? theme.colorScheme.onError : semanticColors.onSuccess,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? theme.colorScheme.onError
                    : semanticColors.onSuccess,
              ),
            ),
          ),
        ],
      ),
      backgroundColor:
          isError ? theme.colorScheme.error : semanticColors.success,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
