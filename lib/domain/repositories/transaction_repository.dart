// lib/domain/repositories/transaction_repository.dart
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}