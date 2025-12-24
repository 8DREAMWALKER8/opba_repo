import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/api_service.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  AccountProvider() {
    _loadDemoAccounts();
  }

  void _loadDemoAccounts() {
    // Demo hesapları yükle
    _accounts = [
      Account(
        id: 'acc_1',
        userId: 'user_123',
        bankName: 'Ziraat Bankası',
        cardNumber: '8843 2347 9512 6940',
        cardHolderName: 'Ahmet Yılmaz',
        expiryDate: '06/25',
        iban: 'TR00 0001 0012 3456 7890 1234 56',
        balance: 6000.00,
        currency: 'TRY',
      ),
      Account(
        id: 'acc_2',
        userId: 'user_123',
        bankName: 'İş Bankası',
        cardNumber: '4532 1234 5678 9012',
        cardHolderName: 'Ahmet Yılmaz',
        expiryDate: '09/26',
        iban: 'TR00 0006 4000 0012 3456 7890 12',
        balance: 11350.00,
        currency: 'TRY',
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // _accounts would be loaded from API
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Hesaplar yüklenirken hata oluştu.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount({
    required String bankName,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String iban,
    double balance = 0.0,
    String currency = 'TRY',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final newAccount = Account(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_123',
        bankName: bankName,
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        iban: iban,
        balance: balance,
        currency: currency,
      );

      _accounts.add(newAccount);
      _isLoading = false;
      notifyListeners();
      return true;
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