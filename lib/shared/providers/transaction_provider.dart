import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_db.dart';
import '../../data/models/transaction.dart';

final localDbProvider = Provider<LocalDb>((ref) {
  return LocalDb();
});

final transactionListProvider = NotifierProvider<TransactionListNotifier, List<Transaction>>(() {
  return TransactionListNotifier();
});

class TransactionListNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    // Return empty initially, then load
    final db = ref.read(localDbProvider);
    return db.getAllTransactions();
  }

  void loadTransactions() {
    final db = ref.read(localDbProvider);
    state = db.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = ref.read(localDbProvider);
    await db.addTransaction(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = ref.read(localDbProvider);
    await db.updateTransaction(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    final db = ref.read(localDbProvider);
    await db.deleteTransaction(id);
    loadTransactions();
  }
}
