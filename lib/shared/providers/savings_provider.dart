import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/saving_goal.dart';
import '../../data/models/saving_deposit.dart';
import 'transaction_provider.dart';

final savingsProvider = NotifierProvider<SavingsNotifier, SavingsState>(() {
  return SavingsNotifier();
});

class SavingsState {
  final List<SavingGoal> goals;
  final List<SavingDeposit> deposits;

  SavingsState({required this.goals, required this.deposits});

  SavingsState copyWith({List<SavingGoal>? goals, List<SavingDeposit>? deposits}) {
    return SavingsState(
      goals: goals ?? this.goals,
      deposits: deposits ?? this.deposits,
    );
  }
}

class SavingsNotifier extends Notifier<SavingsState> {
  @override
  SavingsState build() {
    final db = ref.read(localDbProvider);
    return SavingsState(
      goals: db.savingGoalBox.values.toList()..sort((a, b) => a.deadline.compareTo(b.deadline)),
      deposits: db.savingDepositBox.values.toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  void loadData() {
    final db = ref.read(localDbProvider);
    state = state.copyWith(
      goals: db.savingGoalBox.values.toList()..sort((a, b) => a.deadline.compareTo(b.deadline)),
      deposits: db.savingDepositBox.values.toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<void> addGoal(SavingGoal goal) async {
    final db = ref.read(localDbProvider);
    await db.savingGoalBox.put(goal.id, goal);
    loadData();
  }

  Future<void> updateGoal(SavingGoal goal) async {
    final db = ref.read(localDbProvider);
    await db.savingGoalBox.put(goal.id, goal);
    loadData();
  }

  Future<void> deleteGoal(String id) async {
    final db = ref.read(localDbProvider);
    await db.savingGoalBox.delete(id);
    
    // Delete associated deposits
    final depositsToDelete = db.savingDepositBox.values.where((d) => d.goalId == id).map((d) => d.id).toList();
    await db.savingDepositBox.deleteAll(depositsToDelete);
    
    loadData();
  }

  Future<void> addDeposit(SavingDeposit deposit) async {
    final db = ref.read(localDbProvider);
    await db.savingDepositBox.put(deposit.id, deposit);
    
    // Update goal current amount
    final goal = db.savingGoalBox.get(deposit.goalId);
    if (goal != null) {
      final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + deposit.amount);
      await db.savingGoalBox.put(updatedGoal.id, updatedGoal);
    }
    
    loadData();
  }

  Future<void> deleteDeposit(String depositId) async {
    final db = ref.read(localDbProvider);
    final deposit = db.savingDepositBox.get(depositId);
    
    if (deposit != null) {
      // Revert goal current amount
      final goal = db.savingGoalBox.get(deposit.goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount - deposit.amount);
        await db.savingGoalBox.put(updatedGoal.id, updatedGoal);
      }
      
      await db.savingDepositBox.delete(depositId);
      loadData();
    }
  }
}
