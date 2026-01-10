// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/interest_rate_model.dart';

// class InterestRatesProvider extends ChangeNotifier {
//   final ApiService _api;

//   InterestRatesProvider({ApiService? api}) : _api = api ?? ApiService();

//   bool _isLoading = false;
//   String? _error;

//   InterestRatesResponse? _listResponse;
//   BankTermsResponse? _bankTermsResponse;

//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   InterestRatesResponse? get listResponse => _listResponse;
//   BankTermsResponse? get bankTermsResponse => _bankTermsResponse;

//   List<InterestRateItem> get items => _listResponse?.items ?? [];
//   List<InterestRateChartPoint> get chart => _listResponse?.chart ?? [];

//   List<BankTermItem> get terms => _bankTermsResponse?.terms ?? [];

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   Future<void> fetchInterestRates({
//     String? loanType,
//     String? currency,
//     int? termMonths,
//     String? bankName,
//     String sort = 'asc',
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _listResponse = (await _api.getInterestRates(
//         loanType: loanType,
//         currency: currency,
//         termMonths: termMonths,
//         bankName: bankName,
//         sort: sort,
//       )) as InterestRatesResponse?;
//       _isLoading = false;
//       notifyListeners();
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//     } catch (_) {
//       _error = 'INTEREST_RATES_ERROR';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchBankTerms({
//     required String bankName,
//     String loanType = 'consumer',
//     String currency = 'TRY',
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _bankTermsResponse = await _api.getInterestRateBankTerms(
//         bankName: bankName,
//         loanType: loanType,
//         currency: currency,
//       );
//       _isLoading = false;
//       notifyListeners();
//     } on ApiException catch (e) {
//       _error = e.message; // TERMS_NOT_FOUND vs
//       _isLoading = false;
//       notifyListeners();
//     } catch (_) {
//       _error = 'TERMS_ERROR';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
