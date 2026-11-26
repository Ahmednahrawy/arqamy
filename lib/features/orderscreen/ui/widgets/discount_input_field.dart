import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Compact discount control used immediately before the collection field.
///
/// The icon opens the field and stays small when closed. Once open, the inner
/// icon switches between entering a fixed amount and a percentage. The active
/// mode is remembered for the rest of the app session.
class DiscountInputField extends StatelessWidget {
  const DiscountInputField({
    super.key,
    required this.controller,
    required this.type,
    required this.subtotal,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onTypeChanged,
    required this.onChanged,
  });

  final TextEditingController controller;
  final InvoiceDiscountType type;
  final double subtotal;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<InvoiceDiscountType> onTypeChanged;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final colors = Theme.of(context).colorScheme;
    final discount = InvoiceDiscount.fromText(controller.text, type, subtotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const ValueKey('discount-toggle'),
              tooltip: strings.discount,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
              onPressed: () {
                InvoiceDiscount.lastUsedType = type;
                onToggleExpanded();
              },
              icon: const Icon(Icons.local_offer_outlined, size: 19),
            ),
            if (discount != null) ...[
              const SizedBox(width: 8),
              Text(
                _summary(discount, strings),
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !expanded
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AppTextFormField(
                    key: const ValueKey('discount-value'),
                    controller: controller,
                    labelText: type == InvoiceDiscountType.amount
                        ? strings.discount_amount
                        : strings.discount_percent,
                    suffixText: type == InvoiceDiscountType.percent
                        ? '%'
                        : strings.currency,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const ValueKey('discount-mode-switch'),
                          tooltip: type == InvoiceDiscountType.amount
                              ? strings.switch_to_percent
                              : strings.switch_to_amount,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            type == InvoiceDiscountType.amount
                                ? Icons.percent
                                : Icons.attach_money,
                            size: 18,
                          ),
                          onPressed: () {
                            final next = type == InvoiceDiscountType.amount
                                ? InvoiceDiscountType.percent
                                : InvoiceDiscountType.amount;
                            InvoiceDiscount.lastUsedType = next;
                            onTypeChanged(next);
                          },
                        ),
                        if (controller.text.isNotEmpty)
                          IconButton(
                            key: const ValueKey('discount-clear'),
                            tooltip: strings.clear_discount,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                          ),
                      ],
                    ),
                    validator: (value) =>
                        _validator(value, type, subtotal, strings),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }

  static String? _validator(
    String? value,
    InvoiceDiscountType type,
    double subtotal,
    S strings,
  ) {
    switch (InvoiceDiscount.validateText(value, type, subtotal)) {
      case InvoiceDiscountValidationError.invalidNumber:
      case InvoiceDiscountValidationError.negative:
        return strings.invalidNumber;
      case InvoiceDiscountValidationError.percentOutOfRange:
        return strings.discount_percent_range;
      case InvoiceDiscountValidationError.exceedsSubtotal:
        return strings.discount_exceeds_total;
      case null:
        return null;
    }
  }

  static String _summary(InvoiceDiscount discount, S strings) {
    if (discount.type == InvoiceDiscountType.percent) {
      return '${discount.value.toStringAsFixed(2)}% '
          '(${discount.amount.toStringAsFixed(2)} ${strings.currency})';
    }
    return '${discount.amount.toStringAsFixed(2)} ${strings.currency}';
  }
}
