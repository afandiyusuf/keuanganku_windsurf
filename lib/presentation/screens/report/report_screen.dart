// lib/presentation/screens/report/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/report_summary.dart';
import '../../widgets/category_chart.dart';
import '../../widgets/filtered_transaction_list.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  bool _isFilterExpanded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => context.read<ReportViewModel>().initialize(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
            icon: Icon(_isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            tooltip: _isFilterExpanded ? 'Sembunyikan Filter' : 'Tampilkan Filter',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter panel yang dapat diperluas
                if (_isFilterExpanded) 
                  const FilterPanel(),
                
                // Gunakan Expanded dengan ListView untuk memungkinkan scroll pada seluruh konten
                Expanded(
                  child: ListView(
                    children: [
                      // Ringkasan laporan
                      const ReportSummary(),
                      
                      // Tab untuk memilih chart kategori
                      Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            tabs: const [
                              Tab(text: 'Pengeluaran'),
                              Tab(text: 'Pemasukan'),
                            ],
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              controller: _tabController,
                              children: const [
                                CategoryChart(isExpense: true),
                                CategoryChart(isExpense: false),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Judul daftar transaksi
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Daftar Transaksi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      
                      // Daftar transaksi tanpa SizedBox dengan tinggi tetap
                      // karena FilteredTransactionList sudah menampilkan semua data secara vertikal
                      const FilteredTransactionList(),
                      
                      // Tambahkan padding di bawah untuk memberikan ruang
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
