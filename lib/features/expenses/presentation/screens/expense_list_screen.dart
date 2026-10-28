import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/expenses/models/expense_model.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  final _uuid = const Uuid();

  final Map<String, String> _categories = {
    'tea': 'چائے، کھانا و مہمان نوازی',
    'material': 'دھاگہ، بکرم و مٹیریل',
    'wages': 'کاریگروں کی اجرت',
    'utilities': 'بجلی / گیس / انٹرنیٹ بل',
    'rent': 'دکان کا کرایہ',
    'misc': 'متفرق خرچہ',
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'business_id = ?',
      whereArgs: [activeBiz.id],
      orderBy: 'created_at DESC',
    );

    setState(() {
      _expenses = rows.map((r) => ExpenseModel.fromMap(r)).toList();
      _isLoading = false;
    });
  }

  void _addExpenseDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = 'tea';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final lang = ref.watch(localeProvider).locale.languageCode;
          final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

          return AlertDialog(
            title: const Text('نیا خرچہ درج کریں'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'خرچے کی رقم',
                      prefixText: '$currency ',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'خرچے کی مد', prefixIcon: Icon(Icons.category)),
                    items: _categories.entries.map((e) {
                      return DropdownMenuItem(value: e.key, child: Text(e.value));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val ?? 'tea'),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'تفصیل (مثلاً: کاریگر بشیر کو ایڈوانس، چائے بسکٹ)',
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
                  final exp = ExpenseModel(
                    id: _uuid.v4(),
                    businessId: activeBiz.id,
                    category: selectedCategory,
                    amount: amt,
                    notes: noteController.text.trim(),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  );

                  await db.insert('expenses', exp.toMap());

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (mounted) {
                    _loadExpenses();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('خرچہ کامیابی سے درج ہو گیا')),
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
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    final double totalExpense = _expenses.fold(0.0, (acc, e) => acc + e.amount);

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('expenses', lang)),
        ),
        body: Column(
          children: [
            // Total Expense Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('کل اخراجات (Total Expenses)', style: TextStyle(fontSize: 13, color: Color(0xFF92400E))),
                      const SizedBox(height: 4),
                      Text(
                        '$currency ${numFormat(totalExpense.toStringAsFixed(0))}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.receipt_long),
                  ),
                ],
              ),
            ),

            // Expense Records List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.money_off, size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('کوئی خرچہ درج نہیں کیا گیا', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _expenses.length,
                          itemBuilder: (context, idx) {
                            final e = _expenses[idx];
                            final catName = _categories[e.category] ?? e.category;
                            final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(e.createdAt),
                            );

                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFF1F5F9),
                                  foregroundColor: Color(0xFF475569),
                                  child: Icon(Icons.receipt),
                                ),
                                title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${e.notes ?? ''}\n$dateStr', style: const TextStyle(fontSize: 12)),
                                trailing: Text(
                                  '$currency ${numFormat(e.amount.toStringAsFixed(0))}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('نیا خرچہ درج کریں (+)'),
          backgroundColor: const Color(0xFFDC2626),
          onPressed: _addExpenseDialog,
        ),
      ),
    );
  }
}

