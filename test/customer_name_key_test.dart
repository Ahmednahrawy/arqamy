import 'package:arqamy/core/helpers/customer_name_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cleanCustomerName', () {
    test('trims and collapses spaces', () {
      expect(cleanCustomerName('  أحمد   علي '), 'أحمد علي');
    });

    test('removes invisible direction and zero-width marks', () {
      expect(cleanCustomerName('أحمد\u200F\u200B علي\uFEFF'), 'أحمد علي');
    });

    test('leaves the letters themselves untouched', () {
      expect(cleanCustomerName('أحم\u0640د'), 'أحم\u0640د');
    });
  });

  group('customerNameKey gives the same key for', () {
    void same(String label, String a, String b) {
      test(label, () => expect(customerNameKey(a), customerNameKey(b)));
    }

    same('case and extra spaces', 'Ahmed  Ali ', 'ahmed ali');
    same('tatweel', 'أحم\u0640د', 'أحمد');
    same('diacritics', 'مُحَمَّد', 'محمد');
    same('hamza on alef', 'أحمد', 'احمد');
    same('hamza below alef', 'إبراهيم', 'ابراهيم');
    same('alef madda and taa marbuta', 'آمنة', 'امنه');
    same('alef maqsura', 'مصطفى', 'مصطفي');
    same('Arabic-Indic digits', 'عميل ٢', 'عميل 2');
    same('Persian digits', 'عميل ۲', 'عميل 2');
    same('invisible direction marks', 'أحمد\u200F', 'أحمد');
  });

  test('different names keep different keys', () {
    expect(
      customerNameKey('أحمد علي'),
      isNot(customerNameKey('أحمد حسن')),
    );
  });

  test('names with no letters give an empty key', () {
    expect(customerNameKey('   '), '');
    expect(customerNameKey('\u0640\u200B'), '');
  });
}