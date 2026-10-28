/// Centralized calculation engine for TailorPro billing and order finances.
class BillingEngine {
  /// Computes the final grand total given unit stitching, quantity, fabric, extras, urgency, and discount.
  static double computeGrandTotal({
    required double stitchingPerSuit,
    required int quantity,
    double fabricCharges = 0.0,
    double otherCharges = 0.0,
    bool isUrgent = false,
    double urgentSurcharge = 0.0,
    double discountAmount = 0.0,
  }) {
    final stitchingTotal = stitchingPerSuit * quantity;
    final urgentTotal = isUrgent ? urgentSurcharge : 0.0;
    final subtotal = stitchingTotal + fabricCharges + otherCharges + urgentTotal;
    return (subtotal - discountAmount).clamp(0.0, double.infinity);
  }

  /// Computes the remaining balance due after advance or partial payment.
  /// A positive value means customer owes tailor.
  /// A negative value represents an advance credit balance.
  static double computeBalanceDue({
    required double grandTotal,
    required double advancePaid,
  }) {
    return grandTotal - advancePaid;
  }
}
