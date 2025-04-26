// lib/domain/usecases/delete_category.dart
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(String id, CategoryType type) async {
    await repository.deleteCategory(id, type);
  }
}
