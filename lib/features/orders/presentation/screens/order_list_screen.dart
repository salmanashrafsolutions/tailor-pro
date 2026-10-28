import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/orders/providers/order_provider.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_create_screen.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_detail_screen.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _statusTabs = [
    {'key': 'all', 'ur': 'سبھی آرڈرز'},
    {'key': 'received', 'ur': 'وصول شدہ'},
    {'key': 'cutting', 'ur': 'کٹنگ'},
    {'key': 'stitching', 'ur': 'سلائی'},
    {'key': 'finishing', 'ur': 'فنشنگ'},
    {'key': 'ready', 'ur': 'تیار ہے'},
    {'key': 'delivered', 'ur': 'حوالے شدہ'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final key = _statusTabs[_tabController.index]['key']!;
        ref.read(orderProvider.notifier).loadOrders(status: key);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getNextStatus(String current) {
    switch (current) {
      case 'received':
        return 'cutting';
      case 'cutting':
        return 'stitching';
      case 'stitching':
        return 'finishing';
      case 'finishing':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return 'delivered';
    }
  }

  String _getNextStatusLabel(String current) {
    switch (current) {
      case 'received':
        return 'کٹنگ شروع ➔';
      case 'cutting':
        return 'سلائی شروع ➔';
      case 'stitching':
        return 'فنشنگ میں بھیجیں ➔';
      case 'finishing':
        return 'تیار مارک کریں ✓';
      case 'ready':
        return 'گاہک کے حوالے کریں ✓';
      default:
        return 'مکمل';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'received':
        return const Color(0xFF64748B);
      case 'cutting':
        return const Color(0xFF2563EB);
      case 'stitching':
        return const Color(0xFFD97706);
      case 'finishing':
        return const Color(0xFF7C3AED);
      case 'ready':
        return const Color(0xFF059669);
      case 'delivered':
        return const Color(0xFF16A34A);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final numFormat = ref.read(localeProvider.notifier).formatNumber;
    final currency = ref.watch(businessProvider).activeBusiness?.currencySymbol ?? 'Rs.';

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('orders', lang)),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: _statusTabs.map((t) => Tab(text: t['ur'])).toList(),
          ),
        ),
        body: orderState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderState.orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'اس اسٹیٹس میں کوئی آرڈر موجود نہیں',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orderState.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderState.orders[index];
                      final statusColor = _getStatusColor(order.status);
                      final isDelivered = order.status == 'delivered';
                      final deliveryDateStr = DateFormat('dd MMM yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(order.deliveryDate),
                      );

                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: order),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Order Number, Rush Badge, Status Badge
                                Row(
                                  children: [
                                    Text(
                                      order.orderNumber,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    if (order.isUrgent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.bolt, size: 14, color: Color(0xFFDC2626)),
                                            Text(
                                              'ارجنٹ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFDC2626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        _statusTabs.firstWhere(
                                          (t) => t['key'] == order.status,
                                          orElse: () => {'ur': order.status},
                                        )['ur']!,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Customer Name & Garment Info
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.customerName ?? 'نامعلوم گاہک',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(' • '),
                                    Text(
                                      '${order.quantity} سوٹ (${order.garmentType})',
                                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Delivery Date & Dues Row
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ڈلیوری: $deliveryDateStr',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                    ),
                                    const Spacer(),
                                    Text(
                                      order.balanceDue > 0
                                          ? 'بقایا: $currency ${numFormat(order.balanceDue.toStringAsFixed(0))}'
                                          : 'مکمل ادائیگی ✓',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: order.balanceDue > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),

                                // Bottom Stage Advancement Button
                                if (!isDelivered)
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: statusColor),
                                        foregroundColor: statusColor,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onPressed: () {
                                        final next = _getNextStatus(order.status);
                                        ref.read(orderProvider.notifier).updateOrderStatus(order.id, next);
                                      },
                                      child: Text(
                                        _getNextStatusLabel(order.status),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: Text(AppStrings.get('new_order', lang)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrderCreateScreen()),
            );
          },
        ),
      ),
    );
  }
}

