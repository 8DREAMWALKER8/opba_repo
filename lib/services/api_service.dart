import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // base url
  static const String baseUrl = 'http://localhost:5000/api';

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
    } catch (e) {
      throw Exception('Network error: $e');
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
    } catch (e) {
      throw Exception('Network error: $e');
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
    } catch (e) {
      throw Exception('Network error: $e');
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
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // yanıtı işle
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(body['message'] ?? 'Server error');
    }
  }

  // kimlik doğrulama endpoint'leri
  Future<dynamic> login(String emailOrUsername, String password) async {
    return post('/auth/login', {
      'email': emailOrUsername,
      'password': password,
    });
  }

  Future<dynamic> verifySecurityQuestion(String userId, String answer) async {
    return post('/auth/verify-security', {
      'userId': userId,
      'answer': answer,
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
}
