import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/orders/models/order_model.dart';

class PrintPreviewScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const PrintPreviewScreen({super.key, required this.order});

  @override
  ConsumerState<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends ConsumerState<PrintPreviewScreen> {
  String _selectedLayout = '80mm'; // '80mm', '58mm', 'a4', 'a5'
  bool _includeMeasurements = true;

  @override
  Widget build(BuildContext context) {
    final activeBiz = ref.watch(businessProvider).activeBusiness;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = activeBiz?.currencySymbol ?? 'Rs.';

    final order = widget.order;
    final orderDateStr = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(order.orderDate));
    final deliveryDateStr = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(order.deliveryDate));

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('print_receipt', lang)),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: AppStrings.get('share_whatsapp', lang),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رسید واٹس ایپ پر شیئر کی جا رہی ہے...')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Format Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  const Text('رسید کا سائز:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedLayout,
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: '80mm', child: Text('80 ملی میٹر (تھرمل)')),
                      DropdownMenuItem(value: '58mm', child: Text('58 ملی میٹر (پورٹیبل)')),
                      DropdownMenuItem(value: 'a4', child: Text('A4 مکمل صفحہ')),
                      DropdownMenuItem(value: 'a5', child: Text('A5 نصف صفحہ')),
                    ],
                    onChanged: (val) => setState(() => _selectedLayout = val ?? '80mm'),
                  ),
                  const Spacer(),
                  // Toggle measurements
                  Row(
                    children: [
                      Checkbox(
                        value: _includeMeasurements,
                        onChanged: (val) => setState(() => _includeMeasurements = val ?? true),
                      ),
                      const Text('ناپ شامل کریں', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Paper Preview Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: _selectedLayout == '58mm'
                        ? 280
                        : _selectedLayout == '80mm'
                            ? 360
                            : 450,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shop Header
                        Text(
                          activeBiz?.name ?? 'الکرم ٹیلرز',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        if (activeBiz?.tagline != null)
                          Text(activeBiz!.tagline!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('فون: ${activeBiz?.phonePrimary ?? '03001234567'}', style: const TextStyle(fontSize: 12)),
                        if (activeBiz?.address != null)
                          Text(activeBiz!.address!, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                        const Divider(thickness: 1.5, height: 20),

                        // Order & Customer Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('رسید #: ${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('تاریخ: $orderDateStr', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('گاہک: ${order.customerName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('ڈلیوری: $deliveryDateStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A))),
                          ],
                        ),
                        const Divider(thickness: 1, height: 16),

                        // Garment Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${order.quantity}x ${order.garmentType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('$currency ${numFormat(order.totalStitchingCharges.toStringAsFixed(0))}'),
                          ],
                        ),
                        if (order.isUrgent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ارجنٹ سرچارج', style: TextStyle(color: Color(0xFFDC2626))),
                              Text('$currency ${numFormat(order.urgentSurcharge.toStringAsFixed(0))}', style: const TextStyle(color: Color(0xFFDC2626))),
                            ],
                          ),
                        const Divider(thickness: 1, height: 16),

                        // Billing Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('کل میزان (Grand Total):', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$currency ${numFormat(order.grandTotal.toStringAsFixed(0))}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('پیشگی وصول (Advance):', style: TextStyle(color: Color(0xFF059669))),
                            Text('$currency ${numFormat(order.advancePaid.toStringAsFixed(0))}', style: const TextStyle(color: Color(0xFF059669))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('بقایا رقم (Balance Due):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                            Text(
                              '$currency ${numFormat(order.balanceDue.toStringAsFixed(0))}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 15),
                            ),
                          ],
                        ),

                        // Measurements Summary (If toggled on)
                        if (_includeMeasurements) ...[
                          const Divider(thickness: 1, height: 20),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('خلاصہ ناپ (Measurements):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'لمبائی: 40½ | چھاتی: 38¼ | تیرا: 17½ | بازو: 23¾ | گلا: 15½ | شلوار: 38 | پائنچہ: 8½',
                            style: TextStyle(fontSize: 11, color: Color(0xFF334155)),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        // Tear-off Customer Token Cutline
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Icon(Icons.content_cut, size: 14, color: Colors.grey),
                            Expanded(child: Divider(thickness: 1, indent: 8, endIndent: 8, color: Colors.grey)),
                            Text('یہاں سے کاٹ کر گاہک کو دیں', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Expanded(child: Divider(thickness: 1, indent: 8, endIndent: 8, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Customer Slip / Token Section
                        const Text(
                          'گاہک ٹوکن پرچی (Customer Slip)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                        ),
                        Text('آرڈر #: ${order.orderNumber} • ${order.quantity} سوٹ (${order.garmentType})', style: const TextStyle(fontSize: 11)),
                        Text('ڈلیوری تاریخ: $deliveryDateStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('بقایا رقم: $currency ${numFormat(order.balanceDue.toStringAsFixed(0))}', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),

                        const SizedBox(height: 10),
                        // QR Code
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: QrImageView(
                            data: '${order.orderNumber}|${order.customerName}|${order.balanceDue}',
                            version: QrVersions.auto,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Footer Message
                        Text(
                          activeBiz?.invoiceFooterText ?? 'سلائی کے نقائص کی صورت میں 3 دن کے اندر رجوع فرمائیں۔ بغیر رسید کے سوٹ نہیں ملے گا۔',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text(
              'پرنٹ بھیجیں (ESC/POS بلوٹوتھ یا سسٹم پرنٹر)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('پرنٹر پر کمانڈ بھیجی جا رہی ہے...')),
              );
            },
          ),
        ),
      ),
    );
  }
}

