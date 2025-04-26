// lib/presentation/widgets/transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../../presentation/viewmodels/category_viewmodel.dart';
import '../../presentation/viewmodels/transaction_viewmodel.dart';
import '../screens/home/add_transaction_screen.dart';
import '../screens/home/transaction_detail_screen.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, transactionViewModel, child) {
        if (transactionViewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final transactions = transactionViewModel.transactions;

        if (transactions.isEmpty) {
          return const Center(
            child: Text('Belum ada transaksi'),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionItem(
              transaction: transaction,
              onDelete: () {
                transactionViewModel.deleteTransaction(transaction.id);
              },
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(
                      transaction: transaction,
                    ),
                  ),
                );
              },
              onTap: () {
                // Menggunakan MaterialPageRoute dengan fullscreenDialog untuk menghindari konflik hero tag
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => TransactionDetailScreen(
                      transaction: transaction,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Consumer<CategoryViewModel>(
      builder: (context, categoryViewModel, child) {
        final category = categoryViewModel.getCategoryById(transaction.categoryId);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: onTap, // Tambahkan onTap untuk melihat detail
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction.type == TransactionType.expense
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: Text(
                  category?.icon ?? '?',
                  style: TextStyle(
                    color: transaction.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Indikator gambar
                  if (transaction.imagePath != null)
                    Icon(
                      Icons.image,
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.blue,
                      size: 16,
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(transaction.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    category?.name ?? 'Kategori tidak ditemukan',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == TransactionType.expense
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Menggunakan IconButton sebagai pengganti PopupMenuButton
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.visibility),
                              title: const Text('Lihat Detail'),
                              onTap: () {
                                Navigator.pop(context);
                                onTap();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit'),
                              onTap: () {
                                Navigator.pop(context);
                                onEdit();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Hapus'),
                              onTap: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}