// lib/presentation/viewmodels/category_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart' as entities;
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'package:uuid/uuid.dart';

class CategoryViewModel extends ChangeNotifier {
  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryViewModel({
    required GetCategories getCategories,
    required AddCategory addCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  })  : _getCategories = getCategories,
        _addCategory = addCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory;

  List<entities.Category> _expenseCategories = [];
  List<entities.Category> get expenseCategories => _expenseCategories;

  List<entities.Category> _incomeCategories = [];
  List<entities.Category> get incomeCategories => _incomeCategories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenseCategories = await _getCategories(entities.CategoryType.expense);
      _incomeCategories = await _getCategories(entities.CategoryType.income);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String icon, entities.CategoryType type) async {
    try {
      final prefix = type == entities.CategoryType.expense ? 'expense_' : 'income_';
      final id = '$prefix${const Uuid().v4()}';
      
      final category = entities.Category(
        id: id,
        name: name,
        icon: icon,
      );
      
      await _addCategory(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(entities.Category category) async {
    try {
      await _updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id, entities.CategoryType type) async {
    try {
      await _deleteCategory(id, type);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Metode untuk mendapatkan kategori berdasarkan ID
  entities.Category? getCategoryById(String categoryId) {
    // Cari di kategori pengeluaran
    try {
      if (categoryId.startsWith('expense_')) {
        return _expenseCategories.firstWhere(
          (category) => category.id == categoryId,
          orElse: () => _expenseCategories.isNotEmpty 
              ? _expenseCategories.first 
              : entities.Category(id: 'expense_other', name: 'Lainnya', icon: '📋'),
        );
      } 
      // Cari di kategori pemasukan
      else if (categoryId.startsWith('income_')) {
        return _incomeCategories.firstWhere(
          (category) => category.id == categoryId,
          orElse: () => _incomeCategories.isNotEmpty 
              ? _incomeCategories.first 
              : entities.Category(id: 'income_other', name: 'Lainnya', icon: '📋'),
        );
      }
      // Jika ID tidak dikenali
      return null;
    } catch (e) {
      return null;
    }
  }
}
