import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

    // Backend genelde { ok:false, message:"..." } döndürüyor
    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : (response.reasonPhrase ?? 'Server error');

    // Status code'u da taşımak istersen:
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await get('/me');
    return Map<String, dynamic>.from(res as Map);
  }

  // kimlik doğrulama endpoint'leri
  Future<dynamic> login(String emailOrUsername, String password) async {
    return post('/auth/login', {
      'email': emailOrUsername,
      'password': password,
    });
  }

  Future<dynamic> verifySecurityQuestion(
      String challengeToken, String securityAnswer) async {
    return post('/auth/login/verify-question', {
      'challengeToken': challengeToken,
      'securityAnswer': securityAnswer,
    });
  }

  Future<dynamic> register(Map<String, dynamic> userData) async {
    return post('/auth/register', userData);
  }

  // hesap endpoint'leri
  Future<dynamic> getAccounts() async {
    return get('/accounts');
  }

  Future<dynamic> addAccount(Map<String, dynamic> accountData) async {
    return post('/accounts', accountData);
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

  Future<dynamic> patchProfile(
      {String? fullName, String? email, String? phone}) async {
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

    if (body.isEmpty) {
      // Hiç alan gönderilmezse backend'e gereksiz istek atmayalım
      return {'ok': true, 'message': 'No changes'};
    }

    return patch('/me/profile', body);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
