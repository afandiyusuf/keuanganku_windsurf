// lib/data/models/transaction_model.dart
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String categoryId,
    String? imagePath,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          date: date,
          type: type,
          categoryId: categoryId,
          imagePath: imagePath,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.byName(json['type']),
      categoryId: json['categoryId'] ?? (json['type'] == 'expense' ? 'other' : 'salary'),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'categoryId': categoryId,
      'imagePath': imagePath,
    };
  }
}