// lib/domain/usecases/add_category.dart
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository repository;

  AddCategory(this.repository);

  Future<void> call(Category category) async {
    await repository.addCategory(category);
  }
}
