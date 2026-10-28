import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/dashboard/presentation/screens/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController(text: 'الکرم ٹیلرز اینڈ کلاتھ');
  final _ownerNameController = TextEditingController(text: 'استاد محمد اکرم');
  final _phoneController = TextEditingController(text: '03001234567');
  final _secondaryPhoneController = TextEditingController();
  final _addressController = TextEditingController(text: 'مین بازار، بالمقابل جامع مسجد');
  final _currencyController = TextEditingController(text: 'Rs.');
  final _serialStartController = TextEditingController(text: '1001');
  final _invoiceFooterController = TextEditingController(
    text: 'سلائی کے نقائص کی صورت میں 3 دن کے اندر رجوع فرمائیں۔ بغیر رسید کے سوٹ نہیں ملے گا۔',
  );

  bool _enablePin = false;
  final _pinController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    _serialStartController.dispose();
    _invoiceFooterController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final bizNotifier = ref.read(businessProvider.notifier);
      final serialStart = int.tryParse(_serialStartController.text) ?? 1;

      await bizNotifier.createBusiness(
        name: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phonePrimary: _phoneController.text.trim(),
        phoneSecondary: _secondaryPhoneController.text.trim().isEmpty ? null : _secondaryPhoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        currencySymbol: _currencyController.text.trim().isEmpty ? 'Rs.' : _currencyController.text.trim(),
        serialStartNumber: serialStart,
        invoiceFooterText: _invoiceFooterController.text.trim(),
        pinHash: _enablePin && _pinController.text.isNotEmpty ? _pinController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خرابی: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('setup_title', lang)),
          actions: [
            TextButton.icon(
              onPressed: () => ref.read(localeProvider.notifier).toggleLanguage(),
              icon: const Icon(Icons.language, color: Colors.white),
              label: Text(
                localeState.isUrdu ? 'English' : 'اردو',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.content_cut, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('app_name', lang),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get('tagline', lang),
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Shop Name
                TextFormField(
                  controller: _shopNameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('shop_name', lang),
                    prefixIcon: const Icon(Icons.store),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'براہ کرم دکان کا نام درج کریں' : null,
                ),
                const SizedBox(height: 14),

                // Owner Name
                TextFormField(
                  controller: _ownerNameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('owner_name', lang),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'مالک کا نام ضروری ہے' : null,
                ),
                const SizedBox(height: 14),

                // Phone (Primary)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('phone_primary', lang),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'فون نمبر ضروری ہے' : null,
                ),
                const SizedBox(height: 14),

                // Secondary Phone
                TextFormField(
                  controller: _secondaryPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('phone_secondary', lang),
                    prefixIcon: const Icon(Icons.phone_android),
                  ),
                ),
                const SizedBox(height: 14),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('shop_address', lang),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 14),

                // Row: Currency & Starting Serial No.
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _currencyController,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('currency', lang),
                          prefixIcon: const Icon(Icons.payments),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _serialStartController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('starting_serial', lang),
                          prefixIcon: const Icon(Icons.format_list_numbered),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Invoice Footer
                TextFormField(
                  controller: _invoiceFooterController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('invoice_footer', lang),
                    prefixIcon: const Icon(Icons.receipt_long),
                  ),
                ),
                const SizedBox(height: 16),

                // PIN Security Option
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(AppStrings.get('enable_pin', lang)),
                          subtitle: const Text('دکان کھولنے کیلئے سیکیورٹی پن مقرر کریں'),
                          value: _enablePin,
                          onChanged: (val) => setState(() => _enablePin = val),
                        ),
                        if (_enablePin)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('pin_code', lang),
                                prefixIcon: const Icon(Icons.lock),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          AppStrings.get('setup_complete_btn', lang),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
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

