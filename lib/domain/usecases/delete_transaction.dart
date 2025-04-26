import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteTransaction(id);
  }
}
