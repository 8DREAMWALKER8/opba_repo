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

  // =========================
  // STORAGE KEY (NEW + LEGACY)
  // =========================

  /// ✅ Yeni key: cardNumber -> iban (legacy) -> id fallback
  String _storageKeyForAccount(Account acc) {
    final cn = (acc.cardNumber ?? '').trim();
    if (cn.isNotEmpty) return 'acct_card_cn_$cn';

    // Legacy alan (eski datalar)
    final iban = ((acc as dynamic).iban ?? '').toString().trim();
    if (iban.isNotEmpty) return 'acct_card_iban_$iban';

    final id = (acc.id ?? '').trim();
    if (id.isNotEmpty) return 'acct_card_id_$id';

    return 'acct_card_unknown';
  }

  /// ✅ Eski key formatları burada yakalıyoruz
  List<String> _legacyKeysForAccount(Account acc) {
    final keys = <String>[];

    final cn = (acc.cardNumber ?? '').trim();
    final iban = ((acc as dynamic).iban ?? '').toString().trim();
    final id = (acc.id ?? '').trim();

    // senin eski kodun:
    // String _cardKey(String iban) => 'acct_card_$iban';
    if (iban.isNotEmpty) keys.add('acct_card_$iban');

    // geçmişte yanlışlıkla böyle yazıldıysa diye (opsiyonel)
    if (cn.isNotEmpty) keys.add('acct_card_$cn');
    if (id.isNotEmpty) keys.add('acct_card_$id');

    return keys;
  }

  Future<Map<String, dynamic>?> _readMergedCardData(Account acc) async {
    final newKey = _storageKeyForAccount(acc);

    // 1) önce yeni key’den oku
    String? stored = await _storage.read(key: newKey);

    // 2) yoksa legacy key’lerden ara + migrate et
    if (stored == null) {
      for (final legacyKey in _legacyKeysForAccount(acc)) {
        stored = await _storage.read(key: legacyKey);
        if (stored != null) {
          // migrate (kopyala)
          await _storage.write(key: newKey, value: stored);

          // istersen legacy'yi temizle (opsiyonel)
          // await _storage.delete(key: legacyKey);
          break;
        }
      }
    }

    if (stored == null) return null;

    try {
      return jsonDecode(stored) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCardData(Account acc, Map<String, dynamic> data) async {
    final key = _storageKeyForAccount(acc);
    await _storage.write(key: key, value: jsonEncode(data));
  }

  // =========================
  // API
  // =========================

  Future<void> fetchAccounts(String? currency) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final raw = await api.getAccounts(currency: currency!); // List<dynamic>

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

      // ✅ backend: DELETE /accounts/:id  -> { ok:true, account: {...} }
      final deletedJson = await api.deactivateAccount(accountId);

      final deletedId =
          (deletedJson['id'] ?? deletedJson['_id'] ?? accountId).toString();

      // ✅ hard delete: listeden tamamen çıkar
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
    required String cardHolderName, // backend: cardHolder
    required String cardNumber, // backend: cardNumber
    required String description,
    double balance = 0.0,
    String currency = 'TRY',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      // ✅ backend payload (senin controller schema’na göre: cardHolder + cardNumber)
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

      // UI-only alanları localde tamamla
      final uiAccount = created.copyWith(
        cardHolderName: cardHolderName.trim(),
        cardNumber: cardNumber.trim(),
        description: description.trim(),
        lastSyncAt: DateTime.now(),
      );

      // ✅ storage'a da yaz (eski datalarla uyumlu key sistemiyle)
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

      // ✅ Backend payload (yeni field isimleriyle)
      final payload = <String, dynamic>{
        'bankName': account.bankName.trim(),
        'cardHolderName': (account.cardHolderName ?? '').trim(),
        'cardNumber': cardNumber,
        'description': (account.description ?? '').trim(),
        'balance': account.balance,
        'currency': account.currency,
        // expiryDate backend’de varsa aç:
        // 'expiryDate': account.expiryDate,
      };

      final api = ApiService();

      // ✅ API’den güncellenmiş account’u al
      final updatedJson = await api.patchAccount(id, payload);
      final updated = Account.fromJson(updatedJson);

      // ✅ Local listeyi server cevabına göre güncelle
      final index = _accounts.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _accounts[index] = updated;
      } else {
        // listede yoksa başa ekle (opsiyonel)
        _accounts.insert(0, updated);
      }

      // ✅ UI-only alanları storage’a yaz
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
