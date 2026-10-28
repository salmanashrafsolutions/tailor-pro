import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';

class CustomerEditScreen extends ConsumerStatefulWidget {
  final CustomerModel? customer; // null if adding new
  const CustomerEditScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends ConsumerState<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serialController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    final currentBiz = ref.read(businessProvider).activeBusiness;

    _serialController = TextEditingController(
      text: c != null ? c.serialNo.toString() : (currentBiz?.currentSerialNumber ?? 1).toString(),
    );
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _secondaryPhoneController = TextEditingController(text: c?.secondaryPhone ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final custNotifier = ref.read(customerProvider.notifier);
      final serialNo = int.tryParse(_serialController.text) ?? 1;

      if (widget.customer == null) {
        // Create New Customer
        await custNotifier.createCustomer(
          serialNo: serialNo,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          secondaryPhone: _secondaryPhoneController.text.trim().isEmpty ? null : _secondaryPhoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        // Increment business current serial
        await ref.read(businessProvider.notifier).getNextSerialAndIncrement();
      } else {
        // Update Existing
        final updated = CustomerModel(
          id: widget.customer!.id,
          businessId: widget.customer!.businessId,
          serialNo: serialNo,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          secondaryPhone: _secondaryPhoneController.text.trim().isEmpty ? null : _secondaryPhoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          currentBalance: widget.customer!.currentBalance,
          createdAt: widget.customer!.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await custNotifier.updateCustomer(updated);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خرابی: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final isEditing = widget.customer != null;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'گاہک کی معلومات میں ترمیم' : 'نیا گاہک کارڈ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isSaving ? null : _save,
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
                // Serial Number
                TextFormField(
                  controller: _serialController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('serial_no', lang),
                    prefixIcon: const Icon(Icons.tag),
                    helperText: 'سیریل نمبر رجسٹر پر لکھا جانے والا نمبر ہے',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'سیریل نمبر ضروری ہے' : null,
                ),
                const SizedBox(height: 14),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('customer_name', lang),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'گاہک کا نام ضروری ہے' : null,
                ),
                const SizedBox(height: 14),

                // Primary Phone / WhatsApp
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('phone_number', lang),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'فون نمبر ضروری ہے' : null,
                ),
                const SizedBox(height: 14),

                // Secondary Phone
                TextFormField(
                  controller: _secondaryPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'دوسرا فون نمبر (اختیاری)',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
                const SizedBox(height: 14),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'پتہ / علاقہ (اختیاری)',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 14),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'خاص نوٹ / پہچان (اختیاری)',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    AppStrings.get('save', lang),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

