import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

final box = Hive.box<Transaction>('transactions');
String selectedCurrency = 'INR'; // डिफ़ॉल्ट करेंसी

int totalBalance() {
  var transactions = box.values.toList();
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? int.parse(t.amount) : -int.parse(t.amount)));
}

int totalIncome() {
  var transactions = box.values.toList();
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? int.parse(t.amount) : 0));
}

int totalFilteredIncome(List<Transaction> transactions) {
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? int.parse(t.amount) : 0));
}

int totalExpense() {
  var transactions = box.values.toList();
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? 0 : int.parse(t.amount)));
}

int totalFilteredExpense(List<Transaction> transactions) {
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? 0 : int.parse(t.amount)));
}

List<Transaction> getTransactionToday(DateTime selectedDay) {
  return box.values.where((t) =>
  t.createAt.year == selectedDay.year &&
      t.createAt.month == selectedDay.month &&
      t.createAt.day == selectedDay.day).toList();
}

List<Transaction> getExpenseTransactionToday() {
  DateTime date = DateTime.now();
  return box.values.where((t) =>
  t.category.type == 'Expense' &&
      t.createAt.year == date.year &&
      t.createAt.month == date.month &&
      t.createAt.day == date.day).toList();
}

List<Transaction> getTransactionWeek(DateTime selectedDate) {
  return box.values.where((t) => isWithinCurrentWeek(t.createAt, selectedDate)).toList()
    ..sort((a, b) => a.createAt.compareTo(b.createAt));
}

bool isWithinCurrentWeek(DateTime date, DateTime selectedDate) {
  var startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  var endOfWeek = startOfWeek.add(const Duration(days: 6));
  return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && date.isBefore(endOfWeek);
}

List<Transaction> getTransactionMonth(DateTime selectedDate) {
  return box.values.where((t) => t.createAt.year == selectedDate.year && t.createAt.month == selectedDate.month).toList()
    ..sort((a, b) => a.createAt.compareTo(b.createAt));
}

List<Transaction> getTransactionYear(DateTime selectedDate) {
  return box.values.where((t) => t.createAt.year == selectedDate.year).toList()
    ..sort((a, b) => a.createAt.compareTo(b.createAt));
}

int totalChart(List<Transaction> transactions) {
  return transactions.fold(0, (sum, t) => sum + (t.type == 'Income' ? int.parse(t.amount) : -int.parse(t.amount)));
}

List<int> time(List<Transaction> transactions, bool hour, bool day, bool month) {
  List<int> totals = [];
  Set<String> timeGroups = {};

  for (var t in transactions) {
    String key = hour
        ? '${t.createAt.year}-${t.createAt.month}-${t.createAt.day}-${t.createAt.hour}'
        : day
        ? '${t.createAt.year}-${t.createAt.month}-${t.createAt.day}'
        : '${t.createAt.year}-${t.createAt.month}';

    if (!timeGroups.contains(key)) {
      timeGroups.add(key);
      totals.add(totalChart(transactions.where((tx) =>
      hour ? tx.createAt.hour == t.createAt.hour :
      day ? tx.createAt.day == t.createAt.day :
      tx.createAt.month == t.createAt.month).toList()));
    }
  }
  return totals;
}

String formatCurrency(int value) {
  final format = NumberFormat.currency(symbol: '', decimalDigits: 0, locale: 'en_US');
  return '${getCurrencySymbol(selectedCurrency)}${format.format(value)}';
}

String getCurrencySymbol(String currencyCode) {
  switch (currencyCode) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'INR':
      return '₹';
    case 'JPY':
      return '¥';
    case 'AUD':
      return 'A\$';
    default:
      return '$currencyCode ';
  }
}

String getFormattedDate(int index, DateTime selectedDate) {
  switch (index) {
    case 0:
      return DateFormat('MMM dd, yyyy').format(selectedDate);
    case 1:
      final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('dd').format(startOfWeek)}-${DateFormat('dd').format(endOfWeek)} ${DateFormat('MMM, yyyy').format(selectedDate)}';
    case 2:
      return DateFormat('MMM yyyy').format(selectedDate);
    case 3:
      return DateFormat('yyyy').format(selectedDate);
    default:
      return '';
  }
}
