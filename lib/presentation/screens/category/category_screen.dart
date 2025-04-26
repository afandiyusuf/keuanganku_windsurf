// lib/presentation/screens/category/category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/category.dart' as entities;
import '../../viewmodels/category_viewmodel.dart';
import 'edit_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => context.read<CategoryViewModel>().loadCategories(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(entities.CategoryType.expense),
          _buildCategoryList(entities.CategoryType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? entities.CategoryType.expense
              : entities.CategoryType.income;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCategoryScreen(type: type),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(entities.CategoryType type) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('Error: ${viewModel.error}'));
        }

        final categories = type == entities.CategoryType.expense
            ? viewModel.expenseCategories
            : viewModel.incomeCategories;

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isDefaultCategory = category.id.endsWith('_other');
            
            return ListTile(
              leading: CircleAvatar(
                child: Text(category.icon),
              ),
              title: Text(category.name),
              trailing: isDefaultCategory
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCategoryScreen(
                                  type: type,
                                  category: category,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, category.id, type);
                          },
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String categoryId,
    entities.CategoryType type,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: const Text(
            'Yakin ingin menghapus kategori ini? Semua transaksi dengan kategori ini akan diubah ke kategori "Lainnya".',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                context.read<CategoryViewModel>().deleteCategory(categoryId, type);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
