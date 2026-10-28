import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/providers/customer_provider.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_edit_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custState = ref.watch(customerProvider);
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('customer_register', lang)),
          actions: [
            IconButton(
              icon: Icon(
                custState.duesOnlyFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: custState.duesOnlyFilter ? Colors.amber : Colors.white,
              ),
              tooltip: 'صرف باقیات والے گاہک',
              onPressed: () {
                ref.read(customerProvider.notifier).loadCustomers(
                      query: _searchController.text,
                      duesOnly: !custState.duesOnlyFilter,
                    );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Input Box
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'نام، فون نمبر یا سیریل سے تلاش کریں...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(customerProvider.notifier).loadCustomers();
                          },
                        )
                      : null,
                ),
                onChanged: (q) {
                  ref.read(customerProvider.notifier).loadCustomers(
                        query: q,
                        duesOnly: custState.duesOnlyFilter,
                      );
                },
              ),
            ),

            // Active Filter Chip Indicator
            if (custState.duesOnlyFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'صرف وہ گاہک دکھائے جا رہے ہیں جن کی طرف رقم واجب الادا ہے',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFF92400E)),
                      onPressed: () {
                        ref.read(customerProvider.notifier).loadCustomers(
                              query: _searchController.text,
                              duesOnly: false,
                            );
                      },
                    ),
                  ],
                ),
              ),

            // Customer List View
            Expanded(
              child: custState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : custState.customers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.get('no_customers_found', lang),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: custState.customers.length,
                          itemBuilder: (context, index) {
                            final customer = custState.customers[index];
                            final hasDues = customer.currentBalance < 0;

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    numFormat(customer.serialNo),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  customer.phone,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (hasDues)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$currency ${numFormat(customer.currentBalance.abs().toStringAsFixed(0))}',
                                          style: const TextStyle(
                                            color: Color(0xFFDC2626),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CustomerDetailScreen(customer: customer),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.person_add),
          label: Text(AppStrings.get('new_customer', lang)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomerEditScreen()),
            );
          },
        ),
      ),
    );
  }
}

