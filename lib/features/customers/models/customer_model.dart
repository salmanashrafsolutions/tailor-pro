class CustomerModel {
  final String id;
  final String businessId;
  final int serialNo;
  final String name;
  final String phone;
  final String? secondaryPhone;
  final String? address;
  final String? photoPath;
  final String? notes;
  final double currentBalance; // positive = advance, negative = customer owes tailor
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  CustomerModel({
    required this.id,
    required this.businessId,
    required this.serialNo,
    required this.name,
    required this.phone,
    this.secondaryPhone,
    this.address,
    this.photoPath,
    this.notes,
    this.currentBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'serial_no': serialNo,
      'name': name,
      'phone': phone,
      'secondary_phone': secondaryPhone,
      'address': address,
      'photo_path': photoPath,
      'notes': notes,
      'current_balance': currentBalance,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      businessId: map['business_id'],
      serialNo: map['serial_no'],
      name: map['name'],
      phone: map['phone'],
      secondaryPhone: map['secondary_phone'],
      address: map['address'],
      photoPath: map['photo_path'],
      notes: map['notes'],
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      deletedAt: map['deleted_at'],
    );
  }
}

