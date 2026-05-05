import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/savings_provider.dart';
import '../widgets/deposit_bottom_sheet.dart';
import '../utils/saving_icon_helper.dart';

class SavingDetailScreen extends ConsumerWidget {
  final String goalId;
  
  const SavingDetailScreen({super.key, required this.goalId});

  void _showDeposit(BuildContext context, ref) {
    final state = ref.read(savingsProvider);
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DepositBottomSheet(initialGoal: goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsProvider);
    
    // Check if goal exists, it might have been deleted
    final goalIndex = savingsState.goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Goal tidak ditemukan')),
      );
    }
    
    final goal = savingsState.goals[goalIndex];
    final deposits = savingsState.deposits.where((d) => d.goalId == goalId).toList();
    
    final color = Color(int.parse(goal.colorHex.replaceAll('#', 'FF'), radix: 16));
    
    // Prepare chart data
    final depositsByMonth = <String, double>{};
    for (var d in deposits) {
      final key = DateFormat('MMM yy').format(d.date);
      depositsByMonth[key] = (depositsByMonth[key] ?? 0) + d.amount;
    }
    
    final sortedMonths = depositsByMonth.keys.toList()..sort((a, b) {
      final da = DateFormat('MMM yy').parse(a);
      final db = DateFormat('MMM yy').parse(b);
      return da.compareTo(db);
    });

    List<FlSpot> areaSpots = [];
    double cumulative = 0;
    for (int i = 0; i < sortedMonths.length; i++) {
      cumulative += depositsByMonth[sortedMonths[i]]!;
      areaSpots.add(FlSpot(i.toDouble(), cumulative));
    }
    
    if (areaSpots.isEmpty) {
      areaSpots.add(const FlSpot(0, 0));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Progress Header
            Center(
              child: CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 16.0,
                percent: (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(SavingIconHelper.getIcon(goal.icon), size: 40, color: color),
                    const SizedBox(height: 8),
                    Text(
                      '${((goal.currentAmount / goal.targetAmount) * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                progressColor: color,
                backgroundColor: Theme.of(context).cardTheme.color ?? Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1500,
              ),
            ),
            const SizedBox(height: 24),
            
            // Info Row
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context, 
                    'Terkumpul', 
                    CurrencyFormatter.formatRupiah(goal.currentAmount),
                    color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context, 
                    'Kekurangan', 
                    CurrencyFormatter.formatRupiah(goal.remainingAmount),
                    AppColors.coralRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Additional Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Status', goal.status, isStatus: true),
                  const Divider(height: 24),
                  _buildInfoRow('Deadline', DateFormat('dd MMM yyyy').format(goal.deadline)),
                  const Divider(height: 24),
                  _buildInfoRow('Sisa Waktu', '${goal.remainingDays} hari'),
                  const Divider(height: 24),
                  _buildInfoRow('Target Setoran /bln', CurrencyFormatter.formatRupiah(goal.monthlyTargetDeposit)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Area Chart
            Text('Riwayat Terkumpul', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(sortedMonths[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: areaSpots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            // Bar Chart Perbandingan Bulanan
            Text('Setoran per Bulan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: max(goal.monthlyTargetDeposit * 1.5, depositsByMonth.values.fold(0.0, max)),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(sortedMonths[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedMonths.length, (i) {
                    final monthAmount = depositsByMonth[sortedMonths[i]]!;
                    final isMet = monthAmount >= goal.monthlyTargetDeposit;
                    
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: monthAmount,
                          color: isMet ? AppColors.electricTeal : AppColors.coralRed,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: goal.monthlyTargetDeposit,
                          color: Colors.grey.withOpacity(0.3),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Riwayat Setoran', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (deposits.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada setoran.')))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deposits.length,
                itemBuilder: (context, index) {
                  final d = deposits[index];
                  return Dismissible(
                    key: Key(d.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(color: AppColors.coralRed, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref.read(savingsProvider.notifier).deleteDeposit(d.id);
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(LucideIcons.arrowDownToLine, color: color, size: 20),
                      ),
                      title: Text(CurrencyFormatter.formatRupiah(d.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${DateFormat('dd MMM yyyy').format(d.date)}${d.note != null ? ' - ${d.note}' : ''}'),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDeposit(context, ref),
        backgroundColor: color,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Setor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: value == 'Completed' ? AppColors.electricTeal.withOpacity(0.1) : (value == 'Behind Schedule' ? AppColors.coralRed.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value == 'Completed' ? AppColors.electricTeal : (value == 'Behind Schedule' ? AppColors.coralRed : Colors.blue),
              ),
            ),
          )
        else
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
