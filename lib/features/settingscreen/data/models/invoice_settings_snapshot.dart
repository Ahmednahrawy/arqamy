/// The invoice settings and order defaults that travel in a backup file.
class InvoiceSettingsSnapshot {
  const InvoiceSettingsSnapshot({
    required this.logoPath,
    required this.managerName,
    required this.managerPhone,
    required this.companyName,
    required this.companyDescription,
    required this.qrData,
    required this.defaultPackageWeight,
    required this.defaultPackageNumber,
    required this.showPackageWeight,
    required this.showPackageNumber,
  });

  factory InvoiceSettingsSnapshot.defaults() => const InvoiceSettingsSnapshot(
    logoPath: 'assets/images/arqamy.png',
    managerName: '',
    managerPhone: '',
    companyName: '',
    companyDescription: '',
    qrData: '',
    defaultPackageWeight: 2,
    defaultPackageNumber: 0,
    showPackageWeight: true,
    showPackageNumber: true,
  );

  final String logoPath;
  final String managerName;
  final String managerPhone;
  final String companyName;
  final String companyDescription;
  final String qrData;
  final double defaultPackageWeight;
  final int defaultPackageNumber;
  final bool showPackageWeight;
  final bool showPackageNumber;

  Map<String, Object?> toJson() => {
    'logoPath': logoPath,
    'managerName': managerName,
    'managerPhone': managerPhone,
    'companyName': companyName,
    'companyDescription': companyDescription,
    'qrData': qrData,
    'defaultPackageWeight': defaultPackageWeight,
    'defaultPackageNumber': defaultPackageNumber,
    'showPackageWeight': showPackageWeight,
    'showPackageNumber': showPackageNumber,
  };

  /// Parses a settings object from a backup.
  ///
  /// Throws [FormatException] so the backup reader can reject the whole file.
  static InvoiceSettingsSnapshot fromJson(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('settings is not an object');
    }
    final map = Map<String, dynamic>.from(raw);
    final logoPath = _text(map, 'logoPath');
    if (logoPath.trim().isEmpty) {
      throw const FormatException('logoPath is empty');
    }
    return InvoiceSettingsSnapshot(
      logoPath: logoPath,
      managerName: _text(map, 'managerName'),
      managerPhone: _text(map, 'managerPhone'),
      companyName: _text(map, 'companyName'),
      companyDescription: _text(map, 'companyDescription'),
      qrData: _text(map, 'qrData'),
      defaultPackageWeight: _nonNegativeDouble(
        map,
        'defaultPackageWeight',
      ),
      defaultPackageNumber: _nonNegativeInt(map, 'defaultPackageNumber'),
      showPackageWeight: _bool(map, 'showPackageWeight'),
      showPackageNumber: _bool(map, 'showPackageNumber'),
    );
  }

  static String _text(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw FormatException('$key is not text');
    }
    return value;
  }

  static double _nonNegativeDouble(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException('$key is not a non-negative number');
    }
    return value.toDouble();
  }

  static int _nonNegativeInt(Map<String, dynamic> map, String key) {
    final value = _nonNegativeDouble(map, key);
    if (value != value.truncateToDouble()) {
      throw FormatException('$key is not a whole number');
    }
    return value.toInt();
  }

  static bool _bool(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! bool) {
      throw FormatException('$key is not a boolean');
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      other is InvoiceSettingsSnapshot &&
      other.logoPath == logoPath &&
      other.managerName == managerName &&
      other.managerPhone == managerPhone &&
      other.companyName == companyName &&
      other.companyDescription == companyDescription &&
      other.qrData == qrData &&
      other.defaultPackageWeight == defaultPackageWeight &&
      other.defaultPackageNumber == defaultPackageNumber &&
      other.showPackageWeight == showPackageWeight &&
      other.showPackageNumber == showPackageNumber;

  @override
  int get hashCode => Object.hash(
    logoPath,
    managerName,
    managerPhone,
    companyName,
    companyDescription,
    qrData,
    defaultPackageWeight,
    defaultPackageNumber,
    showPackageWeight,
    showPackageNumber,
  );
}
