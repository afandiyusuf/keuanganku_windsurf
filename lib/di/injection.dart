// lib/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/transaction_local_datasource.dart';
import '../data/datasources/category_local_datasource.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/usecases/add_transaction.dart';
import '../domain/usecases/delete_transaction.dart';
import '../domain/usecases/get_transactions.dart';
import '../domain/usecases/update_transaction.dart';
import '../domain/usecases/get_filtered_transactions.dart';
import '../domain/usecases/add_category.dart';
import '../domain/usecases/delete_category.dart';
import '../domain/usecases/get_categories.dart';
import '../domain/usecases/update_category.dart';
import '../presentation/viewmodels/transaction_viewmodel.dart';
import '../presentation/viewmodels/category_viewmodel.dart';
import '../presentation/viewmodels/report_viewmodel.dart';
import '../core/services/image_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  sl.registerLazySingleton<ImageService>(() => ImageService());

  // Data sources
  sl.registerSingleton<TransactionLocalDataSource>(
    TransactionLocalDataSourceImpl(sl()),
  );
  sl.registerSingleton<CategoryLocalDataSource>(
    CategoryLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(sl()),
  );
  sl.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(sl()),
  );

  // Use cases - Transaction
  sl.registerSingleton<GetTransactions>(GetTransactions(sl()));
  sl.registerSingleton<AddTransaction>(AddTransaction(sl()));
  sl.registerSingleton<UpdateTransaction>(UpdateTransaction(sl()));
  sl.registerSingleton<DeleteTransaction>(DeleteTransaction(sl()));
  sl.registerSingleton<GetFilteredTransactions>(GetFilteredTransactions(sl()));

  // Use cases - Category
  sl.registerSingleton<GetCategories>(GetCategories(sl()));
  sl.registerSingleton<AddCategory>(AddCategory(sl()));
  sl.registerSingleton<UpdateCategory>(UpdateCategory(sl()));
  sl.registerSingleton<DeleteCategory>(DeleteCategory(sl()));

  // View models
  sl.registerFactory<TransactionViewModel>(
    () => TransactionViewModel(
      getTransactions: sl(),
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );
  sl.registerFactory<CategoryViewModel>(
    () => CategoryViewModel(
      getCategories: sl(),
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );
  sl.registerFactory<ReportViewModel>(
    () => ReportViewModel(
      getFilteredTransactions: sl(),
      getCategories: sl(),
    ),
  );
}