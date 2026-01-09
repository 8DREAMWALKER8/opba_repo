import 'package:flutter/material.dart';
import 'package:opba_app/services/api_service.dart';
import '../models/account_model.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  String _cardKey(String iban) => 'acct_card_$iban';

  Future<void> fetchAccounts(currency) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('Fetching accounts from API...');
    try {
      final api = ApiService();

      final raw = await api.getAccounts(currency: currency); // List<dynamic>

      final accounts = raw
          .whereType<
              Map<String, dynamic>>() // Eğer API zaten Map döndürüyorsa direkt
          .map(Account.fromJson)
          .toList();

      final merged = <Account>[];

      for (final acc in accounts) {
        final stored = await _storage.read(key: _cardKey(acc.iban));

        if (stored != null) {
          final data = jsonDecode(stored) as Map<String, dynamic>;
          merged.add(
            acc.copyWith(
              cardNumber: (data['cardNumber'] ?? acc.cardNumber).toString(),
              expiryDate: (data['expiryDate'] ?? acc.expiryDate)?.toString(),
              cardHolderName:
                  (data['cardHolderName'] ?? acc.cardHolderName)?.toString(),
            ),
          );
        } else {
          merged.add(acc);
        }
      }

      _accounts = merged;
      // debugPrint('Fetched accounts: $_accounts');
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message; // backend error mesajı
      debugPrint('get account API Exception: ${e.message}');
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _error = 'Hesaplar yüklenirken hata oluştu.';
      debugPrint('get account general Exception: ${_.toString()}');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount({
    required String bankName,
    required String cardHolderName, // ✅ backend'e accountName gidecek
    required String iban,
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
        'accountName': cardHolderName.trim(), // ✅ mapping
        'iban': iban.trim(),
        'balance': balance,
        'currency': currency,
        'source': 'manual',
      };

      final createdJson = await api.createAccount(payload);
      final created = Account.fromJson(createdJson);

      // ✅ UI-only alanları localde tamamla
      final uiAccount = created.copyWith(
        cardHolderName: cardHolderName,
        lastSyncAt: DateTime.now(), // ✅ şimdilik new date
      );

      _accounts.insert(0, uiAccount);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Hesap eklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(Account account) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    try {
      _accounts.removeWhere((a) => a.id == accountId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
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
