// lib/presentation/widgets/filter_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../viewmodels/report_viewmodel.dart';
import '../../core/utils/date_formatter.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportViewModel>();
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Range Filter
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      context,
                      'Dari Tanggal',
                      viewModel.startDate,
                      (date) => viewModel.setDateRange(date, viewModel.endDate),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      context,
                      'Sampai Tanggal',
                      viewModel.endDate,
                      (date) => viewModel.setDateRange(viewModel.startDate, date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Transaction Type Filter
              Row(
                children: [
                  const Text('Tipe: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Semua'),
                            selected: viewModel.selectedType == null,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.setTransactionType(null);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Pemasukan'),
                            selected: viewModel.selectedType == TransactionType.income,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.setTransactionType(TransactionType.income);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Pengeluaran'),
                            selected: viewModel.selectedType == TransactionType.expense,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.setTransactionType(TransactionType.expense);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Category Filter
              if (viewModel.selectedType != null) ...[
                const Text('Kategori:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua Kategori'),
                      selected: viewModel.selectedCategoryId == null,
                      onSelected: (selected) {
                        if (selected) {
                          viewModel.setCategoryId(null);
                        }
                      },
                    ),
                    ...viewModel.selectedType == TransactionType.expense
                        ? viewModel.expenseCategories.map(
                            (category) => ChoiceChip(
                              avatar: Text(category.icon),
                              label: Text(category.name),
                              selected: viewModel.selectedCategoryId == category.id,
                              onSelected: (selected) {
                                if (selected) {
                                  viewModel.setCategoryId(category.id);
                                }
                              },
                            ),
                          )
                        : viewModel.incomeCategories.map(
                            (category) => ChoiceChip(
                              avatar: Text(category.icon),
                              label: Text(category.name),
                              selected: viewModel.selectedCategoryId == category.id,
                              onSelected: (selected) {
                                if (selected) {
                                  viewModel.setCategoryId(category.id);
                                }
                              },
                            ),
                          ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => viewModel.resetFilters(),
                  child: const Text('Reset Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? initialDate,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          initialDate != null
              ? DateFormatter.formatDate(initialDate)
              : 'Pilih Tanggal',
        ),
      ),
    );
  }
}
