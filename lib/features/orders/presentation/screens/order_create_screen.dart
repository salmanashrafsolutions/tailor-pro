import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';
import 'package:tailor_pro/features/orders/providers/order_provider.dart';

class OrderCreateScreen extends ConsumerStatefulWidget {
  final CustomerModel? selectedCustomer;
  const OrderCreateScreen({super.key, this.selectedCustomer});

  @override
  ConsumerState<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends ConsumerState<OrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerModel? _customer;
  String _garmentType = 'شلوار قمیض';
  int _quantity = 1;
  String _fabricSource = 'customer_cloth'; // 'customer_cloth' or 'shop_cloth'
  final _fabricNotesController = TextEditingController();

  DateTime? _trialDate;
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));

  bool _isUrgent = false;
  final _urgentFeeController = TextEditingController(text: '500');
  final _stitchingChargesController = TextEditingController(text: '1500');
  final _fabricChargesController = TextEditingController(text: '0');
  final _otherChargesController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _advancePaidController = TextEditingController(text: '500');

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _customer = widget.selectedCustomer;
    if (_customer == null) {
      final list = ref.read(customerProvider).customers;
      if (list.isNotEmpty) _customer = list.first;
    }
  }

  @override
  void dispose() {
    _fabricNotesController.dispose();
    _urgentFeeController.dispose();
    _stitchingChargesController.dispose();
    _fabricChargesController.dispose();
    _otherChargesController.dispose();
    _discountController.dispose();
    _advancePaidController.dispose();
    super.dispose();
  }

  double get _grandTotal {
    final stitch = (double.tryParse(_stitchingChargesController.text) ?? 0.0) * _quantity;
    final fabric = double.tryParse(_fabricChargesController.text) ?? 0.0;
    final other = double.tryParse(_otherChargesController.text) ?? 0.0;
    final urgent = _isUrgent ? (double.tryParse(_urgentFeeController.text) ?? 0.0) : 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    return (stitch + fabric + other + urgent) - discount;
  }

  double get _balanceDue {
    final advance = double.tryParse(_advancePaidController.text) ?? 0.0;
    return _grandTotal - advance;
  }

  Future<void> _submit() async {
    if (_customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پہلے گاہک منتخب کریں')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final stitch = (double.tryParse(_stitchingChargesController.text) ?? 0.0) * _quantity;
      final fabric = double.tryParse(_fabricChargesController.text) ?? 0.0;
      final other = double.tryParse(_otherChargesController.text) ?? 0.0;
      final urgent = _isUrgent ? (double.tryParse(_urgentFeeController.text) ?? 0.0) : 0.0;
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      final advance = double.tryParse(_advancePaidController.text) ?? 0.0;

      await ref.read(orderProvider.notifier).createOrder(
            customerId: _customer!.id,
            measurementId: 'default_measurement',
            garmentType: _garmentType,
            quantity: _quantity,
            fabricSource: _fabricSource,
            fabricNotes: _fabricNotesController.text.trim(),
            isUrgent: _isUrgent,
            urgentSurcharge: urgent,
            totalStitchingCharges: stitch,
            totalFabricCharges: fabric,
            otherCharges: other,
            discountAmount: discount,
            advancePaid: advance,
            trialDate: _trialDate?.millisecondsSinceEpoch,
            deliveryDate: _deliveryDate.millisecondsSinceEpoch,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نیا آرڈر کامیابی سے بک ہو گیا')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خرابی: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider).customers;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('new_order', lang)),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Customer Selector
                if (widget.selectedCustomer != null)
                  Card(
                    color: const Color(0xFFEFF6FF),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1E3A8A),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(_customer!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${_customer!.phone} • سیریل #${_customer!.serialNo}'),
                    ),
                  )
                else
                  DropdownButtonFormField<CustomerModel>(
                    initialValue: _customer,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('customer_name', lang),
                      prefixIcon: const Icon(Icons.person_search),
                    ),
                    items: customers.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} (${c.phone}) - #${c.serialNo}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _customer = val),
                    validator: (v) => v == null ? 'گاہک منتخب کرنا ضروری ہے' : null,
                  ),
                const SizedBox(height: 16),

                // 2. Garment Type & Quantity
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _garmentType,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('garment_type', lang),
                          prefixIcon: const Icon(Icons.checkroom),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'شلوار قمیض', child: Text('شلوار قمیض')),
                          DropdownMenuItem(value: 'کرتا پاجامہ', child: Text('کرتا پاجامہ')),
                          DropdownMenuItem(value: 'ویسٹ کوٹ', child: Text('ویسٹ کوٹ')),
                          DropdownMenuItem(value: 'شیروانی', child: Text('شیروانی')),
                          DropdownMenuItem(value: 'پینٹ شرٹ', child: Text('پینٹ شرٹ')),
                          DropdownMenuItem(value: 'کوٹ سوٹ', child: Text('کوٹ سوٹ')),
                          DropdownMenuItem(value: 'لیڈیز سوٹ', child: Text('لیڈیز سوٹ')),
                        ],
                        onChanged: (val) => setState(() => _garmentType = val ?? 'شلوار قمیض'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                          Text('$_quantity جوڑے', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Fabric Source Segmented Button
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'customer_cloth',
                      label: Text(AppStrings.get('own_cloth', lang)),
                      icon: const Icon(Icons.person_pin),
                    ),
                    ButtonSegment(
                      value: 'shop_cloth',
                      label: Text(AppStrings.get('shop_cloth', lang)),
                      icon: const Icon(Icons.store),
                    ),
                  ],
                  selected: {_fabricSource},
                  onSelectionChanged: (val) => setState(() => _fabricSource = val.first),
                ),
                const SizedBox(height: 12),

                // Fabric Notes
                TextFormField(
                  controller: _fabricNotesController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('fabric_details', lang),
                    hintText: 'مثلاً: واش اینڈ ویئر، کالا رنگ، 4 میٹر، لٹھا شلوار...',
                    prefixIcon: const Icon(Icons.texture),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Dates: Trial Date & Delivery Date
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event_repeat),
                        label: Text(
                          _trialDate == null ? 'ٹرائل تاریخ مقرر کریں' : DateFormat('dd/MM/yyyy').format(_trialDate!),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 4)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _trialDate = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                        icon: const Icon(Icons.local_shipping),
                        label: Text(
                          'ڈلیوری: ${DateFormat('dd/MM/yyyy').format(_deliveryDate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deliveryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _deliveryDate = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Urgent Rush Order Toggle
                Card(
                  color: _isUrgent ? const Color(0xFFFEF2F2) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: _isUrgent ? const Color(0xFFEF4444) : Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Row(
                            children: [
                              Icon(Icons.bolt, color: Color(0xFFDC2626)),
                              SizedBox(width: 8),
                              Text('ارجنٹ آرڈر (فوری ضرورت)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          value: _isUrgent,
                          onChanged: (val) => setState(() => _isUrgent = val),
                        ),
                        if (_isUrgent)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              controller: _urgentFeeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'ارجنٹ اضافی فیس',
                                prefixIcon: Icon(Icons.price_change),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Charges & Billing Breakdown
                Text(
                  AppStrings.get('billing', lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 10),

                // Stitching Charges per suit
                TextFormField(
                  controller: _stitchingChargesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'سلائی فیس (فی سوٹ)',
                    prefixIcon: const Icon(Icons.straighten),
                    suffixText: '$_quantity سوٹ = $currency ${((double.tryParse(_stitchingChargesController.text) ?? 0) * _quantity).toStringAsFixed(0)}',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v == null || v.trim().isEmpty ? 'سلائی چارجز ضروری ہیں' : null,
                ),
                const SizedBox(height: 12),

                if (_fabricSource == 'shop_cloth') ...[
                  TextFormField(
                    controller: _fabricChargesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('fabric_charges', lang),
                      prefixIcon: const Icon(Icons.shopping_bag),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],

                // Advance Payment
                TextFormField(
                  controller: _advancePaidController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('advance_paid', lang),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Summary Total Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.get('grand_total', lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '$currency ${_grandTotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.get('remaining_balance', lang), style: const TextStyle(fontSize: 15, color: Color(0xFF475569))),
                          Text(
                            '$currency ${_balanceDue.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _balanceDue > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'محفوظ ہو رہا ہے...' : 'آرڈر مکمل کریں اور محفوظ کریں',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

