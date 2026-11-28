import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/core/helpers/invoice_export_columns.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/settingscreen/data/models/invoice_settings_snapshot.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Product _product({required double packageWeight, int packages = 1}) => Product(
  name: 'Rice',
  weight: 10,
  packageWeight: packageWeight,
  numberPackage: packages,
  price: 20,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('column visibility', () {
    test('hidden columns round trip through JSON', () {
      const visibility = InvoiceColumnVisibility();
      final hidden = visibility
          .setVisible(InvoiceTableColumn.product, false)
          .setVisible(InvoiceTableColumn.total, false);

      expect(hidden.toJson()['hidden'], ['product', 'total']);
      expect(InvoiceColumnVisibility.fromJson(hidden.toJson()), hidden);
      expect(hidden.isVisible(InvoiceTableColumn.price), isTrue);
      expect(hidden.isVisible(InvoiceTableColumn.product), isFalse);
    });

    test('missing or malformed saved data keeps every column visible', () {
      expect(
        InvoiceColumnVisibility.fromJson(null),
        InvoiceColumnVisibility.allVisible,
      );
      expect(
        InvoiceColumnVisibility.fromJson('not an object'),
        InvoiceColumnVisibility.allVisible,
      );
      expect(
        InvoiceColumnVisibility.fromJson({'hidden': ['unknown']}),
        InvoiceColumnVisibility.allVisible,
      );
      expect(
        InvoiceColumnVisibility.tryParseJson({'hidden': ['unknown']}),
        isNull,
      );
    });
  });

  group('package weight display', () {
    test('one shared weight becomes a note, different weights stay a column', () {
      final same = InvoicePackageWeights.fromProducts([
        _product(packageWeight: 2),
        _product(packageWeight: 2),
      ]);
      final different = InvoicePackageWeights.fromProducts([
        _product(packageWeight: 2),
        _product(packageWeight: 3),
      ]);

      expect(same.hasSingleWeight, isTrue);
      expect(
        resolvePackageWeightDisplay(enabled: true, weights: same),
        PackageWeightDisplay.note,
      );
      expect(different.hasMultipleWeights, isTrue);
      expect(
        resolvePackageWeightDisplay(enabled: true, weights: different),
        PackageWeightDisplay.column,
      );
    });

    test('no packages or a disabled column hide package weight entirely', () {
      final noPackages = InvoicePackageWeights.fromProducts([
        _product(packageWeight: 2, packages: 0),
      ]);
      final weights = InvoicePackageWeights.fromProducts([
        _product(packageWeight: 2),
        _product(packageWeight: 3),
      ]);
      final disabled = const InvoiceColumnVisibility().setVisible(
        InvoiceTableColumn.packageWeight,
        false,
      );

      expect(
        resolvePackageWeightDisplay(enabled: true, weights: noPackages),
        PackageWeightDisplay.hidden,
      );
      expect(
        resolvePackageWeightDisplay(enabled: false, weights: weights),
        PackageWeightDisplay.hidden,
      );
      expect(disabled.isVisible(InvoiceTableColumn.packageWeight), isFalse);
    });
  });

  group('settings', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('PDF and Excel visibility persist and backup independently', () async {
      final settings = InvoiceSettingsProvider();
      await settings.loadSettings();
      final pdfColumns = const InvoiceColumnVisibility().setVisible(
        InvoiceTableColumn.packageWeight,
        false,
      );
      final excelColumns = const InvoiceColumnVisibility().setVisible(
        InvoiceTableColumn.serial,
        false,
      );

      await settings.updateSettings(
        pdfColumnVisibility: pdfColumns,
        excelColumnVisibility: excelColumns,
      );

      final reloaded = InvoiceSettingsProvider();
      await reloaded.loadSettings();
      expect(reloaded.pdfColumns, pdfColumns);
      expect(reloaded.excelColumns, excelColumns);
      expect(reloaded.pdfColumns, isNot(excelColumns));

      final backup = InvoiceBackup.encode(
        const [],
        exportedAt: DateTime.utc(2026, 11, 28),
        settings: reloaded.snapshot(),
      );
      final restored = InvoiceBackup.decodeSettings(backup);
      expect(restored?.pdfColumnVisibility, pdfColumns);
      expect(restored?.excelColumnVisibility, excelColumns);

      await reloaded.resetToDefaults();
      expect(reloaded.pdfColumns, InvoiceColumnVisibility.allVisible);
      expect(reloaded.excelColumns, InvoiceColumnVisibility.allVisible);
      expect(reloaded.snapshot(), InvoiceSettingsSnapshot.defaults());
    });
  });
}
