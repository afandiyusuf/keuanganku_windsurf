// lib/domain/usecases/get_filtered_transactions.dart
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final String? categoryId;

  TransactionFilter({
    this.startDate,
    this.endDate,
    this.type,
    this.categoryId,
  });
}

class GetFilteredTransactions {
  final TransactionRepository repository;

  GetFilteredTransactions(this.repository);

  Future<List<Transaction>> call(TransactionFilter filter) async {
    final transactions = await repository.getTransactions();
    
    return transactions.where((transaction) {
      // Filter by date range
      if (filter.startDate != null && transaction.date.isBefore(filter.startDate!)) {
        return false;
      }
      
      if (filter.endDate != null) {
        // Include the entire end date (until 23:59:59)
        final endOfDay = DateTime(
          filter.endDate!.year, 
          filter.endDate!.month, 
          filter.endDate!.day, 
          23, 59, 59
        );
        if (transaction.date.isAfter(endOfDay)) {
          return false;
        }
      }
      
      // Filter by transaction type
      if (filter.type != null && transaction.type != filter.type) {
        return false;
      }
      
      // Filter by category
      if (filter.categoryId != null && transaction.categoryId != filter.categoryId) {
        return false;
      }
      
      return true;
    }).toList();
  }
}
