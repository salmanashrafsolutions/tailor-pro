import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_detail_screen.dart';

class DuesListScreen extends ConsumerWidget {
  const DuesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custState = ref.watch(customerProvider);
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    // Filter customers who owe money
    final duesCustomers = custState.customers.where((c) => c.currentBalance < 0).toList();
    final double totalDues = duesCustomers.fold(0.0, (acc, c) => acc + c.currentBalance.abs());

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('total_outstanding', lang)),
        ),
        body: Column(
          children: [
            // Top Total Dues Hero Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'دکان کے کل بقایا جات (ادھار)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$currency ${numFormat(totalDues.toStringAsFixed(0))}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${duesCustomers.length} گاہکوں کی طرف رقم واجب الادا ہے',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Customer Dues List
            Expanded(
              child: duesCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'ماشاءاللہ! کوئی بقایا رقم واجب الادا نہیں',
                            style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: duesCustomers.length,
                      itemBuilder: (context, idx) {
                        final c = duesCustomers[idx];
                        final dueAmt = c.currentBalance.abs();

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFEE2E2),
                              foregroundColor: const Color(0xFFDC2626),
                              child: Text(numFormat(c.serialNo)),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${c.phone}\nبقایا رقم: $currency ${numFormat(dueAmt.toStringAsFixed(0))}'),
                            trailing: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                minimumSize: const Size(0, 36),
                              ),
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text('یاد دہانی', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${c.name} کو واٹس ایپ یاد دہانی بھیجی جا رہی ہے...'),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: c)),
                              );
                            },
                          ),
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

