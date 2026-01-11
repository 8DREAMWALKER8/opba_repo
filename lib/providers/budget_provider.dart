import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class BudgetProvider extends ChangeNotifier {
  final ApiService _api;
  BudgetProvider(this._api);

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  String get selectedPeriodLabel =>
      '${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}';

  // ✅ Burada her türlü inputu int’e çevirip garanti altına alıyoruz
  void setSelectedPeriod({required dynamic year, required dynamic month}) {
    final y = (year is int) ? year : int.tryParse(year.toString());
    final m = (month is int) ? month : int.tryParse(month.toString());

    if (y == null || m == null) return;

    _selectedYear = y;
    _selectedMonth = m.clamp(1, 12);
    notifyListeners();
  }

  Budget? getBudgetForCategory(TransactionCategory category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchBudgets({int? year, int? month, String? currency}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final y = year ?? _selectedYear;
    final m = month ?? _selectedMonth;

    // currency paramı verilmediyse uygulama ayarından al
    // (AppProvider yoksa burayı AuthProvider'a göre değiştir)
    final cur = (currency?.trim().isNotEmpty == true)
        ? currency!.trim().toUpperCase()
        : 'TRY';

    try {
      final resp = await _api.getBudgets(year: y, month: m, currency: cur);

      List list;
      if (resp is Map && resp['ok'] == true) {
        list = (resp['budgets'] as List?) ?? [];
      } else if (resp is List) {
        list = resp;
      } else {
        list = [];
      }

      _budgets = list
          .whereType<Map>()
          .map((x) => Budget.fromJson(Map<String, dynamic>.from(x)))
          .toList();

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _error = 'Bütçeler yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setBudget({
    required TransactionCategory category,
    required double limitAmount,
    required int year,
    required int month,
    required String currency,
  }) async {
    return createBudget(
      category: category,
      limitAmount: limitAmount,
      year: year,
      month: month,
      currency: currency,
    );
  }

  Future<bool> createBudget({
    required TransactionCategory category,
    required double limitAmount,
    required int year,
    required int month,
    required String currency,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'category': category.name,
        'limitAmount': limitAmount,
        'year': year,
        'month': month,
        'currency': currency,
      };

      final resp = await _api.createBudget(payload);

      Budget? created;
      if (resp is Map && resp['ok'] == true) {
        if (resp['budget'] is Map) {
          created = Budget.fromJson(Map<String, dynamic>.from(resp['budget']));
        } else if (resp['budgets'] is List) {
          final list = (resp['budgets'] as List).whereType<Map>().toList();
          _budgets = list
              .map((x) => Budget.fromJson(Map<String, dynamic>.from(x)))
              .toList();
        }
      }

      if (created != null) {
        final idx = _budgets.indexWhere((b) => b.category == created!.category);
        if (idx != -1)
          _budgets[idx] = created;
        else
          _budgets.add(created);
      } else {
        // create sonrası item dönmüyorsa: tekrar çek
        await fetchBudgets(year: year, month: month);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Bütçe oluşturulurken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget({
    required String budgetId,
    int? year,
    int? month,
    String? currency,
  }) async {
    _error = null;
    notifyListeners();

    // UI optimistik silme yapacak; burada sadece API + refetch
    try {
      final resp = await _api.deleteBudget(budgetId);

      final ok = (resp is Map) ? (resp['ok'] == true) : true;
      if (!ok) {
        _error = (resp is Map && resp['message'] != null)
            ? resp['message'].toString()
            : 'Bütçe silinemedi.';
        notifyListeners();
        return false;
      }

      // mevcut seçili dönemi koruyarak tekrar çek
      await fetchBudgets(
        year: year ?? _selectedYear,
        month: month ?? _selectedMonth,
        currency: currency,
      );

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Bütçe silinirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
