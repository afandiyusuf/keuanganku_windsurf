import 'package:keuanganku/domain/repositories/transaction_repository.dart';
import 'package:keuanganku/domain/entities/transaction.dart';

class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
  }
}
