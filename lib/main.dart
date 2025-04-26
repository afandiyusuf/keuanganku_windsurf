// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'di/injection.dart' as di;
import 'app.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/viewmodels/transaction_viewmodel.dart';
import 'presentation/viewmodels/category_viewmodel.dart';
import 'presentation/viewmodels/report_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale data untuk format tanggal
  await initializeDateFormatting('id', null);
  
  // Initialize dependencies
  await di.initializeDependencies();
  
  runApp(const KeuanganKuApp());
}