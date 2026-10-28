import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/business/presentation/screens/business_switcher_screen.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:tailor_pro/features/customers/presentation/screens/customer_edit_screen.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_list_screen.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_create_screen.dart';
import 'package:tailor_pro/features/orders/presentation/screens/delivery_calendar_screen.dart';
import 'package:tailor_pro/features/billing/presentation/screens/dues_list_screen.dart';
import 'package:tailor_pro/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:tailor_pro/features/reports/presentation/screens/reports_screen.dart';
import 'package:tailor_pro/features/settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bizState = ref.watch(businessProvider);
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final activeBiz = bizState.activeBusiness;

    final List<Widget> pages = [
      _buildDashboardHome(context, lang, activeBiz),
      const CustomerListScreen(),
      const OrderListScreen(),
      const DeliveryCalendarScreen(),
      const SettingsScreen(),
    ];

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        body: pages[_currentTabIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: AppStrings.get('dashboard', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: AppStrings.get('customer_register', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedIcon: const Icon(Icons.shopping_bag),
              label: AppStrings.get('orders', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: AppStrings.get('delivery_date', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu),
              selectedIcon: const Icon(Icons.menu_open),
              label: AppStrings.get('settings', lang),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context, String lang, dynamic activeBiz) {
    final isUrdu = ref.watch(localeProvider).isUrdu;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = activeBiz?.currencySymbol ?? 'Rs.';

    return CustomScrollView(
      slivers: [
        // App Bar with Shop Switcher
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 120,
          backgroundColor: const Color(0xFF1E3A8A),
          title: Row(
            children: [
              const Icon(Icons.content_cut, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                activeBiz != null ? activeBiz.name : AppStrings.get('app_name', lang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            // Business Switcher Chip
            IconButton(
              icon: const Icon(Icons.storefront, color: Colors.white),
              tooltip: AppStrings.get('switch_business', lang),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BusinessSwitcherScreen()),
                );
              },
            ),
            // Language Toggle
            TextButton(
              onPressed: () => ref.read(localeProvider.notifier).toggleLanguage(),
              child: Text(
                isUrdu ? 'EN' : 'اردو',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                activeBiz != null
                    ? '${activeBiz.ownerName} • ${activeBiz.phonePrimary}'
                    : AppStrings.get('tagline', lang),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ),

        // Body Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Urgent Orders Alert Banner
                Card(
                  color: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFDC2626),
                      child: Icon(Icons.bolt, color: Colors.white),
                    ),
                    title: Text(
                      AppStrings.get('urgent_orders', lang),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                    ),
                    subtitle: const Text('3 ارجنٹ سوٹ فوری سلائی کے منتظر ہیں'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF991B1B)),
                    onTap: () {
                      setState(() => _currentTabIndex = 2); // Switch to Orders
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // KPI Counter Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.45,
                  children: [
                    _buildKpiCard(
                      title: AppStrings.get('today_orders', lang),
                      count: numFormat('8'),
                      icon: Icons.assignment,
                      iconColor: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                      onTap: () => setState(() => _currentTabIndex = 2),
                    ),
                    _buildKpiCard(
                      title: AppStrings.get('pending_trials', lang),
                      count: numFormat('5'),
                      icon: Icons.checkroom,
                      iconColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFFFBEB),
                      onTap: () => setState(() => _currentTabIndex = 3),
                    ),
                    _buildKpiCard(
                      title: AppStrings.get('pending_deliveries', lang),
                      count: numFormat('4'),
                      icon: Icons.local_shipping,
                      iconColor: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () => setState(() => _currentTabIndex = 3),
                    ),
                    _buildKpiCard(
                      title: AppStrings.get('cash_received_today', lang),
                      count: '$currency ${numFormat('14,500')}',
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF0D9488),
                      bgColor: const Color(0xFFF0FDFA),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Full Width Udhaar Banner
                Card(
                  color: const Color(0xFFFFF7ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFFED7AA)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEA580C),
                      child: Icon(Icons.money_off, color: Colors.white),
                    ),
                    title: Text(
                      AppStrings.get('total_outstanding', lang),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$currency ${numFormat('48,200')}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DuesListScreen()),
                        );
                      },
                      child: Text(AppStrings.get('view_khata', lang)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Action Buttons
                Text(
                  AppStrings.get('quick_actions', lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: Text(AppStrings.get('new_customer', lang)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CustomerEditScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(AppStrings.get('new_order', lang)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const OrderCreateScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long),
                        label: Text(AppStrings.get('daily_expense', lang)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.bar_chart),
                        label: Text(AppStrings.get('reports', lang)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: iconColor, size: 26),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.black38),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

