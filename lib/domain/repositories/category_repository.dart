// lib/domain/repositories/category_repository.dart
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories(CategoryType type);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id, CategoryType type);
  Future<Category> getCategoryById(String id, CategoryType type);
}
