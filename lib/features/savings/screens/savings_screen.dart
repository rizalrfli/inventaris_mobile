import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/savings_provider.dart';
import '../widgets/create_goal_bottom_sheet.dart';
import '../widgets/deposit_bottom_sheet.dart';

import '../utils/saving_icon_helper.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  void _showCreateGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateGoalBottomSheet(),
    );
  }

  void _showDeposit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DepositBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsProvider);
    final goals = savingsState.goals;

    double totalCurrent = goals.fold(0, (sum, goal) => sum + goal.currentAmount);
    double totalTarget = goals.fold(0, (sum, goal) => sum + goal.targetAmount);
    double masterProgress = totalTarget > 0 ? (totalCurrent / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan'),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.electricTeal),
            onPressed: () => _showCreateGoal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Master Progress
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.deepNavy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Text('Total Terkumpul', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatRupiah(totalCurrent),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text('dari target ${CurrencyFormatter.formatRupiah(totalTarget)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                    const SizedBox(height: 24),
                    LinearPercentIndicator(
                      lineHeight: 12.0,
                      percent: masterProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      progressColor: AppColors.electricTeal,
                      barRadius: const Radius.circular(6),
                      animation: true,
                      animationDuration: 1000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Goal Tabungan Anda', style: Theme.of(context).textTheme.titleLarge),
                  if (goals.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _showDeposit(context),
                      icon: const Icon(LucideIcons.piggyBank, size: 16),
                      label: const Text('Setor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricTeal,
                        foregroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (goals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.target, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Belum ada goal tabungan.'),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => _showCreateGoal(context),
                          child: const Text('Buat Goal Baru'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isCompleted = goal.status == 'Completed';
                    final goalColor = Color(int.parse(goal.colorHex.replaceAll('#', 'FF'), radix: 16));
                    
                    return Dismissible(
                      key: Key(goal.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: AppColors.coralRed, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        ref.read(savingsProvider.notifier).deleteGoal(goal.id);
                      },
                      child: GestureDetector(
                        onTap: () => context.push('/savings/${goal.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: goalColor.withOpacity(0.3), width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: goalColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(SavingIconHelper.getIcon(goal.icon), size: 24, color: goalColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                                        Text('Sisa ${goal.remainingDays} hari', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.electricTeal.withOpacity(0.1) : (goal.status == 'Behind Schedule' ? AppColors.coralRed.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      goal.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? AppColors.electricTeal : (goal.status == 'Behind Schedule' ? AppColors.coralRed : Colors.blue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(CurrencyFormatter.formatRupiah(goal.currentAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(CurrencyFormatter.formatRupiah(goal.targetAmount), style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearPercentIndicator(
                                lineHeight: 8.0,
                                padding: EdgeInsets.zero,
                                percent: (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0),
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                progressColor: Color(int.parse(goal.colorHex.replaceAll('#', 'FF'), radix: 16)),
                                barRadius: const Radius.circular(4),
                                animation: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
