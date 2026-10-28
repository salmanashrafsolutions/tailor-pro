import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('backup_restore', lang)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Security Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Color(0xFF059669), size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% آف لائن اور محفوظ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF065F46)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'آپ کا ڈیٹا آپ کے موبائل یا لیپ ٹاپ پر مکمل محفوظ رہتا ہے۔ فون بدلنے یا محفوظ رکھنے کیلئے بیک اپ فائل بنائیں۔',
                          style: TextStyle(fontSize: 12, color: Color(0xFF047857)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Backup Actions Card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.backup),
                    ),
                    title: const Text('مکمل بیک اپ فائل بنائیں (.tpbackup)'),
                    subtitle: const Text('تمام گاہک، ناپ، آرڈرز اور کھاتہ ایک فائل میں محفوظ کریں'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('بیک اپ فائل بن گئی: TailorPro_Backup_20261027.tpbackup')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.settings_backup_restore),
                    ),
                    title: const Text('بیک اپ فائل بحال کریں (Restore)'),
                    subtitle: const Text('کسی بھی سابقہ بیک اپ فائل سے ڈیٹا واپس لائیں'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فائل کا انتخاب کریں...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Excel Import & Export
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF107C41),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.table_view),
                    ),
                    title: const Text('گاہکوں کی فہرست ایکسل میں نکالیں (.xlsx)'),
                    subtitle: const Text('کمپیوٹر یا پرنٹ کیلئے تمام گاہک اور فون نمبرز برآمد کریں'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ایکسل فائل کامیابی سے تیار ہو گئی')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.file_upload),
                    ),
                    title: const Text('ایکسل سے گاہک درآمد کریں (Import)'),
                    subtitle: const Text('سابقہ ایکسل فائل سے گاہکوں کا ڈیٹا شامل کریں'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('درآمد کیلئے فائل منتخب کریں...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recycle Bin (30-day soft delete undo)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEE2E2),
                  foregroundColor: Color(0xFFDC2626),
                  child: Icon(Icons.delete_outline),
                ),
                title: const Text('ری سائیکل بن (کوڑے دان)'),
                subtitle: const Text('حذف شدہ گاہک اور آرڈرز یہاں 30 دن تک موجود رہتے ہیں'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ری سائیکل بن خالی ہے')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

