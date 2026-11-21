/// A fixed-scale (2 decimals) money amount stored as whole minor units.
///
/// Rounding rule (Decision 29): half away from zero at 0.01.
/// This type is currency-agnostic on purpose; the app displays every amount
/// with two decimals, so the scale matches what users already see.
class Money implements Comparable<Money> {
  const Money.fromMinorUnits(this.minorUnits);

  /// Rounds [value] to 0.01, half away from zero.
  factory Money.fromDouble(double value) =>
      Money.fromMinorUnits(_roundToMinorUnits(value));

  static const Money zero = Money.fromMinorUnits(0);

  /// Whole hundredths, e.g. 82.25 is 8225.
  final int minorUnits;

  // Kept below 1e12 so minor units stay exact even on web (53-bit integers).
  static const double _maxAbsValue = 1e12;

  static int _roundToMinorUnits(double value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'must be a finite number');
    }
    if (value.abs() >= _maxAbsValue) {
      throw RangeError.value(value, 'value', 'is too large for Money');
    }
    // Eight decimals absorb binary floating-point noise (1.005 is stored as
    // 1.00499999999999989...), then we round half-up on the magnitude.
    final digits = value.abs().toStringAsFixed(8);
    final dot = digits.indexOf('.');
    final whole = int.parse(digits.substring(0, dot));
    final cents = int.parse(digits.substring(dot + 1, dot + 3));
    final roundUp = digits.codeUnitAt(dot + 3) >= 0x35; // the digit '5'
    final magnitude = whole * 100 + cents + (roundUp ? 1 : 0);
    return value < 0 ? -magnitude : magnitude;
  }

  static Money sum(Iterable<Money> amounts) =>
      amounts.fold(zero, (total, amount) => total + amount);

  double toDouble() => minorUnits / 100;

  bool get isZero => minorUnits == 0;
  bool get isNegative => minorUnits < 0;

  Money abs() => Money.fromMinorUnits(minorUnits.abs());

  Money operator +(Money other) =>
      Money.fromMinorUnits(minorUnits + other.minorUnits);

  Money operator -(Money other) =>
      Money.fromMinorUnits(minorUnits - other.minorUnits);

  Money operator -() => Money.fromMinorUnits(-minorUnits);

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minorUnits == minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() {
    final sign = minorUnits < 0 ? '-' : '';
    final absolute = minorUnits.abs();
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$sign${absolute ~/ 100}.$fraction';
  }
}