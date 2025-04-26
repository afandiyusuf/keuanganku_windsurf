// lib/presentation/widgets/filtered_transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../presentation/viewmodels/category_viewmodel.dart';
import '../../presentation/viewmodels/report_viewmodel.dart';
import '../screens/home/add_transaction_screen.dart';
import '../screens/home/transaction_detail_screen.dart';

class FilteredTransactionList extends StatelessWidget {
  const FilteredTransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportViewModel, child) {
        final transactions = reportViewModel.transactions;

        if (transactions.isEmpty) {
          return const Center(
            child: Text('Tidak ada transaksi yang sesuai dengan filter'),
          );
        }

        // Menggunakan Column dengan children untuk menampilkan semua transaksi secara vertikal
        // tanpa scroll sendiri
        return Column(
          children: transactions.map((transaction) {
            return FilteredTransactionItem(
              transaction: transaction,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(
                      transaction: transaction,
                    ),
                  ),
                ).then((_) {
                  // Refresh report data when returning from edit screen
                  context.read<ReportViewModel>().applyFilters();
                });
              },
              onTap: () {
                // Menggunakan fullscreenDialog untuk menghindari konflik hero tag
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => TransactionDetailScreen(
                      transaction: transaction,
                    ),
                  ),
                ).then((_) {
                  // Refresh report data when returning from detail screen
                  context.read<ReportViewModel>().applyFilters();
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class FilteredTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const FilteredTransactionItem({
    Key? key,
    required this.transaction,
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
        // Menggunakan metode yang ada di CategoryViewModel dengan penanganan error
        final categories = transaction.type == TransactionType.expense
            ? categoryViewModel.expenseCategories
            : categoryViewModel.incomeCategories;
            
        // Cari kategori dengan penanganan jika tidak ditemukan
        Category category;
        try {
          category = categories.firstWhere(
            (cat) => cat.id == transaction.categoryId,
            orElse: () => categories.isNotEmpty 
                ? categories.first 
                : Category(
                    id: 'default',
                    name: 'Tidak diketahui',
                    icon: '?',
                  ),
          );
        } catch (e) {
          // Fallback jika terjadi error
          category = Category(
            id: 'default',
            name: 'Tidak diketahui',
            icon: '?',
          );
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            onTap: onTap, // Tambahkan onTap untuk melihat detail
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction.type == TransactionType.expense
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: Text(
                  category.icon,
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
                    category.name,
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
