import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/saving_goal.dart';
import '../models/saving_deposit.dart';

class LocalDb {
  static const String _transactionBoxName = 'transactionsBox';
  static const String _savingGoalBoxName = 'savingGoalsBox';
  static const String _savingDepositBoxName = 'savingDepositsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(SavingGoalAdapter());
    Hive.registerAdapter(SavingDepositAdapter());
    
    await Hive.openBox<Transaction>(_transactionBoxName);
    await Hive.openBox<SavingGoal>(_savingGoalBoxName);
    await Hive.openBox<SavingDeposit>(_savingDepositBoxName);
  }

  Box<Transaction> get transactionBox => Hive.box<Transaction>(_transactionBoxName);
  Box<SavingGoal> get savingGoalBox => Hive.box<SavingGoal>(_savingGoalBoxName);
  Box<SavingDeposit> get savingDepositBox => Hive.box<SavingDeposit>(_savingDepositBoxName);

  List<Transaction> getAllTransactions() {
    return transactionBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }
}
