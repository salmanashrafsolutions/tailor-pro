class OrderModel {
  final String id;
  final String businessId;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String orderNumber;
  final String measurementId;
  final String garmentType;
  final int quantity;
  final String fabricSource; // 'customer_cloth' or 'shop_cloth'
  final String? fabricNotes;
  final String? fabricPhotoPath;
  final String? designPhotoPath;
  final bool isUrgent;
  final double urgentSurcharge;
  final double totalStitchingCharges;
  final double totalFabricCharges;
  final double otherCharges;
  final double discountAmount;
  final double grandTotal;
  final double advancePaid;
  final double balanceDue;
  final String status; // 'received', 'cutting', 'stitching', 'finishing', 'ready', 'delivered', 'cancelled'
  final String? assignedCutterId;
  final String? assignedTailorId;
  final double cutterWage;
  final double tailorWage;
  final int orderDate;
  final int? trialDate;
  final int deliveryDate;
  final int? deliveredAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  OrderModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.orderNumber,
    required this.measurementId,
    required this.garmentType,
    this.quantity = 1,
    this.fabricSource = 'customer_cloth',
    this.fabricNotes,
    this.fabricPhotoPath,
    this.designPhotoPath,
    this.isUrgent = false,
    this.urgentSurcharge = 0.0,
    required this.totalStitchingCharges,
    this.totalFabricCharges = 0.0,
    this.otherCharges = 0.0,
    this.discountAmount = 0.0,
    required this.grandTotal,
    this.advancePaid = 0.0,
    required this.balanceDue,
    this.status = 'received',
    this.assignedCutterId,
    this.assignedTailorId,
    this.cutterWage = 0.0,
    this.tailorWage = 0.0,
    required this.orderDate,
    this.trialDate,
    required this.deliveryDate,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'order_number': orderNumber,
      'measurement_id': measurementId,
      'garment_type': garmentType,
      'quantity': quantity,
      'fabric_source': fabricSource,
      'fabric_notes': fabricNotes,
      'fabric_photo_path': fabricPhotoPath,
      'design_photo_path': designPhotoPath,
      'is_urgent': isUrgent ? 1 : 0,
      'urgent_surcharge': urgentSurcharge,
      'total_stitching_charges': totalStitchingCharges,
      'total_fabric_charges': totalFabricCharges,
      'other_charges': otherCharges,
      'discount_amount': discountAmount,
      'grand_total': grandTotal,
      'advance_paid': advancePaid,
      'balance_due': balanceDue,
      'status': status,
      'assigned_cutter_id': assignedCutterId,
      'assigned_tailor_id': assignedTailorId,
      'cutter_wage': cutterWage,
      'tailor_wage': tailorWage,
      'order_date': orderDate,
      'trial_date': trialDate,
      'delivery_date': deliveryDate,
      'delivered_at': deliveredAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      businessId: map['business_id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      orderNumber: map['order_number'],
      measurementId: map['measurement_id'],
      garmentType: map['garment_type'],
      quantity: map['quantity'] ?? 1,
      fabricSource: map['fabric_source'] ?? 'customer_cloth',
      fabricNotes: map['fabric_notes'],
      fabricPhotoPath: map['fabric_photo_path'],
      designPhotoPath: map['design_photo_path'],
      isUrgent: map['is_urgent'] == 1,
      urgentSurcharge: (map['urgent_surcharge'] as num?)?.toDouble() ?? 0.0,
      totalStitchingCharges: (map['total_stitching_charges'] as num?)?.toDouble() ?? 0.0,
      totalFabricCharges: (map['total_fabric_charges'] as num?)?.toDouble() ?? 0.0,
      otherCharges: (map['other_charges'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0.0,
      advancePaid: (map['advance_paid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (map['balance_due'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'received',
      assignedCutterId: map['assigned_cutter_id'],
      assignedTailorId: map['assigned_tailor_id'],
      cutterWage: (map['cutter_wage'] as num?)?.toDouble() ?? 0.0,
      tailorWage: (map['tailor_wage'] as num?)?.toDouble() ?? 0.0,
      orderDate: map['order_date'],
      trialDate: map['trial_date'],
      deliveryDate: map['delivery_date'],
      deliveredAt: map['delivered_at'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      deletedAt: map['deleted_at'],
    );
  }
}

