import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBiz = ref.watch(businessProvider).activeBusiness;
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = activeBiz?.currencySymbol ?? 'Rs.';

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('reports', lang)),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: AppStrings.get('export_pdf', lang),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('پی ڈی ایف رپورٹ برآمد ہو گئی ہے')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.table_view),
              tooltip: AppStrings.get('export_excel', lang),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ایکسل رپورٹ برآمد ہو گئی ہے')),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Month Overview Summary Card
            Card(
              color: const Color(0xFF1E3A8A),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('اس ماہ کا خلاصہ (اکتوبر 2026)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '$currency ${numFormat('184,500')}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('کل آمدن (Total Revenue)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('$currency ${numFormat('42,000')}', style: const TextStyle(color: Color(0xFFFECACA), fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            const Text('کل اخراجات', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        Column(
                          children: [
                            Text('$currency ${numFormat('142,500')}', style: const TextStyle(color: Color(0xFFA7F3D0), fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            const Text('خالص منافع (Net Profit)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Garments Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('سب سے زیادہ سلنے والے ملبوسات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 12),
                    _buildGarmentStatRow('شلوار قمیض', 48, 0.65, const Color(0xFF1E3A8A)),
                    _buildGarmentStatRow('کرتا پاجامہ', 14, 0.20, const Color(0xFFD97706)),
                    _buildGarmentStatRow('ویسٹ کوٹ', 8, 0.10, const Color(0xFF059669)),
                    _buildGarmentStatRow('پینٹ شرٹ', 4, 0.05, const Color(0xFF7C3AED)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tailor Wages & Productivity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('کاریگروں کی کارکردگی اور واجب الادا اجرت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Text('ب')),
                      title: const Text('استاد بشیر (کٹنگ ماسٹر)'),
                      subtitle: const Text('42 سوٹ کٹنگ • واجب الادا: Rs 10,500'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('ادائیگی', style: TextStyle(fontSize: 11, color: Colors.white)),
                        onPressed: () {},
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Text('ط')),
                      title: const Text('محمد طارق (سلائی درزی)'),
                      subtitle: const Text('28 سوٹ سلائی • واجب الادا: Rs 21,000'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('ادائیگی', style: TextStyle(fontSize: 11, color: Colors.white)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentStatRow(String name, int count, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$count سوٹ (${(percent * 100).toInt()}%)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

