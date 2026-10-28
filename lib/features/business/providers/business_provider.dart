import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/models/business_model.dart';

class BusinessState {
  final List<BusinessModel> businesses;
  final BusinessModel? activeBusiness;
  final bool isLoading;

  const BusinessState({
    this.businesses = const [],
    this.activeBusiness,
    this.isLoading = true,
  });

  BusinessState copyWith({
    List<BusinessModel>? businesses,
    BusinessModel? activeBusiness,
    bool? isLoading,
  }) {
    return BusinessState(
      businesses: businesses ?? this.businesses,
      activeBusiness: activeBusiness ?? this.activeBusiness,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  BusinessNotifier() : super(const BusinessState()) {
    loadBusinesses();
  }

  final _uuid = const Uuid();

  Future<void> loadBusinesses() async {
    state = state.copyWith(isLoading: true);
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'businesses',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );

    final list = maps.map((m) => BusinessModel.fromMap(m)).toList();
    BusinessModel? active;
    if (list.isNotEmpty) {
      active = state.activeBusiness != null && list.any((b) => b.id == state.activeBusiness!.id)
          ? list.firstWhere((b) => b.id == state.activeBusiness!.id)
          : list.first;
    }

    state = state.copyWith(
      businesses: list,
      activeBusiness: active,
      isLoading: false,
    );
  }

  Future<BusinessModel> createBusiness({
    required String name,
    String? tagline,
    required String ownerName,
    required String phonePrimary,
    String? phoneSecondary,
    String? address,
    String currencySymbol = 'Rs.',
    String? ntnTaxId,
    String? invoiceFooterText,
    String? pinHash,
    int serialStartNumber = 1,
    String defaultUnit = 'inch',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newBiz = BusinessModel(
      id: _uuid.v4(),
      name: name,
      tagline: tagline,
      ownerName: ownerName,
      phonePrimary: phonePrimary,
      phoneSecondary: phoneSecondary,
      address: address,
      currencySymbol: currencySymbol,
      ntnTaxId: ntnTaxId,
      invoiceFooterText: invoiceFooterText,
      pinHash: pinHash,
      serialStartNumber: serialStartNumber,
      currentSerialNumber: serialStartNumber,
      defaultUnit: defaultUnit,
      createdAt: now,
      updatedAt: now,
    );

    final db = await AppDatabase.instance.database;
    await db.insert('businesses', newBiz.toMap());
    await AppDatabase.instance.seedDefaultBusinessData(newBiz.id);

    await loadBusinesses();
    state = state.copyWith(activeBusiness: newBiz);
    return newBiz;
  }

  void setActiveBusiness(BusinessModel biz) {
    state = state.copyWith(activeBusiness: biz);
  }

  Future<int> getNextSerialAndIncrement() async {
    if (state.activeBusiness == null) return 1;
    final biz = state.activeBusiness!;
    final nextSerial = biz.currentSerialNumber;
    final updatedSerial = nextSerial + 1;

    final db = await AppDatabase.instance.database;
    await db.update(
      'businesses',
      {'current_serial_number': updatedSerial, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [biz.id],
    );

    await loadBusinesses();
    return nextSerial;
  }
}

final businessProvider = StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  return BusinessNotifier();
});

