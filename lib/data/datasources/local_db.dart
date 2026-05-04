import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class LocalDb {
  static const String _transactionBoxName = 'transactionsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<Transaction>(_transactionBoxName);
  }

  Box<Transaction> get transactionBox => Hive.box<Transaction>(_transactionBoxName);

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
