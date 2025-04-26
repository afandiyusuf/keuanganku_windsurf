// lib/data/datasources/transaction_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String TRANSACTIONS_KEY = 'transactions';

  TransactionLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final jsonString = sharedPreferences.getString(TRANSACTIONS_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await _saveTransactions(transactions);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await _saveTransactions(transactions);
  }

  Future<void> _saveTransactions(List<TransactionModel> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await sharedPreferences.setString(TRANSACTIONS_KEY, json.encode(jsonList));
  }
}