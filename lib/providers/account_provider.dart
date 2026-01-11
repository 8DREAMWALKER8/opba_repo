import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opba_app/services/api_service.dart';

import '../models/account_model.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = <Account>[];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _storageKeyForAccount(Account acc) {
    final cn = (acc.cardNumber).trim();
    if (cn.isNotEmpty) return 'acct_card_cn_$cn';

    final id = (acc.id ?? '').trim();
    if (id.isNotEmpty) return 'acct_card_id_$id';

    return 'acct_card_unknown';
  }

  Future<void> _writeCardData(Account acc, Map<String, dynamic> data) async {
    final key = _storageKeyForAccount(acc);
    await _storage.write(key: key, value: jsonEncode(data));
  }

  Future<void> fetchAccounts(String? currency) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final raw = await api.getAccounts(currency: currency!);

      final accounts =
          raw.whereType<Map<String, dynamic>>().map(Account.fromJson).toList();

      _accounts = accounts;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Hesaplar yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final deletedJson = await api.deactivateAccount(accountId);

      final deletedId =
          (deletedJson['id'] ?? deletedJson['_id'] ?? accountId).toString();

      _accounts.removeWhere((a) => a.id == deletedId);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Hesap silinirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAccount({
    required String bankName,
    required String cardHolderName,
    required String cardNumber,
    required String description,
    double balance = 0.0,
    String currency = 'TRY',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final payload = <String, dynamic>{
        'bankName': bankName.trim(),
        'cardHolderName': cardHolderName.trim(),
        'cardNumber': cardNumber.trim(),
        'balance': balance,
        'currency': currency,
        'description': description.trim(),
        'source': 'manual',
      };

      final createdJson = await api.createAccount(payload);
      final created = Account.fromJson(createdJson);

      final uiAccount = created.copyWith(
        cardHolderName: cardHolderName.trim(),
        cardNumber: cardNumber.trim(),
        description: description.trim(),
        lastSyncAt: DateTime.now(),
      );

      await _writeCardData(uiAccount, {
        'cardNumber': uiAccount.cardNumber,
        'cardHolderName': uiAccount.cardHolderName,
        'expiryDate': uiAccount.expiryDate,
        'description': uiAccount.description,
      });

      _accounts.insert(0, uiAccount);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Hesap eklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(Account account) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = (account.id ?? '').toString().trim();
      if (id.isEmpty) {
        _error = 'Account id bulunamadı.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final cardNumber = (account.cardNumber ?? '').replaceAll(' ', '').trim();
      if (cardNumber.isEmpty || !RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
        _error = 'Kart numarası geçersiz.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final payload = <String, dynamic>{
        'bankName': account.bankName.trim(),
        'cardHolderName': (account.cardHolderName ?? '').trim(),
        'cardNumber': cardNumber,
        'description': (account.description ?? '').trim(),
        'balance': account.balance,
        'currency': account.currency,
      };

      final api = ApiService();

      final updatedJson = await api.patchAccount(id, payload);
      final updated = Account.fromJson(updatedJson);

      final index = _accounts.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _accounts[index] = updated;
      } else {
        _accounts.insert(0, updated);
      }

      await _writeCardData(updated, {
        'cardNumber': updated.cardNumber,
        'cardHolderName': updated.cardHolderName,
        'expiryDate': updated.expiryDate,
        'description': updated.description,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Hesap güncellenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
