import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/settingscreen/data/models/invoice_settings_snapshot.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('new installations use sensible order defaults', () async {
    final settings = InvoiceSettingsProvider();
    await settings.loadSettings();

    expect(settings.defaultPackageWeight, 2.0);
    expect(settings.defaultPackageNumber, 0);
    expect(settings.showPackageWeight, isTrue);
    expect(settings.showPackageNumber, isTrue);
  });

  test('defaults and visibility preferences persist across reloads', () async {
    final settings = InvoiceSettingsProvider();
    await settings.loadSettings();
    await settings.updateSettings(
      managerName: 'Ahmed',
      defaultPackageWeight: 4.5,
      defaultPackageNumber: 3,
      showPackageWeight: false,
      showPackageNumber: true,
    );

    final reloaded = InvoiceSettingsProvider();
    await reloaded.loadSettings();

    expect(reloaded.managerName, 'Ahmed');
    expect(reloaded.defaultPackageWeight, 4.5);
    expect(reloaded.defaultPackageNumber, 3);
    expect(reloaded.showPackageWeight, isFalse);
    expect(reloaded.showPackageNumber, isTrue);
  });

  test('negative defaults are rejected', () async {
    final settings = InvoiceSettingsProvider();
    await settings.loadSettings();

    expect(
      () => settings.updateSettings(defaultPackageWeight: -1),
      throwsArgumentError,
    );
    expect(
      () => settings.updateSettings(defaultPackageNumber: -2),
      throwsArgumentError,
    );
  });

  test('settings round trip through an invoice backup', () async {
    final source = InvoiceSettingsProvider();
    await source.loadSettings();
    await source.updateSettings(
      companyName: 'Arqamy',
      qrData: 'https://example.com',
      defaultPackageWeight: 2.75,
      defaultPackageNumber: 6,
      showPackageWeight: false,
      showPackageNumber: false,
    );
    final backup = InvoiceBackup.encode(
      const [],
      exportedAt: DateTime.utc(2026, 11, 26),
      settings: source.snapshot(),
    );

    final restored = InvoiceBackup.decodeSettings(backup);

    expect(InvoiceBackup.containsSettings(backup), isTrue);
    expect(restored, source.snapshot());
    expect(restored?.defaultPackageWeight, 2.75);
    expect(restored?.showPackageNumber, isFalse);
  });

  test('legacy backups without settings still decode', () {
    final backup = InvoiceBackup.encode(
      const [],
      exportedAt: DateTime.utc(2026, 11, 26),
    );

    expect(InvoiceBackup.containsSettings(backup), isFalse);
    expect(InvoiceBackup.decodeSettings(backup), isNull);
    expect(InvoiceBackup.decode(backup), isEmpty);
  });

  test('restore applies backup settings and reset restores defaults', () async {
    final source = InvoiceSettingsProvider();
    await source.loadSettings();
    await source.updateSettings(
      managerName: 'Source',
      defaultPackageWeight: 8,
      defaultPackageNumber: 9,
      showPackageWeight: false,
    );
    final backup = InvoiceBackup.encode(
      const [],
      exportedAt: DateTime.utc(2026, 11, 26),
      settings: source.snapshot(),
    );

    final target = InvoiceSettingsProvider();
    await target.loadSettings();
    expect(await target.restoreFromBackup(backup), isTrue);
    expect(target.snapshot(), source.snapshot());

    await target.resetToDefaults();
    expect(target.snapshot(), InvoiceSettingsSnapshot.defaults());
  });
}
