import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';

class CustomerState {
  final List<CustomerModel> customers;
  final bool isLoading;
  final String searchQuery;
  final bool duesOnlyFilter;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.duesOnlyFilter = false,
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    String? searchQuery,
    bool? duesOnlyFilter,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      duesOnlyFilter: duesOnlyFilter ?? this.duesOnlyFilter,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final Ref ref;
  CustomerNotifier(this.ref) : super(const CustomerState()) {
    loadCustomers();
  }

  final _uuid = const Uuid();

  Future<void> loadCustomers({String query = '', bool duesOnly = false}) async {
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    state = state.copyWith(isLoading: true, searchQuery: query, duesOnlyFilter: duesOnly);
    final db = await AppDatabase.instance.database;

    String sql = 'SELECT * FROM customers WHERE business_id = ? AND deleted_at IS NULL';
    List<dynamic> args = [activeBiz.id];

    if (query.trim().isNotEmpty) {
      sql += ' AND (name LIKE ? OR phone LIKE ? OR serial_no LIKE ?)';
      final q = '%${query.trim()}%';
      args.addAll([q, q, q]);
    }

    if (duesOnly) {
      sql += ' AND current_balance < 0';
    }

    sql += ' ORDER BY serial_no DESC LIMIT 200';

    final List<Map<String, dynamic>> results = await db.rawQuery(sql, args);
    final list = results.map((m) => CustomerModel.fromMap(m)).toList();

    state = state.copyWith(customers: list, isLoading: false);
  }

  Future<CustomerModel> createCustomer({
    required int serialNo,
    required String name,
    required String phone,
    String? secondaryPhone,
    String? address,
    String? notes,
  }) async {
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) throw Exception('No active business');

    final now = DateTime.now().millisecondsSinceEpoch;
    final customer = CustomerModel(
      id: _uuid.v4(),
      businessId: activeBiz.id,
      serialNo: serialNo,
      name: name,
      phone: phone,
      secondaryPhone: secondaryPhone,
      address: address,
      notes: notes,
      currentBalance: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    final db = await AppDatabase.instance.database;
    await db.insert('customers', customer.toMap());
    await loadCustomers(query: state.searchQuery, duesOnly: state.duesOnlyFilter);
    return customer;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'customers',
      customer.toMap()..['updated_at'] = DateTime.now().millisecondsSinceEpoch,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    await loadCustomers(query: state.searchQuery, duesOnly: state.duesOnlyFilter);
  }

  Future<void> softDeleteCustomer(String customerId) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'customers',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: [customerId],
    );
    await loadCustomers(query: state.searchQuery, duesOnly: state.duesOnlyFilter);
  }

  Future<void> restoreCustomer(String customerId) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'customers',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [customerId],
    );
    await loadCustomers(query: state.searchQuery, duesOnly: state.duesOnlyFilter);
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  return CustomerNotifier(ref);
});

