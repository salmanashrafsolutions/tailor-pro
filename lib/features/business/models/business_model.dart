class BusinessModel {
  final String id;
  final String name;
  final String? tagline;
  final String? logoPath;
  final String ownerName;
  final String phonePrimary;
  final String? phoneSecondary;
  final String? address;
  final String currencySymbol;
  final String? ntnTaxId;
  final String? invoiceFooterText;
  final String? pinHash;
  final bool isBiometricEnabled;
  final String serialPrefix;
  final int serialStartNumber;
  final int currentSerialNumber;
  final String defaultUnit; // 'inch' or 'cm'
  final int createdAt;
  final int updatedAt;

  BusinessModel({
    required this.id,
    required this.name,
    this.tagline,
    this.logoPath,
    required this.ownerName,
    required this.phonePrimary,
    this.phoneSecondary,
    this.address,
    this.currencySymbol = 'Rs.',
    this.ntnTaxId,
    this.invoiceFooterText,
    this.pinHash,
    this.isBiometricEnabled = false,
    this.serialPrefix = '',
    this.serialStartNumber = 1,
    this.currentSerialNumber = 1,
    this.defaultUnit = 'inch',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'logo_path': logoPath,
      'owner_name': ownerName,
      'phone_primary': phonePrimary,
      'phone_secondary': phoneSecondary,
      'address': address,
      'currency_symbol': currencySymbol,
      'ntn_tax_id': ntnTaxId,
      'invoice_footer_text': invoiceFooterText,
      'pin_hash': pinHash,
      'is_biometric_enabled': isBiometricEnabled ? 1 : 0,
      'serial_prefix': serialPrefix,
      'serial_start_number': serialStartNumber,
      'current_serial_number': currentSerialNumber,
      'default_unit': defaultUnit,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': 0,
    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      id: map['id'],
      name: map['name'],
      tagline: map['tagline'],
      logoPath: map['logo_path'],
      ownerName: map['owner_name'],
      phonePrimary: map['phone_primary'],
      phoneSecondary: map['phone_secondary'],
      address: map['address'],
      currencySymbol: map['currency_symbol'] ?? 'Rs.',
      ntnTaxId: map['ntn_tax_id'],
      invoiceFooterText: map['invoice_footer_text'],
      pinHash: map['pin_hash'],
      isBiometricEnabled: map['is_biometric_enabled'] == 1,
      serialPrefix: map['serial_prefix'] ?? '',
      serialStartNumber: map['serial_start_number'] ?? 1,
      currentSerialNumber: map['current_serial_number'] ?? 1,
      defaultUnit: map['default_unit'] ?? 'inch',
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

