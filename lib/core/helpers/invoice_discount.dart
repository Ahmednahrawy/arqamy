import 'package:arqamy/core/helpers/money.dart';

enum InvoiceDiscountType { amount, percent }

extension InvoiceDiscountTypeStorage on InvoiceDiscountType {
  String get storageValue =>
      this == InvoiceDiscountType.amount ? 'amount' : 'percent';

  static InvoiceDiscountType fromStorage(Object? value) =>
      value == 'percent' ? InvoiceDiscountType.percent : InvoiceDiscountType.amount;
}

enum InvoiceDiscountValidationError {
  invalidNumber,
  negative,
  percentOutOfRange,
  exceedsSubtotal,
}

/// A discount entered by the user and its resolved currency amount.
///
/// [value] is the raw input: a currency amount or a percentage. [amount] is
/// always the rounded currency amount actually subtracted from the subtotal.
class InvoiceDiscount {
  const InvoiceDiscount({
    required this.type,
    required this.value,
    required this.amount,
  });

  final InvoiceDiscountType type;
  final double value;
  final double amount;

  /// The mode shown the next time a discount control is opened.
  ///
  /// Kept in memory only: the choice lives for the current app session.
  static InvoiceDiscountType lastUsedType = InvoiceDiscountType.amount;

  static InvoiceDiscountValidationError? validateText(
    String? text,
    InvoiceDiscountType type,
    double subtotal,
  ) {
    final raw = text?.trim() ?? '';
    if (raw.isEmpty) return null;
    final parsed = Money.tryParse(raw);
    if (parsed == null || Money.tryFromDouble(parsed.toDouble()) == null) {
      return InvoiceDiscountValidationError.invalidNumber;
    }
    if (parsed.isNegative) return InvoiceDiscountValidationError.negative;

    final subtotalMoney = Money.tryFromDouble(subtotal);
    if (subtotalMoney == null) {
      return InvoiceDiscountValidationError.invalidNumber;
    }

    if (type == InvoiceDiscountType.percent && parsed.toDouble() > 100) {
      return InvoiceDiscountValidationError.percentOutOfRange;
    }

    final amount = type == InvoiceDiscountType.percent
        ? Money.fromDouble(subtotalMoney.toDouble() * parsed.toDouble() / 100)
        : parsed;
    if (amount.compareTo(subtotalMoney) > 0) {
      return InvoiceDiscountValidationError.exceedsSubtotal;
    }
    return null;
  }

  static InvoiceDiscount? fromText(
    String? text,
    InvoiceDiscountType type,
    double subtotal,
  ) {
    if (validateText(text, type, subtotal) != null) return null;
    final raw = text?.trim() ?? '';
    if (raw.isEmpty) return null;

    final value = Money.tryParse(raw)!.toDouble();
    final subtotalMoney = Money.fromDouble(subtotal);
    final amount = type == InvoiceDiscountType.percent
        ? Money.fromDouble(subtotalMoney.toDouble() * value / 100)
        : Money.fromDouble(value);
    return InvoiceDiscount(type: type, value: value, amount: amount.toDouble());
  }

  static double payableTotal(double subtotal, InvoiceDiscount? discount) =>
      (Money.fromDouble(subtotal) - Money.fromDouble(discount?.amount ?? 0))
          .toDouble();

  Map<String, dynamic> toJson() => {
        'type': type.storageValue,
        'value': value,
        'amount': amount,
      };

  static InvoiceDiscount? fromJson(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map) return null;
    final value = raw['value'];
    final amount = raw['amount'];
    if (value is! num || amount is! num) return null;
    return InvoiceDiscount(
      type: InvoiceDiscountTypeStorage.fromStorage(raw['type']),
      value: value.toDouble(),
      amount: amount.toDouble(),
    );
  }
}
