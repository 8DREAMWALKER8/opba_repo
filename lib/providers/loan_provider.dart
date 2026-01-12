import 'package:flutter/material.dart';
import 'package:opba_app/models/loan_rate_model.dart';
import '../services/api_service.dart';

class LoanProvider extends ChangeNotifier {
  final ApiService _api;

  LoanProvider(this._api);

  bool _isLoadingRates = false;
  String? _errorRates;
  List<LoanRateItem> _rates = [];

  bool get isLoadingRates => _isLoadingRates;
  String? get errorRates => _errorRates;
  List<LoanRateItem> get rates => _rates;

  // calc
  bool _isCalculating = false;
  String? _calcError;
  LoanCalcResponse? _calcResponse;

  bool get isCalculating => _isCalculating;
  String? get calcError => _calcError;
  LoanCalcResponse? get calcResponse => _calcResponse;

  Future<void> fetchRates({
    String loanType = 'consumer',
    String currency = 'TRY',
    int? termMonths,
    String sort = 'asc',
  }) async {
    _isLoadingRates = true;
    _errorRates = null;
    notifyListeners();

    try {
      final res = await _api.getInterestRates(
        loanType: loanType,
        currency: currency,
        termMonths: termMonths,
        sort: sort,
      );

      final items = (res['items'] as List?) ?? [];
      _rates = items
          .map(
              (e) => LoanRateItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      _isLoadingRates = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorRates = e.message;
      _isLoadingRates = false;
      notifyListeners();
    } catch (_) {
      _errorRates = 'Faiz oranları alınamadı.';
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  LoanRateItem? get bestRate {
    if (_rates.isEmpty) return null;
    _rates.sort((a, b) => a.monthlyRatePercent.compareTo(b.monthlyRatePercent));
    return _rates.first;
  }

  Future<bool> calculate(LoanCalcInput input) async {
    _isCalculating = true;
    _calcError = null;
    _calcResponse = null;
    notifyListeners();

    try {
      final res = await _api.calcLoanFromInput(input);
      _calcResponse = LoanCalcResponse.fromJson(res);
      _isCalculating = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _calcError = e.message;
      _isCalculating = false;
      notifyListeners();
      return false;
    } catch (_) {
      _calcError = 'Hesaplama yapılamadı.';
      _isCalculating = false;
      notifyListeners();
      return false;
    }
  }
}
