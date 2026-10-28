class ExpenseModel {
  final String id;
  final String businessId;
  final String category; // 'rent', 'utilities', 'material', 'wages', 'refreshment', 'misc'
  final double amount;
  final String paymentMethod;
  final String? recipientName;
  final String? notes;
  final int createdAt;

  ExpenseModel({
    required this.id,
    required this.businessId,
    required this.category,
    required this.amount,
    this.paymentMethod = 'cash',
    this.recipientName,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'category': category,
      'amount': amount,
      'payment_method': paymentMethod,
      'recipient_name': recipientName,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      businessId: map['business_id'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] ?? 'cash',
      recipientName: map['recipient_name'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}

