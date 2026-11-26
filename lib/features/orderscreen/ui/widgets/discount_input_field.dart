import 'package:arqamy/core/helpers/invoice_discount.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Compact, labeled discount control used immediately before the collection
/// field.
///
/// The whole row is tappable and always says what it does, so the discount is
/// discoverable without interpreting an icon. Once open, the inner icon
/// switches between entering a fixed amount and a percentage. The active mode
/// is remembered for the rest of the app session.
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
    final label = discount == null ? strings.add_discount : strings.discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: label,
          child: InkWell(
            key: const ValueKey('discount-toggle'),
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              InvoiceDiscount.lastUsedType = type;
              onToggleExpanded();
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 19,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (discount != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _summary(discount, strings),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
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
