import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';

class CustomOptionDialog extends ConsumerStatefulWidget {
  final String category; // e.g. 'collar_band', 'front_patti', 'cuff_style', 'pocket_style', 'daman_style'
  final String categoryName;

  const CustomOptionDialog({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  ConsumerState<CustomOptionDialog> createState() => _CustomOptionDialogState();
}

class _CustomOptionDialogState extends ConsumerState<CustomOptionDialog> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _nameController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    try {
      await AppDatabase.instance.addCustomOption(
        businessId: activeBiz.id,
        category: widget.category,
        valueEn: text,
        valueUr: text,
      );

      if (mounted) {
        Navigator.of(context).pop(text);
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
    final lang = ref.watch(localeProvider).locale.languageCode;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.add_circle, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'نیا آپشن شامل کریں (${widget.categoryName})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'یہ آپشن ایک بار شامل کرنے پر دکان کے مستقل مینو میں محفوظ ہو جائے گا تاکہ آئندہ بار بار لکھنا نہ پڑے۔',
            style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppStrings.get('custom_option_name', lang),
              hintText: 'مثلاً: کٹ بین پائپنگ کے ساتھ',
              prefixIcon: const Icon(Icons.edit_note),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.get('cancel', lang)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(AppStrings.get('save', lang)),
        ),
      ],
    );
  }
}

