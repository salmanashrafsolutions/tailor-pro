import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/orders/models/order_model.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String statusFilter; // 'all', 'received', 'cutting', 'stitching', 'finishing', 'ready', 'delivered'

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.statusFilter = 'all',
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? statusFilter,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;
  OrderNotifier(this.ref) : super(const OrderState()) {
    loadOrders();
  }

  final _uuid = const Uuid();

  Future<void> loadOrders({String? status}) async {
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    final targetStatus = status ?? state.statusFilter;
    state = state.copyWith(isLoading: true, statusFilter: targetStatus);
    final db = await AppDatabase.instance.database;

    String sql = '''
      SELECT o.*, c.name as customer_name, c.phone as customer_phone
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.business_id = ? AND o.deleted_at IS NULL
    ''';
    List<dynamic> args = [activeBiz.id];

    if (targetStatus != 'all') {
      sql += ' AND o.status = ?';
      args.add(targetStatus);
    }

    sql += ' ORDER BY o.delivery_date ASC';

    final List<Map<String, dynamic>> results = await db.rawQuery(sql, args);
    final list = results.map((m) => OrderModel.fromMap(m)).toList();

    state = state.copyWith(orders: list, isLoading: false);
  }

  Future<OrderModel> createOrder({
    required String customerId,
    required String measurementId,
    required String garmentType,
    int quantity = 1,
    String fabricSource = 'customer_cloth',
    String? fabricNotes,
    bool isUrgent = false,
    double urgentSurcharge = 0.0,
    required double totalStitchingCharges,
    double totalFabricCharges = 0.0,
    double otherCharges = 0.0,
    double discountAmount = 0.0,
    required double advancePaid,
    int? trialDate,
    required int deliveryDate,
  }) async {
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) throw Exception('No active business');

    final grandTotal = (totalStitchingCharges + totalFabricCharges + otherCharges + (isUrgent ? urgentSurcharge : 0.0)) - discountAmount;
    final balanceDue = grandTotal - advancePaid;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Generate Order Number
    final orderNum = 'ORD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final order = OrderModel(
      id: _uuid.v4(),
      businessId: activeBiz.id,
      customerId: customerId,
      orderNumber: orderNum,
      measurementId: measurementId,
      garmentType: garmentType,
      quantity: quantity,
      fabricSource: fabricSource,
      fabricNotes: fabricNotes,
      isUrgent: isUrgent,
      urgentSurcharge: urgentSurcharge,
      totalStitchingCharges: totalStitchingCharges,
      totalFabricCharges: totalFabricCharges,
      otherCharges: otherCharges,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      advancePaid: advancePaid,
      balanceDue: balanceDue,
      status: 'received',
      orderDate: now,
      trialDate: trialDate,
      deliveryDate: deliveryDate,
      createdAt: now,
      updatedAt: now,
    );

    final db = await AppDatabase.instance.database;
    await db.insert('orders', order.toMap());

    // Update Customer Khata balance: add remaining balance to dues
    if (balanceDue > 0) {
      await db.rawUpdate(
        'UPDATE customers SET current_balance = current_balance - ?, updated_at = ? WHERE id = ?',
        [balanceDue, now, customerId],
      );
    }

    await loadOrders();
    return order;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> updateMap = {
      'status': newStatus,
      'updated_at': now,
    };
    if (newStatus == 'delivered') {
      updateMap['delivered_at'] = now;
    }

    await db.update('orders', updateMap, where: 'id = ?', whereArgs: [orderId]);
    await loadOrders();
  }

  Future<void> assignStaffAndWages({
    required String orderId,
    String? cutterId,
    String? tailorId,
    double cutterWage = 0.0,
    double tailorWage = 0.0,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'orders',
      {
        'assigned_cutter_id': cutterId,
        'assigned_tailor_id': tailorId,
        'cutter_wage': cutterWage,
        'tailor_wage': tailorWage,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    await loadOrders();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});

