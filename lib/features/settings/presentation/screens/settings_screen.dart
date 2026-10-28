import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/business/presentation/screens/business_switcher_screen.dart';
import '../../../backup/presentation/screens/backup_restore_screen.dart';
import 'package:tailor_pro/features/reports/presentation/screens/reports_screen.dart';
import 'package:tailor_pro/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:tailor_pro/features/billing/presentation/screens/dues_list_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBiz = ref.watch(businessProvider).activeBusiness;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('settings', lang)),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Business Profile Header
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  child: Text(activeBiz != null && activeBiz.name.isNotEmpty ? activeBiz.name.substring(0, 1) : 'T'),
                ),
                title: Text(activeBiz?.name ?? 'الکرم ٹیلرز', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${activeBiz?.ownerName ?? ''} • ${activeBiz?.phonePrimary ?? ''}'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BusinessSwitcherScreen()),
                    );
                  },
                  child: const Text('تبدیل کریں'),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Language & Numeral Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('زبان اور ہندسے (Language & Display)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: Color(0xFF1E3A8A)),
                    title: const Text('زبان تبدیل کریں (Language)'),
                    subtitle: Text(localeState.isUrdu ? 'اردو (Urdu RTL)' : 'English (انگریزی)'),
                    trailing: Switch(
                      value: localeState.isUrdu,
                      onChanged: (_) => ref.read(localeProvider.notifier).toggleLanguage(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.format_list_numbered, color: Color(0xFFD97706)),
                    title: const Text('ہندسوں کا انداز (Numerals)'),
                    subtitle: Text(localeState.useUrduNumerals ? 'اردو ہندسے (۱ ۲ ۳ ۴)' : 'انگریزی ہندسے (1 2 3 4)'),
                    trailing: Switch(
                      value: localeState.useUrduNumerals,
                      onChanged: (_) => ref.read(localeProvider.notifier).toggleUrduNumerals(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Business & Management Operations
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('دکان کا انتظام و کھاتہ جات', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.money_off, color: Color(0xFFDC2626)),
                    title: const Text('باقیات اور ادھار رجسٹر (Dues List)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DuesListScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long, color: Color(0xFF059669)),
                    title: const Text('دکان کا خرچہ رجسٹر (Expenses Book)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Color(0xFF2563EB)),
                    title: const Text('رپورٹس اور مالیاتی حساب کتاب'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup, color: Color(0xFF7C3AED)),
                    title: const Text('بیک اپ، بحالی اور ایکسل ایکسپورٹ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Hardware & Printers
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('ہارڈویئر و پرنٹر', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.print, color: Color(0xFF0284C7)),
                title: const Text('تھرمل پرنٹر کنکشن (ESC/POS Bluetooth)'),
                subtitle: const Text('58mm / 80mm بلوٹوتھ رسید پرنٹر سیٹ کریں'),
                trailing: const Icon(Icons.bluetooth),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('بلوٹوتھ پرنٹر تلاش کیا جا رہا ہے...')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // App Version Footer
            const Center(
              child: Column(
                children: [
                  Text('TailorPro (ٹیلر پرو) v1.0.0', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('100% آف لائن اور اوپن سورس', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

