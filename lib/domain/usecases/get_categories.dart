// lib/domain/usecases/get_categories.dart
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call(CategoryType type) async {
    return await repository.getCategories(type);
  }
}
