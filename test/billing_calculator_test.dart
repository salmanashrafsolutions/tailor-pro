import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_pro/core/utils/billing_engine.dart';

void main() {
  group('Billing Calculation Engine Tests', () {
    test('calculates basic stitching charges for single suit', () {
      final total = BillingEngine.computeGrandTotal(
        stitchingPerSuit: 1500,
        quantity: 1,
      );
      expect(total, 1500.0);
    });

    test('calculates multiple suits correctly', () {
      final total = BillingEngine.computeGrandTotal(
        stitchingPerSuit: 1500,
        quantity: 3,
      );
      expect(total, 4500.0);
    });

    test('adds fabric charges and urgent surcharge', () {
      final total = BillingEngine.computeGrandTotal(
        stitchingPerSuit: 1500,
        quantity: 2, // 3000
        fabricCharges: 2500, // + 2500 = 5500
        isUrgent: true,
        urgentSurcharge: 500, // + 500 = 6000
      );
      expect(total, 6000.0);
    });

    test('deducts discount correctly', () {
      final total = BillingEngine.computeGrandTotal(
        stitchingPerSuit: 2000,
        quantity: 1,
        fabricCharges: 1000,
        discountAmount: 300,
      );
      expect(total, 2700.0);
    });

    test('calculates balance due with advance payment', () {
      final balance = BillingEngine.computeBalanceDue(
        grandTotal: 5000,
        advancePaid: 2000,
      );
      expect(balance, 3000.0);
    });

    test('zero balance due on full payment', () {
      final balance = BillingEngine.computeBalanceDue(
        grandTotal: 3500,
        advancePaid: 3500,
      );
      expect(balance, 0.0);
    });

    test('negative balance represents advance deposit', () {
      final balance = BillingEngine.computeBalanceDue(
        grandTotal: 2000,
        advancePaid: 2500,
      );
      expect(balance, -500.0);
    });
  });
}
