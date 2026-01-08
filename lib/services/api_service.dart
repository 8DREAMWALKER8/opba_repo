import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opba_app/models/account_model.dart';

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

  // hesap endpoint'leri
  Future<List<dynamic>> getAccounts() async {
    final resp = await get('/accounts');
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
  Future<dynamic> getTransactions({String? accountId}) async {
    final endpoint = accountId != null
        ? '/transactions?accountId=$accountId'
        : '/transactions';
    return get(endpoint);
  }

  Future<dynamic> getTransactionSummary() async {
    return get('/transactions/summary');
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
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
