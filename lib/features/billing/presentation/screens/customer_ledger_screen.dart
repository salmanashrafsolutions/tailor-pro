import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';
import 'package:tailor_pro/features/billing/models/ledger_model.dart';

class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerLedgerScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  ConsumerState<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends ConsumerState<CustomerLedgerScreen> {
  List<LedgerEntryModel> _entries = [];
  bool _isLoading = true;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() => _isLoading = true);
    final db = await AppDatabase.instance.database;

    final List<Map<String, dynamic>> rows = await db.query(
      'customer_ledger',
      where: 'customer_id = ?',
      whereArgs: [widget.customerId],
      orderBy: 'created_at DESC',
    );

    setState(() {
      _entries = rows.map((r) => LedgerEntryModel.fromMap(r)).toList();
      _isLoading = false;
    });
  }

  void _recordPaymentDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedMethod = 'cash'; // 'cash', 'jazzcash', 'easypaisa', 'bank'

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final lang = ref.watch(localeProvider).locale.languageCode;
          final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

          return AlertDialog(
            title: const Text('ادائیگی وصول کریں (کیش / جاز کیش)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'وصول شدہ رقم',
                      prefixText: '$currency ',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment Method Selector
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'ادائیگی کا ذریعہ',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('نقد (Cash)')),
                      DropdownMenuItem(value: 'jazzcash', child: Text('جاز کیش (JazzCash)')),
                      DropdownMenuItem(value: 'easypaisa', child: Text('ایزی پیسہ (Easypaisa)')),
                      DropdownMenuItem(value: 'bank', child: Text('بینک ٹرانسفر')),
                    ],
                    onChanged: (val) => setDialogState(() => selectedMethod = val ?? 'cash'),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'تفصیل / ٹرانزیکشن آئی ڈی (اختیاری)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountController.text) ?? 0.0;
                  if (amt <= 0) return;

                  final activeBiz = ref.read(businessProvider).activeBusiness;
                  if (activeBiz == null) return;

                  final db = await AppDatabase.instance.database;
                  final now = DateTime.now().millisecondsSinceEpoch;

                  // Update customer balance: adding payment makes balance less negative / positive
                  await db.rawUpdate(
                    'UPDATE customers SET current_balance = current_balance + ?, updated_at = ? WHERE id = ?',
                    [amt, now, widget.customerId],
                  );

                  // Insert Ledger Entry
                  final entry = LedgerEntryModel(
                    id: _uuid.v4(),
                    businessId: activeBiz.id,
                    customerId: widget.customerId,
                    entryType: 'credit',
                    amount: amt,
                    balanceAfter: 0.0,
                    description: 'ادائیگی بذریعہ $selectedMethod ${noteController.text.trim()}',
                    createdAt: now,
                  );
                  await db.insert('customer_ledger', entry.toMap());

                  // Refresh customer state
                  await ref.read(customerProvider.notifier).loadCustomers();

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (mounted) {
                    _loadLedger();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ادائیگی کامیابی سے درج ہو گئی')),
                    );
                  }
                },
                child: Text(AppStrings.get('save', lang)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('کوئی سابقہ کھاتہ یا ٹرانزیکشن موجود نہیں', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _entries.length,
                  itemBuilder: (context, idx) {
                    final e = _entries[idx];
                    final isPayment = e.entryType == 'credit';
                    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(e.createdAt),
                    );

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPayment ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          foregroundColor: isPayment ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          child: Icon(isPayment ? Icons.arrow_downward : Icons.arrow_upward),
                        ),
                        title: Text(
                          isPayment ? 'ادائیگی وصول (Payment)' : 'بل چارج (Bill)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${e.description ?? ''}\n$dateStr', style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          '${isPayment ? '-' : '+'} $currency ${e.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPayment ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_card),
        label: const Text('ادائیگی وصول کریں (+)'),
        backgroundColor: const Color(0xFF059669),
        onPressed: _recordPaymentDialog,
      ),
    );
  }
}

