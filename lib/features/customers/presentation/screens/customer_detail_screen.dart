import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/measurements/presentation/screens/measurement_input_screen.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_create_screen.dart';
import 'package:tailor_pro/features/billing/presentation/screens/customer_ledger_screen.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_edit_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteCustomer() {
    final lang = ref.read(localeProvider).locale.languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('گاہک کو حذف کریں؟'),
        content: const Text('یہ گاہک ری سائیکل بن میں چلا جائے گا اور 30 دن تک واپس لایا جا سکتا ہے۔'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(customerProvider.notifier).softDeleteCustomer(widget.customer.id);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('گاہک ری سائیکل بن میں منتقل ہو گیا'),
                    action: SnackBarAction(
                      label: AppStrings.get('undo', lang),
                      onPressed: () {
                        ref.read(customerProvider.notifier).restoreCustomer(widget.customer.id);
                      },
                    ),
                  ),
                );
              }
            },
            child: Text(AppStrings.get('delete', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';
    final c = widget.customer;
    final hasDues = c.currentBalance < 0;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: AppStrings.get('edit', lang),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CustomerEditScreen(customer: c)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: AppStrings.get('delete', lang),
              onPressed: _deleteCustomer,
            ),
          ],
        ),
        body: Column(
          children: [
            // Customer Header Card
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        child: Text(
                          numFormat(c.serialNo),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.phone,
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                            ),
                            if (c.address != null && c.address!.isNotEmpty)
                              Text(
                                c.address!,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // Balance Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasDues ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasDues ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              hasDues ? 'بقایا واجب الادا' : 'کلئیر / پیشگی',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: hasDues ? const Color(0xFFDC2626) : const Color(0xFF059669),
                              ),
                            ),
                            Text(
                              '$currency ${numFormat(c.currentBalance.abs().toStringAsFixed(0))}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: hasDues ? const Color(0xFFDC2626) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Chips
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone, size: 18),
                          label: Text(AppStrings.get('call_customer', lang)),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                          icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                          label: const Text('واٹس ایپ', style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar: Measurements, Orders, Ledger
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1E3A8A),
              indicatorColor: const Color(0xFF1E3A8A),
              tabs: const [
                Tab(icon: Icon(Icons.straighten), text: 'ناپ رجسٹر'),
                Tab(icon: Icon(Icons.shopping_bag), text: 'آرڈرز'),
                Tab(icon: Icon(Icons.receipt_long), text: 'کھاتہ رجسٹر'),
              ],
            ),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Measurements
                  _buildMeasurementsTab(context, lang),
                  // Tab 2: Orders
                  _buildOrdersTab(context, lang),
                  // Tab 3: Khata Ledger
                  CustomerLedgerScreen(customerId: c.id, customerName: c.name),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.straighten),
                  label: Text(AppStrings.get('take_new_measurement', lang)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MeasurementInputScreen(customer: c),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(AppStrings.get('new_order', lang)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderCreateScreen(selectedCustomer: c),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementsTab(BuildContext context, String lang) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'شلوار قمیض (تازہ ترین ناپ)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('انچ (Inches)', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('تاریخ اندراج: 27 اکتوبر 2026', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),

                // Measurement Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMeasureChip('لمبائی قمیض', '40½'),
                    _buildMeasureChip('چھاتی', '38¼'),
                    _buildMeasureChip('کمر', '36'),
                    _buildMeasureChip('تیرا', '17½'),
                    _buildMeasureChip('بازو', '23¾'),
                    _buildMeasureChip('گلا / بین', '15½'),
                    _buildMeasureChip('دامن', '22'),
                    _buildMeasureChip('لمبائی شلوار', '38'),
                    _buildMeasureChip('پائنچہ', '8½'),
                  ],
                ),
                const Divider(height: 20),

                // Selected Styles
                const Text('سلائی کا ڈیزائن و اسٹائل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Chip(label: Text('مکمل بین (فل بین)', style: TextStyle(fontSize: 12))),
                    Chip(label: Text('گم پٹی', style: TextStyle(fontSize: 12))),
                    Chip(label: Text('سنگل کف', style: TextStyle(fontSize: 12))),
                    Chip(label: Text('1 سامنے جیب', style: TextStyle(fontSize: 12))),
                    Chip(label: Text('1 سائیڈ جیب', style: TextStyle(fontSize: 12))),
                    Chip(label: Text('چورس دامن', style: TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 12),

                // Copy / Edit Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('ناپ کاپی کریں'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ناپ کامیابی سے کاپی ہو گئی')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        minimumSize: const Size(100, 36),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('ترمیم'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MeasurementInputScreen(customer: widget.customer),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureChip(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context, String lang) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF2563EB),
              child: Icon(Icons.cut, color: Colors.white),
            ),
            title: Text('آرڈر # ORD-2026-0001 (2 سوٹ)'),
            subtitle: Text('اسٹیٹس: کٹنگ (Cutting) • ڈلیوری: 30 اکتوبر'),
            trailing: Chip(
              label: Text('کٹنگ جاری'),
              backgroundColor: Color(0xFFEFF6FF),
            ),
          ),
        ),
      ],
    );
  }
}

