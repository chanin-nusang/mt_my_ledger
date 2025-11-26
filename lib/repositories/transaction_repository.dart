import 'package:hive/hive.dart';
import 'package:mt_my_ledger/models/transaction.dart';

class TransactionRepository {
  final Box<Transaction> _transactionBox;

  TransactionRepository(this._transactionBox);

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }
}
