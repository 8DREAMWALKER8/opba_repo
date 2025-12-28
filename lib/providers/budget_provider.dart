import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class BudgetProvider extends ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BudgetProvider() {
    _loadDemoBudgets();
  }

  void _loadDemoBudgets() {
    _budgets = [
      Budget(
        id: 'budget_1',
        userId: 'user_123',
        category: TransactionCategory.market,
        limitAmount: 3000,
        spentAmount: 850,
        month: '2025-11',
      ),
      Budget(
        id: 'budget_2',
        userId: 'user_123',
        category: TransactionCategory.entertainment,
        limitAmount: 1000,
        spentAmount: 53.95,
        month: '2025-11',
      ),
      Budget(
        id: 'budget_3',
        userId: 'user_123',
        category: TransactionCategory.food,
        limitAmount: 2000,
        spentAmount: 150,
        month: '2025-11',
      ),
    ];
    notifyListeners();
  }

  Budget? getBudgetByCategory(TransactionCategory category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (e) {
      return null;
    }
  }

  Budget? getBudgetForCategory(TransactionCategory category) {
    return getBudgetByCategory(category);
  }

  Future<bool> setBudget({
    required TransactionCategory category,
    required double limitAmount,
  }) async {
    return createBudget(category: category, limitAmount: limitAmount);
  }

  Future<void> fetchBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Bütçeler yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget({
    required TransactionCategory category,
    required double limitAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // bu kategori için zaten bütçe olup olmadığını kontrol et
      final existingIndex = _budgets.indexWhere((b) => b.category == category);

      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      if (existingIndex != -1) {
        // mevcut bütçeyi güncelle
        _budgets[existingIndex] = _budgets[existingIndex].copyWith(
          limitAmount: limitAmount,
        );
      } else {
        // yeni bütçe oluştur
        final newBudget = Budget(
          id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user_123',
          category: category,
          limitAmount: limitAmount,
          spentAmount: 0,
          month: month,
        );
        _budgets.add(newBudget);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Bütçe oluşturulurken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(Budget budget) async {
    try {
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    try {
      _budgets.removeWhere((b) => b.id == budgetId);
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
