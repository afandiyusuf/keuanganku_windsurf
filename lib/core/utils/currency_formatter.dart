// lib/core/utils/currency_formatter.dart

class CurrencyFormatter {
  static String format(double amount) {
    // Mengubah double menjadi string tanpa desimal
    String amountStr = amount.toStringAsFixed(0);
    
    // Menambahkan titik sebagai pemisah ribuan
    final result = StringBuffer();
    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(amountStr[i]);
    }
    
    return result.toString();
  }
  
  static String formatWithSymbol(double amount) {
    return 'Rp ${format(amount)}';
  }
}
