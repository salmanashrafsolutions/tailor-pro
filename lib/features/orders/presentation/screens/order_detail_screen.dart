import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/billing/presentation/screens/print_preview_screen.dart';
import 'package:tailor_pro/features/orders/models/order_model.dart';
import 'package:tailor_pro/features/orders/providers/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _cutterNameController = TextEditingController(text: 'استاد بشیر (کٹنگ)');
  final _tailorNameController = TextEditingController(text: 'محمد طارق (سلائی)');
  final _cutterWageController = TextEditingController();
  final _tailorWageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cutterWageController.text = widget.order.cutterWage > 0 ? widget.order.cutterWage.toStringAsFixed(0) : '250';
    _tailorWageController.text = widget.order.tailorWage > 0 ? widget.order.tailorWage.toStringAsFixed(0) : '750';
  }

  @override
  void dispose() {
    _cutterNameController.dispose();
    _tailorNameController.dispose();
    _cutterWageController.dispose();
    _tailorWageController.dispose();
    super.dispose();
  }

  void _advanceStatus(String nextStatus) async {
    await ref.read(orderProvider.notifier).updateOrderStatus(widget.order.id, nextStatus);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('آرڈر کا اسٹیٹس اپڈیٹ ہو گیا: $nextStatus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final localeState = ref.watch(localeProvider);
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    final orderDateStr = DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(o.orderDate));
    final deliveryDateStr = DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(o.deliveryDate));
    final trialDateStr = o.trialDate != null
        ? DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(o.trialDate!))
        : 'مقرر نہیں';

    final stages = [
      {'key': 'received', 'label': 'وصول شدہ'},
      {'key': 'cutting', 'label': 'کٹنگ'},
      {'key': 'stitching', 'label': 'سلائی'},
      {'key': 'finishing', 'label': 'فنشنگ'},
      {'key': 'ready', 'label': 'تیار'},
      {'key': 'delivered', 'label': 'حوالے شدہ'},
    ];

    final currentStageIdx = stages.indexWhere((s) => s['key'] == o.status);

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${o.orderNumber} - تفصیلات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'رسید اور ٹوکن پرنٹ کریں',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PrintPreviewScreen(order: o)),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pipeline Stage Progress Tracker
              Card(
                color: const Color(0xFFF8FAFC),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Column(
                    children: [
                      const Text(
                        'آرڈر ورک فلو پائپ لائن',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: stages.map((s) {
                          final idx = stages.indexOf(s);
                          final isPassed = idx <= currentStageIdx;
                          final isCurrent = idx == currentStageIdx;

                          return Column(
                            children: [
                              CircleAvatar(
                                radius: isCurrent ? 16 : 12,
                                backgroundColor: isPassed ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                child: Icon(
                                  isPassed ? Icons.check : Icons.circle,
                                  size: isCurrent ? 16 : 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s['label']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isPassed ? const Color(0xFF1E3A8A) : Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Customer & Dates Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(o.customerName ?? 'نامعلوم گاہک', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(o.customerPhone ?? '', style: const TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ملبوسات: ${o.quantity} سوٹ (${o.garmentType})'),
                          if (o.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('ارجنٹ آرڈر', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('کپڑا: ${o.fabricSource == 'customer_cloth' ? 'گاہک کا اپنا' : 'دکان کا'} • ${o.fabricNotes ?? 'کوئی خاص نوٹ نہیں'}'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('بکنگ: $orderDateStr', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                          Text('ٹرائل: $trialDateStr', style: const TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                          Text('ڈلیوری: $deliveryDateStr', style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Staff Assignment & Piece-Rate Wages
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('کاریگر کی اجرت و تفویض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A))),
                          Icon(Icons.badge, size: 20, color: Color(0xFF1E3A8A)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _cutterNameController,
                              decoration: const InputDecoration(labelText: 'کٹنگ ماسٹر', prefixIcon: Icon(Icons.cut)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _cutterWageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'اجرت', prefixText: 'Rs. '),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _tailorNameController,
                              decoration: const InputDecoration(labelText: 'سلائی درزی', prefixIcon: Icon(Icons.person)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _tailorWageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'اجرت', prefixText: 'Rs. '),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Billing Breakdown
              Card(
                color: const Color(0xFFF1F5F9),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('سلائی چارجز:'),
                          Text('$currency ${numFormat(o.totalStitchingCharges.toStringAsFixed(0))}'),
                        ],
                      ),
                      if (o.isUrgent) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ارجنٹ سرچارج:'),
                            Text('$currency ${numFormat(o.urgentSurcharge.toStringAsFixed(0))}'),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('کل رقم (Grand Total):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            '$currency ${numFormat(o.grandTotal.toStringAsFixed(0))}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('پیشگی وصول (Advance):', style: TextStyle(color: Color(0xFF059669))),
                          Text('$currency ${numFormat(o.advancePaid.toStringAsFixed(0))}', style: const TextStyle(color: Color(0xFF059669))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('بقایا واجب الادا (Balance):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          Text(
                            '$currency ${numFormat(o.balanceDue.toStringAsFixed(0))}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('رسید اور ٹوکن'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PrintPreviewScreen(order: o)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        currentStageIdx < stages.length - 1
                            ? '${stages[currentStageIdx + 1]['label']!} کریں'
                            : 'مکمل',
                      ),
                      onPressed: currentStageIdx < stages.length - 1
                          ? () => _advanceStatus(stages[currentStageIdx + 1]['key']!)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

