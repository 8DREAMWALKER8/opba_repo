import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opba_app/models/account_model.dart';
import 'package:opba_app/models/interest_rate_model.dart';
import 'package:opba_app/models/loan_rate_model.dart';

class ApiService {
  // base url
  static const String baseUrl = 'http://localhost:5001';

  final _storage = const FlutterSecureStorage();

  // kimlik doğrulama token'ı al
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // headers'ı al
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // generic get isteği
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow; // server hatasıysa olduğu gibi yukarı fırlat
    } catch (e) {
      // burada gerçek network/parsing vb kalır
      throw Exception('Network error');
    }
  }

  // generic post isteği
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on ApiException {
      debugPrint('ApiException in POST $endpoint');
      rethrow; // server hatasıysa olduğu gibi yukarı fırlat
    } catch (e) {
      // burada gerçek network/parsing vb kalır
      throw Exception('Network error');
    }
  }

  // generic put isteği
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow; // server hatasıysa olduğu gibi yukarı fırlat
    } catch (e) {
      // burada gerçek network/parsing vb kalır
      throw Exception('Network error');
    }
  }

  // generic patch isteği
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow; // server hatasıysa olduğu gibi yukarı fırlat
    } catch (e) {
      // burada gerçek network/parsing vb kalır
      throw Exception('Network error');
    }
  }

  // generic delete isteği
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow; // server hatasıysa olduğu gibi yukarı fırlat
    } catch (e) {
      // burada gerçek network/parsing vb kalır
      throw Exception('Network error');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Backend: { ok:false, error:"..." } veya { ok:false, message:"..." } vb.
    String message;

    if (body is Map) {
      message =
          (body['error'] ?? body['message'] ?? body['detail'] ?? body['msg'])
                  ?.toString() ??
              (response.body.isNotEmpty ? response.body : null) ??
              (response.reasonPhrase ?? 'Server error');
    } else {
      message = (response.body.isNotEmpty ? response.body : null) ??
          (response.reasonPhrase ?? 'Server error');
    }
    debugPrint(
        'API Error ${response.statusCode}: $message'); // Hata mesajını konsola yazdır
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await get('/users/me');
    return Map<String, dynamic>.from(res as Map);
  }

  // kimlik doğrulama endpoint'leri
  Future<dynamic> login(String emailOrUsername, String password) async {
    return post('/users/login/step1', {
      'email': emailOrUsername,
      'password': password,
    });
  }

  Future<dynamic> verifySecurityQuestion(
      String challengeToken, String securityAnswer) async {
    return post('/users/login/step2', {
      'userId': challengeToken,
      'securityAnswer': securityAnswer,
    });
  }

  Future<dynamic> register(Map<String, dynamic> userData) async {
    return post('/users/register', userData);
  }

  Future<dynamic> getSecurityQuestions({String lang = 'tr'}) async {
    return get('/users/security-questions?lang=$lang');
  }

  /// PATCH /accounts/:id  (update)
  Future<Map<String, dynamic>> patchAccount(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await patch('/accounts/$id', data);

    if (resp is Map && resp['ok'] == true && resp['account'] is Map) {
      return Map<String, dynamic>.from(resp['account'] as Map);
    }

    throw ApiException('Account update failed', statusCode: 400);
  }

  // hesap endpoint'leri
  Future<List<dynamic>> getAccounts({required String currency}) async {
    final resp = await get(
      currency != null && currency.isNotEmpty
          ? '/accounts?currency=$currency'
          : '/accounts',
    );
    debugPrint('account response ' + resp.toString());
    if (resp is Map && resp['ok'] == true) {
      return (resp['accounts'] as List?) ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> data) async {
    final resp = await post('/accounts', data);

    if (resp is Map && resp['ok'] == true && resp['account'] is Map) {
      return Map<String, dynamic>.from(resp['account'] as Map);
    }

    throw ApiException('Account create failed', statusCode: 400);
  }

  Future<Map<String, dynamic>> deactivateAccount(String id) async {
    final resp = await delete('/accounts/$id');
    if (resp is Map && resp['ok'] == true) {
      return Map<String, dynamic>.from(resp['account'] as Map);
    }
    throw ApiException('Account deactivate failed', statusCode: 400);
  }

  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> data) async {
    final resp = await post('/transactions', data);

    if (resp is Map && resp['ok'] == true && resp['transaction'] is Map) {
      return Map<String, dynamic>.from(resp['transaction'] as Map);
    }

    throw ApiException('Transaction create failed', statusCode: 400);
  }

  Future<Map<String, dynamic>> patchTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await patch('/transactions/$id', data);

    if (resp is Map && resp['ok'] == true && resp['transaction'] is Map) {
      return Map<String, dynamic>.from(resp['transaction'] as Map);
    }

    throw ApiException('Transaction update failed', statusCode: 400);
  }

  // işlem endpoint'leri
  Future<dynamic> getTransactions({String? accountId, String? currency}) async {
    debugPrint('currency in ApiService getTransactions: $currency');
    final endpoint = accountId != null
        ? '/transactions?currency=${currency ?? ''}&accountId=$accountId'
        : '/transactions?currency=${currency ?? ''}';
    return get(endpoint);
  }

  Future<dynamic> getTransactionSummary() async {
    return get('/transactions/summary');
  }

  // =========================
// Interest Rates
// GET /api/interest-rates?loan_type=...&currency=...&term_months=...&bank_name=...&sort=asc|desc
// =========================
  Future<Map<String, dynamic>> getInterestRates({
    String? loanType,
    String? currency,
    int? termMonths,
    String? bankName,
    String sort = 'asc',
  }) async {
    final query = <String, String>{};

    if (loanType != null && loanType.trim().isNotEmpty) {
      query['loan_type'] = loanType.trim();
    }
    if (currency != null && currency.trim().isNotEmpty) {
      query['currency'] = currency.trim();
    }
    if (termMonths != null && termMonths > 0) {
      query['term_months'] = termMonths.toString();
    }
    if (bankName != null && bankName.trim().isNotEmpty) {
      query['bank_name'] = bankName.trim();
    }
    if (sort.trim().isNotEmpty) {
      query['sort'] = sort.trim();
    }

    final uri = Uri.parse('$baseUrl/api/interest-rates').replace(
      queryParameters: query.isEmpty ? null : query,
    );

    // ApiService içindeki _getHeaders() kullanmak için doğrudan get() yerine küçük bir override:
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    final resp = _handleResponse(response);
    if (resp is Map && resp['ok'] == true) {
      debugPrint(response.body);
      return Map<String, dynamic>.from(resp);
    }

    throw ApiException('INTEREST_RATES_ERROR', statusCode: 400);
  }

  // GET /interest-rates/banks/:bankName/terms?loan_type=...&currency=...
  Future<Map<String, dynamic>> getBankTerms(
    String bankName, {
    String loanType = 'consumer',
    String currency = 'TRY',
  }) async {
    final endpoint =
        '/interest-rates/banks/${Uri.encodeComponent(bankName)}/terms?loan_type=$loanType&currency=$currency';

    final resp = await get(endpoint);

    if (resp is Map && resp['ok'] == true) {
      return Map<String, dynamic>.from(resp as Map);
    }
    throw ApiException('TERMS_NOT_FOUND', statusCode: 404);
  }

  // =========================
  // Loan Calc
  // POST /loan/calc
  // =========================
  Future<Map<String, dynamic>> calcLoan({
    required String bankName,
    String loanType = 'consumer',
    String currency = 'TRY',
    required int termMonths,
    required double principal,
  }) async {
    final resp = await post('/api/loan/calc', {
      'bank_name': bankName,
      'loan_type': loanType,
      'currency': currency,
      'term_months': termMonths,
      'principal': principal,
    });

    if (resp is Map && resp['ok'] == true) {
      return Map<String, dynamic>.from(resp as Map);
    }
    throw ApiException('CALC_ERROR', statusCode: 400);
  }

  // İstersen model ile çağırmak için helper:
  Future<Map<String, dynamic>> calcLoanFromInput(LoanCalcInput input) {
    return calcLoan(
      bankName: input.bankName,
      loanType: input.loanType,
      currency: input.currency,
      termMonths: input.termMonths,
      principal: input.principal,
    );
  }

  // bütçe endpoint'leri
  Future<dynamic> getBudgets() async {
    return get('/budgets');
  }

  Future<dynamic> createBudget(Map<String, dynamic> budgetData) async {
    return post('/budgets', budgetData);
  }

  // kredi endpoint'leri
  Future<dynamic> getLoanRates() async {
    return get('/loans/rates');
  }

  Future<dynamic> compareLoanRates() async {
    return get('/loans/compare');
  }

  // currency endpoint'leri
  Future<dynamic> getCurrencyRates() async {
    return get('/currency/rates');
  }

  Future<dynamic> convertCurrency(double amount, String from, String to) async {
    return get('/currency/convert?amount=$amount&from=$from&to=$to');
  }

  Future<Map<String, dynamic>> deleteTransaction(String id) async {
    final resp = await delete('/transactions/$id');

    if (resp is Map && resp['ok'] == true && resp['transaction'] is Map) {
      return Map<String, dynamic>.from(resp['transaction'] as Map);
    }

    final message = (resp is Map && resp['message'] != null)
        ? resp['message'].toString()
        : null;

    throw ApiException(message ?? 'Transaction delete failed', statusCode: 400);
  }

  Future<dynamic> patchProfile(
      {String? fullName,
      String? email,
      String? phone,
      String? password,
      String? currentPassword,
      String? securityQuestionId,
      String? securityAnswer,
      String? newAnswer,
      String? language,
      String? currency,
      String? theme}) async {
    final body = <String, dynamic>{};

    // Backend PATCH /me/profile => username/email/phone
    if (fullName != null && fullName.trim().isNotEmpty) {
      body['username'] = fullName.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }
    if (phone != null && phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password.trim();
    }
    if (currentPassword != null && currentPassword.trim().isNotEmpty) {
      body['currentPassword'] = currentPassword.trim();
    }
    if (securityQuestionId != null && securityQuestionId.trim().isNotEmpty) {
      body['securityQuestionId'] = securityQuestionId.trim();
    }
    if (securityAnswer != null && securityAnswer.trim().isNotEmpty) {
      body['securityAnswer'] = securityAnswer.trim();
    }
    if (newAnswer != null && newAnswer.trim().isNotEmpty) {
      body['newAnswer'] = newAnswer.trim();
    }
    if (language != null && language.trim().isNotEmpty) {
      body['language'] = language.trim();
    }
    if (currency != null && currency.trim().isNotEmpty) {
      body['currency'] = currency.trim();
    }
    if (theme != null && theme.trim().isNotEmpty) {
      body['theme'] = theme.trim();
    }

    if (body.isEmpty) {
      // Hiç alan gönderilmezse backend'e gereksiz istek atmayalım
      return {'ok': true, 'message': 'No changes'};
    }

    debugPrint('Patching profile with body: $body');
    return patch('/users/me/update', body);
  }

  Future<BankTermsResponse?> getInterestRateBankTerms(
      {required String bankName,
      required String loanType,
      required String currency}) async {}
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
