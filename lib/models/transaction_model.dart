import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

enum TransactionType { income, expense, transfer }

enum TransactionCategory {
  market,
  bills,
  entertainment,
  transport,
  food,
  health,
  shopping,
  salary,
  transfer,
  other
}

extension TransactionCategoryExtension on TransactionCategory {
  String get name {
    switch (this) {
      case TransactionCategory.market:
        return 'Market';
      case TransactionCategory.bills:
        return 'Faturalar';
      case TransactionCategory.entertainment:
        return 'Eğlence';
      case TransactionCategory.transport:
        return 'Ulaşım';
      case TransactionCategory.food:
        return 'Yemek';
      case TransactionCategory.health:
        return 'Sağlık';
      case TransactionCategory.shopping:
        return 'Alışveriş';
      case TransactionCategory.salary:
        return 'Maaş';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.other:
        return 'Diğer';
    }
  }

  String get nameEn {
    switch (this) {
      case TransactionCategory.market:
        return 'Market';
      case TransactionCategory.bills:
        return 'Bills';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  // uygulama dili neyse ona göre kategori adını döndürür
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case TransactionCategory.market:
        return l10n.translate('category_market');
      case TransactionCategory.bills:
        return l10n.translate('category_bills');
      case TransactionCategory.entertainment:
        return l10n.translate('category_entertainment');
      case TransactionCategory.transport:
        return l10n.translate('category_transport');
      case TransactionCategory.food:
        return l10n.translate('category_food');
      case TransactionCategory.health:
        return l10n.translate('category_health');
      case TransactionCategory.shopping:
        return l10n.translate('category_shopping');
      case TransactionCategory.salary:
        return l10n.locale.languageCode == 'en' ? 'Salary' : 'Maaş';
      case TransactionCategory.transfer:
        return l10n.locale.languageCode == 'en' ? 'Transfer' : 'Transfer';
      case TransactionCategory.other:
        return l10n.translate('category_other');
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.market:
        return AppColors.categoryMarket;
      case TransactionCategory.bills:
        return AppColors.categoryBills;
      case TransactionCategory.entertainment:
        return AppColors.categoryEntertainment;
      case TransactionCategory.transport:
        return AppColors.categoryTransport;
      case TransactionCategory.food:
        return AppColors.categoryFood;
      case TransactionCategory.health:
        return AppColors.categoryHealth;
      case TransactionCategory.shopping:
        return AppColors.categoryShopping;
      case TransactionCategory.salary:
        return AppColors.success;
      case TransactionCategory.transfer:
        return AppColors.info;
      case TransactionCategory.other:
        return AppColors.categoryOther;
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.market:
        return Icons.shopping_cart;
      case TransactionCategory.bills:
        return Icons.receipt_long;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.health:
        return Icons.local_hospital;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.salary:
        return Icons.account_balance_wallet;
      case TransactionCategory.transfer:
        return Icons.swap_horiz;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }
}

class Transaction {
  final String? id;
  final String userId;
  final String accountId;
  final String? merchant;
  final String? description;
  final double amount;
  final String currency;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final bool isRecurring;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.userId,
    required this.accountId,
    this.merchant,
    this.description,
    required this.amount,
    this.currency = 'TRY',
    required this.type,
    required this.category,
    required this.date,
    this.isRecurring = false,
    this.createdAt,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  String get formattedAmount {
    final sign = isExpense ? '-' : '+';
    return '$sign${amount.toStringAsFixed(2)} TL';
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      accountId: json['accountId'] ?? '',
      merchant: json['merchant'],
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TRY',
      type: _parseTransactionType(json['type']),
      category: _parseCategory(json['category']),
      date: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'])
          : DateTime.now(),
      isRecurring: json['isRecurring'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'income':
        return TransactionType.income;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }

  static TransactionCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'market':
        return TransactionCategory.market;
      case 'bills':
      case 'faturalar':
        return TransactionCategory.bills;
      case 'entertainment':
      case 'eğlence':
        return TransactionCategory.entertainment;
      case 'transport':
      case 'ulaşım':
        return TransactionCategory.transport;
      case 'food':
      case 'yemek':
        return TransactionCategory.food;
      case 'health':
      case 'sağlık':
        return TransactionCategory.health;
      case 'shopping':
      case 'alışveriş':
        return TransactionCategory.shopping;
      case 'salary':
      case 'maaş':
        return TransactionCategory.salary;
      case 'transfer':
        return TransactionCategory.transfer;
      default:
        return TransactionCategory.other;
    }
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? merchant,
    String? description,
    double? amount,
    String? currency,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      merchant: merchant ?? this.merchant,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  setUserId(String? userId) {
    return Transaction(
      id: id,
      userId: userId ?? this.userId,
      accountId: accountId,
      merchant: merchant,
      description: description,
      amount: amount,
      currency: currency,
      type: type,
      category: category,
      date: date,
      isRecurring: isRecurring,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'merchant': merchant,
      'description': description,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
    };
  }
}

class CategorySummary {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  CategorySummary({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}
