import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../shared/providers/transaction_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);
    
    // Calculate totals for current month
    final now = DateTime.now();
    final currentMonthTransactions = transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month
    ).toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in currentMonthTransactions) {
      if (t.isIncome) totalIncome += t.amount;
      if (t.isExpense) totalExpense += t.amount;
    }

    final balance = totalIncome - totalExpense;
    
    // Recent transactions (up to 5)
    final recentTransactions = transactions.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildBalanceCard(context, balance),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildIncomeExpenseCard(context, true, totalIncome)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildIncomeExpenseCard(context, false, totalExpense)),
                ],
              ),
              const SizedBox(height: 32),
              _buildBudgetChart(context, totalIncome, totalExpense),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaksi Terbaru', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecentTransactions(context, recentTransactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo,',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              DateFormatter.formatMonthYear(DateTime.now()),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.electricTeal.withOpacity(0.2),
          child: const Icon(LucideIcons.wallet, color: AppColors.electricTeal),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatRupiah(balance),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCard(BuildContext context, bool isIncome, double amount) {
    final color = isIncome ? AppColors.electricTeal : AppColors.coralRed;
    final icon = isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight;
    final title = isIncome ? 'Pemasukan' : 'Pengeluaran';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatRupiah(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChart(BuildContext context, double income, double expense) {
    if (income == 0 && expense == 0) {
      return const SizedBox();
    }
    
    // Provide a default logic for budget vs expense, assuming income is the budget
    final sisa = income - expense;
    final displaySisa = sisa < 0 ? 0.0 : sisa;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sisa Budget Bulan Ini', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 70,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.electricTeal,
                      value: displaySisa,
                      title: '',
                      radius: 15,
                    ),
                    PieChartSectionData(
                      color: AppColors.coralRed,
                      value: expense,
                      title: '',
                      radius: 15,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sisa', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    CurrencyFormatter.formatRupiah(displaySisa),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(LucideIcons.receipt, size: 48, color: Theme.of(context).disabledColor),
              const SizedBox(height: 16),
              Text('Belum ada transaksi', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isIncome = t.isIncome;
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? AppColors.electricTeal.withOpacity(0.1) : AppColors.coralRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: isIncome ? AppColors.electricTeal : AppColors.coralRed,
            ),
          ),
          title: Text(t.category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
          subtitle: Text(DateFormatter.formatShortDate(t.date), style: Theme.of(context).textTheme.bodyMedium),
          trailing: Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.formatRupiah(t.amount)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isIncome ? AppColors.electricTeal : AppColors.coralRed,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
