/// The invoice types the app knows about.
///
/// The Arabic [storedValue] strings are persisted in saved invoices and in the
/// ledger source data, so they must never change; only their presentation is
/// localized.
enum InvoiceAction {
  purchase('شراء'),
  sale('بيع'),
  storage('تخزين');

  const InvoiceAction(this.storedValue);

  final String storedValue;

  /// Stored values in the order the type selectors show them.
  static List<String> get storedValues =>
      [for (final action in values) action.storedValue];

  /// Returns the action for a stored value, ignoring tatweel and surrounding
  /// spaces, or null when the value is empty or not a known type.
  static InvoiceAction? tryParse(String? value) {
    final normalized = value?.replaceAll('\u0640', '').trim();
    for (final action in values) {
      if (action.storedValue == normalized) return action;
    }
    return null;
  }
}