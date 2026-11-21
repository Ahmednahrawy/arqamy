import 'package:arqamy/core/helpers/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.fromDouble rounds half away from zero at 0.01', () {
    const cases = <double, int>{
      1.005: 101, // naive (1.005 * 100).round() gives 100
      2.675: 268,
      0.285: 29,
      1.255: 126,
      82.25125: 8225,
      -1.005: -101,
      -82.25125: -8225,
      0.004: 0,
      0.005: 1,
      -0.005: -1,
      0.994999: 99,
      123456.785: 12345679,
      0.1 + 0.2: 30,
      0.0: 0,
      20.0: 2000,
    };

    cases.forEach((input, expected) {
      test('$input becomes $expected minor units', () {
        expect(Money.fromDouble(input).minorUnits, expected);
      });
    });
  });

  test('a line total is rounded once, from the exact product', () {
    const netWeight = 12.345 - (0.5 * 2);
    expect(Money.fromDouble(netWeight * 7.25).minorUnits, 8225);
  });

  test('ten rounded lines sum to the visible total', () {
    final lines = List.generate(10, (_) => Money.fromDouble(0.1 * 1.1));
    expect(Money.sum(lines), const Money.fromMinorUnits(110));
  });

  test('arithmetic is exact', () {
    expect(
      Money.fromDouble(0.1) + Money.fromDouble(0.2),
      Money.fromDouble(0.3),
    );
    expect(
      Money.fromDouble(82.25) - Money.fromDouble(82.25125),
      Money.zero,
    );
    expect(-const Money.fromMinorUnits(5), const Money.fromMinorUnits(-5));
    expect(const Money.fromMinorUnits(-5).abs(), const Money.fromMinorUnits(5));
  });

  test('comparison, equality and flags', () {
    expect(const Money.fromMinorUnits(1).compareTo(const Money.fromMinorUnits(2)), -1);
    expect(const Money.fromMinorUnits(7), const Money.fromMinorUnits(7));
    expect(const Money.fromMinorUnits(7).hashCode, const Money.fromMinorUnits(7).hashCode);
    expect(Money.zero.isZero, isTrue);
    expect(const Money.fromMinorUnits(-1).isNegative, isTrue);
  });

  test('toString and toDouble', () {
    expect(const Money.fromMinorUnits(8225).toString(), '82.25');
    expect(const Money.fromMinorUnits(-5).toString(), '-0.05');
    expect(Money.zero.toString(), '0.00');
    expect(const Money.fromMinorUnits(8225).toDouble(), 82.25);
  });

  test('rejects values that cannot be represented', () {
    expect(() => Money.fromDouble(double.nan), throwsArgumentError);
    expect(() => Money.fromDouble(double.infinity), throwsArgumentError);
    expect(() => Money.fromDouble(1e12), throwsRangeError);
  });
}