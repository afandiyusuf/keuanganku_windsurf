// lib/domain/entities/category.dart
import 'transaction.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
  
  Category copyWith({
    String? name,
    String? icon,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}

// Predefined categories
class Categories {
  static List<Category> defaultExpenseCategories = [
    Category(id: 'expense_food', name: 'Makanan', icon: '🍔'),
    Category(id: 'expense_home', name: 'Rumah', icon: '🏠'),
    Category(id: 'expense_electricity', name: 'Listrik', icon: '💡'),
    Category(id: 'expense_entertainment', name: 'Hiburan', icon: '🎬'),
    Category(id: 'expense_health', name: 'Kesehatan', icon: '💊'),
    Category(id: 'expense_transport', name: 'Transportasi', icon: '🚗'),
    Category(id: 'expense_education', name: 'Pendidikan', icon: '📚'),
    Category(id: 'expense_shopping', name: 'Belanja', icon: '🛒'),
    Category(id: 'expense_other', name: 'Lainnya', icon: '📋'),
  ];

  static List<Category> defaultIncomeCategories = [
    Category(id: 'income_salary', name: 'Gaji', icon: '💰'),
    Category(id: 'income_bonus', name: 'Bonus', icon: '🎁'),
    Category(id: 'income_investment', name: 'Investasi', icon: '📈'),
    Category(id: 'income_gift', name: 'Hadiah', icon: '🎀'),
    Category(id: 'income_other', name: 'Lainnya', icon: '📋'),
  ];

  static Category getById(String id, TransactionType type) {
    // This will be implemented in the CategoryRepository
    return type == TransactionType.expense 
        ? defaultExpenseCategories.firstWhere(
            (category) => category.id == id,
            orElse: () => defaultExpenseCategories.last,
          )
        : defaultIncomeCategories.firstWhere(
            (category) => category.id == id,
            orElse: () => defaultIncomeCategories.last,
          );
  }
  
  // Common emoji icons for category selection
  static const List<String> availableIcons = [
    '🍔', '🏠', '💡', '🎬', '💊', '🚗', '📚', '🛒', '📋',
    '💰', '🎁', '📈', '🎀', '🛍️', '✈️', '🏥', '🏫', '🏢',
    '🎮', '🎵', '📱', '💻', '👕', '👟', '💄', '🧴', '🍹',
    '🍕', '🍣', '🍦', '🍷', '☕', '🍳', '🥗', '🍲', '🥪',
  ];
}
