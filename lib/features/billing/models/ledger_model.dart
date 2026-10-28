class LedgerEntryModel {
  final String id;
  final String businessId;
  final String customerId;
  final String? orderId;
  final String? paymentId;
  final String entryType; // 'debit' (charge) or 'credit' (payment received)
  final double amount;
  final double balanceAfter;
  final String? description;
  final int createdAt;

  LedgerEntryModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.orderId,
    this.paymentId,
    required this.entryType,
    required this.amount,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'order_id': orderId,
      'payment_id': paymentId,
      'entry_type': entryType,
      'amount': amount,
      'balance_after': balanceAfter,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory LedgerEntryModel.fromMap(Map<String, dynamic> map) {
    return LedgerEntryModel(
      id: map['id'],
      businessId: map['business_id'],
      customerId: map['customer_id'],
      orderId: map['order_id'],
      paymentId: map['payment_id'],
      entryType: map['entry_type'],
      amount: (map['amount'] as num).toDouble(),
      balanceAfter: (map['balance_after'] as num).toDouble(),
      description: map['description'],
      createdAt: map['created_at'],
    );
  }
}

