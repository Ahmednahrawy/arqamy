final _invisibleMarks = RegExp(
  '[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
);

/// Trims, collapses spaces and removes invisible direction or zero-width marks
/// that sneak in when names are copied from chats. The letters are untouched.
String cleanCustomerName(String name) {
  return name
      .replaceAll(_invisibleMarks, '')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// Normalizes a customer name for comparison only.
///
/// Used to find spellings that probably belong to the same customer so the
/// owner can confirm them (Decision 39). It never decides anything by itself
/// and must not be stored or used as an identifier.
String customerNameKey(String name) {
  var value = cleanCustomerName(name)
      // Tatweel (kashida) and Arabic diacritics.
      .replaceAll(RegExp('[\u0640\u064B-\u065F\u0670]'), '')
      // Alef variants, alef maqsura and taa marbuta.
      .replaceAll(RegExp('[\u0623\u0625\u0622\u0671]'), '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647');
  value = value.replaceAllMapped(
    RegExp('[\u0660-\u0669]'),
    (match) => String.fromCharCode(match[0]!.codeUnitAt(0) - 0x0660 + 0x30),
  );
  value = value.replaceAllMapped(
    RegExp('[\u06F0-\u06F9]'),
    (match) => String.fromCharCode(match[0]!.codeUnitAt(0) - 0x06F0 + 0x30),
  );
  return value.trim().toLowerCase();
}