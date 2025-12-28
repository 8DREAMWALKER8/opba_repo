import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  List<CategorySummary> get categorySummaries => getCategorySummary();

  TransactionProvider() {
    _loadDemoTransactions();
  }

  void _loadDemoTransactions() {
    _transactions = [
      Transaction(
        id: 'tx_1',
        userId: 'user_123',
        accountId: 'acc_1',
        merchant: 'SonyPlaystation',
        description: 'FIFA 2023 Game',
        amount: 53.95,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: DateTime(2025, 11, 18),
      ),
      Transaction(
        id: 'tx_2',
        userId: 'user_123',
        accountId: 'acc_2',
        merchant: 'Para Transferi',
        description: 'Mart Ayı Maaş',
        amount: 2500.00,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(2025, 11, 7),
      ),
      Transaction(
        id: 'tx_3',
        userId: 'user_123',
        accountId: 'acc_1',
        merchant: 'Kahve Dükkanı',
        description: 'Kahve Dünyası',
        amount: 150.00,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2025, 11, 10),
      ),
      Transaction(
        id: 'tx_4',
        userId: 'user_123',
        accountId: 'acc_1',
        merchant: 'Migros',
        description: 'Haftalık alışveriş',
        amount: 850.00,
        type: TransactionType.expense,
        category: TransactionCategory.market,
        date: DateTime(2025, 11, 5),
      ),
      Transaction(
        id: 'tx_5',
        userId: 'user_123',
        accountId: 'acc_2',
        merchant: 'İGDAŞ',
        description: 'Doğalgaz faturası',
        amount: 320.00,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: DateTime(2025, 11, 3),
      ),
    ];
    notifyListeners();
  }

  // işlemleri kategoriye göre görüntüle
  List<Transaction> getByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  // pasta grafiği için kategori özeti alma
  List<CategorySummary> getCategorySummary() {
    final Map<TransactionCategory, double> categoryTotals = {};
    double totalExpenses = 0;

    for (final tx in _transactions.where((t) => t.isExpense)) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
      totalExpenses += tx.amount;
    }

    final summaries = <CategorySummary>[];
    categoryTotals.forEach((category, amount) {
      summaries.add(CategorySummary(
        category: category,
        amount: amount,
        percentage: totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0,
      ));
    });

    // miktara göre azalan sırada sırala
    summaries.sort((a, b) => b.amount.compareTo(a.amount));
    return summaries;
  }

  // toplam gider'i getir
  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // toplam geliri getir
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // kategori toplamını al
  double getCategoryTotal(TransactionCategory category) {
    return _transactions
        .where((t) => t.category == category && t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'İşlemler yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      _transactions.insert(0, transaction);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
