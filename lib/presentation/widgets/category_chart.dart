// lib/presentation/widgets/category_chart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/report_viewmodel.dart';

class CategoryChart extends StatelessWidget {
  final bool isExpense;
  
  const CategoryChart({
    Key? key,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        final Map<String, double> data = isExpense
            ? viewModel.expenseByCategoryMap
            : viewModel.incomeByCategoryMap;
            
        if (data.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada data ${isExpense ? 'pengeluaran' : 'pemasukan'}',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        
        // Urutkan data berdasarkan nilai (dari terbesar ke terkecil)
        final sortedEntries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final categoryId = entry.key;
              final amount = entry.value;
              final categoryName = viewModel.getCategoryName(categoryId);
              final categoryIcon = viewModel.getCategoryIcon(categoryId);
              
              // Hitung persentase dari total
              final total = isExpense ? viewModel.totalExpense : viewModel.totalIncome;
              final percentage = total > 0 ? (amount / total * 100) : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                      child: Text(
                        categoryIcon,
                        style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        categoryName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: isExpense ? Colors.red : Colors.green,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
