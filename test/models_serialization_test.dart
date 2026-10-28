import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_pro/features/business/models/business_model.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';
import 'package:tailor_pro/features/measurements/models/measurement_model.dart';
import 'package:tailor_pro/features/orders/models/order_model.dart';

void main() {
  group('Models Serialization and Integrity Tests', () {
    test('BusinessModel toMap and fromMap serialization', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final biz = BusinessModel(
        id: 'biz_001',
        name: 'Royal Master Tailors',
        ownerName: 'Ustad Tariq',
        phonePrimary: '03001234567',
        phoneSecondary: '03219876543',
        address: 'Anarkali Bazaar Lahore',
        currencySymbol: 'Rs.',
        serialStartNumber: 1001,
        currentSerialNumber: 1001,
        invoiceFooterText: 'Quality Tailoring Guaranteed',
        createdAt: now,
        updatedAt: now,
      );

      final map = biz.toMap();
      expect(map['id'], 'biz_001');
      expect(map['name'], 'Royal Master Tailors');
      expect(map['serial_start_number'], 1001);

      final restored = BusinessModel.fromMap(map);
      expect(restored.id, biz.id);
      expect(restored.name, biz.name);
      expect(restored.phoneSecondary, '03219876543');
      expect(restored.serialStartNumber, 1001);
    });

    test('CustomerModel serializes with active balance and custom tags', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final customer = CustomerModel(
        id: 'cust_001',
        businessId: 'biz_001',
        serialNo: 1001,
        name: 'Chaudhry Akram',
        phone: '03017654321',
        currentBalance: -2500.0, // customer owes tailor 2500
        createdAt: now,
        updatedAt: now,
      );

      final map = customer.toMap();
      expect(map['id'], 'cust_001');
      expect(map['serial_no'], 1001);
      expect(map['current_balance'], -2500.0);

      final restored = CustomerModel.fromMap(map);
      expect(restored.name, 'Chaudhry Akram');
      expect(restored.currentBalance, -2500.0);
      expect(restored.deletedAt, isNull);
    });

    test('MeasurementModel encodes and decodes JSON values correctly', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final values = {
        'length': 40.5,
        'chest': 38.25,
        'waist': 34.0,
        'collar': 16.5,
      };
      final styles = {
        'collar_style': 'بین (Sherwani Collar)',
        'cuff_style': 'ڈبل کف (Double Cuff)',
        'daman_style': 'گول گھیرا (Round)',
      };

      final measurement = MeasurementModel(
        id: 'meas_001',
        customerId: 'cust_001',
        businessId: 'biz_001',
        garmentTemplateId: 'kameez_shalwar',
        measurements: values,
        styleOptions: styles,
        unit: 'inch',
        extraDetailsText: 'کھلا دامن رکھنا ہے',
        createdAt: now,
      );

      final map = measurement.toMap();
      expect(map['garment_template_id'], 'kameez_shalwar');
      expect(map['unit'], 'inch');
      expect(map['measurements_json'], isA<String>());

      final restored = MeasurementModel.fromMap(map);
      expect(restored.garmentTemplateId, 'kameez_shalwar');
      expect(restored.measurements['length'], 40.5);
      expect(restored.measurements['collar'], 16.5);
      expect(restored.styleOptions['collar_style'], 'بین (Sherwani Collar)');
      expect(restored.extraDetailsText, 'کھلا دامن رکھنا ہے');
    });

    test('OrderModel status progression and totals', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final order = OrderModel(
        id: 'ord_001',
        businessId: 'biz_001',
        customerId: 'cust_001',
        measurementId: 'meas_001',
        orderNumber: 'ORD-2026-0001',
        garmentType: 'شلوار قمیض',
        quantity: 2,
        fabricSource: 'customer_cloth',
        fabricNotes: 'Boski White',
        status: 'cutting',
        totalStitchingCharges: 3000.0,
        totalFabricCharges: 0.0,
        otherCharges: 200.0,
        urgentSurcharge: 500.0,
        discountAmount: 200.0,
        grandTotal: 3500.0,
        advancePaid: 1500.0,
        balanceDue: 2000.0,
        isUrgent: true,
        orderDate: now,
        deliveryDate: now + 86400000 * 5,
        createdAt: now,
        updatedAt: now,
      );

      final map = order.toMap();
      expect(map['order_number'], 'ORD-2026-0001');
      expect(map['quantity'], 2);
      expect(map['status'], 'cutting');

      final restored = OrderModel.fromMap(map);
      expect(restored.orderNumber, 'ORD-2026-0001');
      expect(restored.grandTotal, 3500.0);
      expect(restored.balanceDue, 2000.0);
      expect(restored.isUrgent, true);
    });
  });
}

