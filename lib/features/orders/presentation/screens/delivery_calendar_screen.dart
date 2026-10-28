import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/orders/providers/order_provider.dart';
import 'package:tailor_pro/features/orders/presentation/screens/order_detail_screen.dart';

class DeliveryCalendarScreen extends ConsumerStatefulWidget {
  const DeliveryCalendarScreen({super.key});

  @override
  ConsumerState<DeliveryCalendarScreen> createState() => _DeliveryCalendarScreenState();
}

class _DeliveryCalendarScreenState extends ConsumerState<DeliveryCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final localeState = ref.watch(localeProvider);

    // Filter orders due on selected day
    final selectedDayOrders = orderState.orders.where((o) {
      if (_selectedDay == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(o.deliveryDate);
      return isSameDay(d, _selectedDay);
    }).toList();

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ڈلیوری و ٹرائل کیلنڈر'),
        ),
        body: Column(
          children: [
            // Calendar Widget
            Card(
              margin: const EdgeInsets.all(12),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 90)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Due Orders for Selected Day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_available, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDay != null
                        ? '${DateFormat('dd MMMM yyyy').format(_selectedDay!)} کی ڈلیوریز (${selectedDayOrders.length})'
                        : 'منتخب تاریخ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),

            Expanded(
              child: selectedDayOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'اس تاریخ کو کوئی ڈلیوری مقرر نہیں',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: selectedDayOrders.length,
                      itemBuilder: (context, idx) {
                        final order = selectedDayOrders[idx];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: order.isUrgent ? const Color(0xFFDC2626) : const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              child: Icon(order.isUrgent ? Icons.bolt : Icons.checkroom),
                            ),
                            title: Text('${order.customerName} (${order.orderNumber})'),
                            subtitle: Text('${order.quantity} سوٹ (${order.garmentType}) • اسٹیٹس: ${order.status}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
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

