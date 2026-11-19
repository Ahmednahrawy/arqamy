import 'package:arqamy/generated/l10n.dart';

/// Maps the canonical (stored) invoice action values to localized labels.
///
/// The canonical values are persisted in the database and must never change;
/// only their presentation is localized.
class InvoiceActionL10n {
  const InvoiceActionL10n._();

  static const String purchase = 'شراء';
  static const String sale = 'بيع';
  static const String storage = 'تخزين';

  static const List<String> actions = [purchase, sale, storage];

  static String? normalize(String? action) =>
      action?.replaceAll('\u0640', '').trim();

  static String label(String? action, S strings) {
    switch (normalize(action)) {
      case purchase:
        return strings.purchase;
      case sale:
        return strings.sale;
      case storage:
        return strings.storage;
      default:
        return action ?? strings.unspecified;
    }
  }
}
