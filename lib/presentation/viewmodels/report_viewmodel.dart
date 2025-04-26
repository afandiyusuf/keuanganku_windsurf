// lib/presentation/viewmodels/report_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart' as entities;
import '../../domain/usecases/get_filtered_transactions.dart';
import '../../domain/usecases/get_categories.dart';

class ReportViewModel extends ChangeNotifier {
  final GetFilteredTransactions _getFilteredTransactions;
  final GetCategories _getCategories;

  ReportViewModel({
    required GetFilteredTransactions getFilteredTransactions,
    required GetCategories getCategories,
  })  : _getFilteredTransactions = getFilteredTransactions,
        _getCategories = getCategories;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<entities.Category> _expenseCategories = [];
  List<entities.Category> get expenseCategories => _expenseCategories;

  List<entities.Category> _incomeCategories = [];
  List<entities.Category> get incomeCategories => _incomeCategories;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  TransactionType? _selectedType;
  TransactionType? get selectedType => _selectedType;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Summary data
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  // Category summary
  Map<String, double> get expenseByCategoryMap {
    final result = <String, double>{};
    
    for (final transaction in _transactions.where((t) => t.type == TransactionType.expense)) {
      final categoryId = transaction.categoryId;
      result[categoryId] = (result[categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  Map<String, double> get incomeByCategoryMap {
    final result = <String, double>{};
    
    for (final transaction in _transactions.where((t) => t.type == TransactionType.income)) {
      final categoryId = transaction.categoryId;
      result[categoryId] = (result[categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  // Initialize with default filter (current month)
  Future<void> initialize() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    await setDateRange(firstDayOfMonth, now);
    await loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _expenseCategories = await _getCategories(entities.CategoryType.expense);
      _incomeCategories = await _getCategories(entities.CategoryType.income);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> applyFilters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filter = TransactionFilter(
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
        categoryId: _selectedCategoryId,
      );

      _transactions = await _getFilteredTransactions(filter);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    await applyFilters();
  }

  Future<void> setTransactionType(TransactionType? type) async {
    _selectedType = type;
    // Reset category if type changes
    if (type != null) {
      _selectedCategoryId = null;
    }
    await applyFilters();
  }

  Future<void> setCategoryId(String? categoryId) async {
    _selectedCategoryId = categoryId;
    await applyFilters();
  }

  Future<void> resetFilters() async {
    _selectedType = null;
    _selectedCategoryId = null;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    await applyFilters();
  }

  // Helper method to get category name by ID
  String getCategoryName(String categoryId) {
    if (categoryId.startsWith('expense_')) {
      final category = _expenseCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => entities.Category(id: categoryId, name: 'Unknown', icon: '❓'),
      );
      return category.name;
    } else {
      final category = _incomeCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => entities.Category(id: categoryId, name: 'Unknown', icon: '❓'),
      );
      return category.name;
    }
  }

  // Helper method to get category icon by ID
  String getCategoryIcon(String categoryId) {
    if (categoryId.startsWith('expense_')) {
      final category = _expenseCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => entities.Category(id: categoryId, name: 'Unknown', icon: '❓'),
      );
      return category.icon;
    } else {
      final category = _incomeCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => entities.Category(id: categoryId, name: 'Unknown', icon: '❓'),
      );
      return category.icon;
    }
  }
}
