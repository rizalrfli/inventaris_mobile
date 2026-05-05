import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../shared/providers/transaction_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider);
    
    // Get transactions for selected day
    final selectedDayTransactions = transactions.where((t) {
      return _selectedDay != null && 
             t.date.year == _selectedDay!.year && 
             t.date.month == _selectedDay!.month && 
             t.date.day == _selectedDay!.day;
    }).toList();

    double dailyExpense = 0;
    for (var t in selectedDayTransactions) {
      if (t.isExpense) dailyExpense += t.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Biaya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.deepNavy,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.electricTeal.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.coralRed,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) {
                  return transactions.where((t) => isSameDay(t.date, day)).toList();
                },
              ),
            ),
            const SizedBox(height: 32),

            // Daily Summary Card
            if (_selectedDay != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.deepNavy, Color(0xFF2A314E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran Hari Ini',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatRupiah(dailyExpense),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Daily Transactions List
            Text('Detail Transaksi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            selectedDayTransactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('Tidak ada transaksi di hari ini', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedDayTransactions.length,
                    itemBuilder: (context, index) {
                      final t = selectedDayTransactions[index];
                      final isIncome = t.isIncome;
                      
                      return Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.coralRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.trash2, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          ref.read(transactionListProvider.notifier).deleteTransaction(t.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isIncome ? AppColors.electricTeal.withOpacity(0.1) : AppColors.coralRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                                color: isIncome ? AppColors.electricTeal : AppColors.coralRed,
                              ),
                            ),
                            title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: t.description?.isNotEmpty == true ? Text(t.description!) : null,
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${CurrencyFormatter.formatRupiah(t.amount)}',
                              style: TextStyle(
                                color: isIncome ? AppColors.electricTeal : AppColors.coralRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
