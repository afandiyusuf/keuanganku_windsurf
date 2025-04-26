// lib/data/repositories/transaction_repository_impl.dart
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final transactionModels = await localDataSource.getTransactions();
    return transactionModels;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type,
      categoryId: transaction.categoryId,
      imagePath: transaction.imagePath,
    );
    await localDataSource.addTransaction(transactionModel);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type,
      categoryId: transaction.categoryId,
      imagePath: transaction.imagePath,
    );
    await localDataSource.updateTransaction(transactionModel);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }
}