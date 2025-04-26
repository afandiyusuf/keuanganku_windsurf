// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/injection.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/viewmodels/transaction_viewmodel.dart';
import 'presentation/viewmodels/category_viewmodel.dart';
import 'presentation/viewmodels/report_viewmodel.dart';

class KeuanganKuApp extends StatelessWidget {
  const KeuanganKuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<TransactionViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<CategoryViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ReportViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'KeuanganKu',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}