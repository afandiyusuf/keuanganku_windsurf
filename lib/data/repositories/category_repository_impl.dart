// lib/data/repositories/category_repository_impl.dart
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<List<Category>> getCategories(CategoryType type) async {
    return await localDataSource.getCategories(type);
  }

  @override
  Future<void> addCategory(Category category) async {
    await localDataSource.addCategory(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await localDataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id, CategoryType type) async {
    await localDataSource.deleteCategory(id, type);
  }

  @override
  Future<Category> getCategoryById(String id, CategoryType type) async {
    final categories = await localDataSource.getCategories(type);
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => type == CategoryType.expense
          ? Categories.defaultExpenseCategories.last
          : Categories.defaultIncomeCategories.last,
    );
  }
}
