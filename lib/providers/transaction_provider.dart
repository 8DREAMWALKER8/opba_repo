import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opba_app/providers/account_provider.dart';
import 'package:opba_app/services/api_service.dart' hide ApiException;
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final _storage = const FlutterSecureStorage();
  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  List<CategorySummary> get categorySummaries => getCategorySummary();

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

  Future<void> fetchTransactions({String? accountId, String? currency}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final api = ApiService();
    try {
      final body =
          await api.getTransactions(accountId: accountId, currency: currency);

      final rawList = (body is Map && body['transactions'] is List)
          ? body['transactions'] as List
          : <dynamic>[];
      _transactions = rawList
          .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'İşlemler yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final api = ApiService();

    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null || userId.trim().isEmpty) {
        _error = 'Kullanıcı bilgisi bulunamadı.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      transaction = transaction.setUserId(userId);

      final payload = <String, dynamic>{
        'accountId': transaction.accountId,
        'type': transaction.type.name,
        'category': transaction.category.name,
        'amount': transaction.amount,
        'currency': transaction.currency,
        'description': (transaction.description ?? '').trim(),
        'occurredAt': transaction.date.toIso8601String(),
        if ((transaction.merchant ?? '').trim().isNotEmpty)
          'merchant': transaction.merchant!.trim(),
        'isRecurring': transaction.isRecurring,
      };

      final createdMap = await api.createTransaction(payload);

      final createdTx =
          Transaction.fromJson(Map<String, dynamic>.from(createdMap));

      _transactions.insert(0, createdTx);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'İşlem eklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final api = ApiService();

    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null || userId.trim().isEmpty) {
        _error = 'Kullanıcı bilgisi bulunamadı.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      transaction = transaction.setUserId(userId);

      final txId = (transaction.id ?? '').trim();
      if (txId.isEmpty) {
        _error = 'Transaction id bulunamadı.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final payload = <String, dynamic>{
        'accountId': transaction.accountId,
        'type': transaction.type.name,
        'category': transaction.category.name,
        'amount': transaction.amount,
        'currency': transaction.currency,
        'description': (transaction.description ?? '').trim(),
        'occurredAt': transaction.date.toIso8601String(),
      };

      final updatedMap = await api.patchTransaction(txId, payload);

      final updatedTx =
          Transaction.fromJson(Map<String, dynamic>.from(updatedMap));

      final index = _transactions.indexWhere((t) => t.id == updatedTx.id);
      if (index != -1) {
        _transactions[index] = updatedTx;
      } else {
        _transactions.insert(0, updatedTx);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'İşlem güncellenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final api = ApiService();

    try {
      if (id.trim().isEmpty) {
        _error = 'Transaction id bulunamadı.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await api.deleteTransaction(id);

      _transactions.removeWhere((t) => (t.id ?? '').toString() == id);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'İşlem silinirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
