// lib/data/datasources/category_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<Category>> getCategories(CategoryType type);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id, CategoryType type);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String EXPENSE_CATEGORIES_KEY = 'expense_categories';
  static const String INCOME_CATEGORIES_KEY = 'income_categories';

  CategoryLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<Category>> getCategories(CategoryType type) async {
    final key = type == CategoryType.expense 
        ? EXPENSE_CATEGORIES_KEY 
        : INCOME_CATEGORIES_KEY;
    
    final jsonString = sharedPreferences.getString(key);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    }
    
    // Return default categories if none are saved
    final defaultCategories = type == CategoryType.expense
        ? Categories.defaultExpenseCategories
        : Categories.defaultIncomeCategories;
    
    // Save default categories
    await _saveCategories(defaultCategories, type);
    
    return defaultCategories;
  }

  @override
  Future<void> addCategory(Category category) async {
    final categories = await getCategories(
      category.id.startsWith('income_') ? CategoryType.income : CategoryType.expense
    );
    
    categories.add(category);
    await _saveCategories(categories, 
      category.id.startsWith('income_') ? CategoryType.income : CategoryType.expense
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    final type = category.id.startsWith('income_') 
        ? CategoryType.income 
        : CategoryType.expense;
    
    final categories = await getCategories(type);
    final index = categories.indexWhere((c) => c.id == category.id);
    
    if (index != -1) {
      categories[index] = category;
      await _saveCategories(categories, type);
    }
  }

  @override
  Future<void> deleteCategory(String id, CategoryType type) async {
    final categories = await getCategories(type);
    
    // Don't allow deleting the 'other' category
    if (id == 'expense_other' || id == 'income_other') {
      return;
    }
    
    categories.removeWhere((c) => c.id == id);
    await _saveCategories(categories, type);
  }

  Future<void> _saveCategories(List<Category> categories, CategoryType type) async {
    final key = type == CategoryType.expense 
        ? EXPENSE_CATEGORIES_KEY 
        : INCOME_CATEGORIES_KEY;
    
    final jsonList = categories.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(key, json.encode(jsonList));
  }
}
