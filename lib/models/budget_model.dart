import 'transaction_model.dart';

class Budget {
  final String? id;
  final String userId;
  final TransactionCategory category;
  final double limitAmount;
  final double spentAmount;
  final String month; // format: '2024-01'
  final bool alertSent80;
  final bool alertSent100;
  final DateTime? createdAt;
  final String currency;

  Budget({
    this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.month,
    this.alertSent80 = false,
    this.alertSent100 = false,
    this.createdAt,
    required this.currency,
  });

  double get progress => limitAmount > 0 ? (spentAmount / limitAmount) : 0.0;
  double get percentage => progress * 100.0;
  double get remaining => limitAmount - spentAmount;
  bool get isOverBudget => spentAmount > limitAmount;
  bool get isNearLimit => progress >= 0.8;

  String get status {
    if (isOverBudget) return 'exceeded';
    if (isNearLimit) return 'warning';
    return 'normal';
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    final rawCategory = (json['category'] ?? json['categoryName'])?.toString();

    return Budget(
      id: (json['_id'] ?? json['id'])?.toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '')?.toString() ?? '',
      category: parseCategory(rawCategory),
      limitAmount: _toDouble(json['limit'] ?? json['limit']),
      spentAmount: _toDouble(json['spent'] ?? json['spent']),
      month: (json['month'] ?? json['yyyy_mm'] ?? '')?.toString() ?? '',
      alertSent80:
          (json['alertSent80'] ?? json['alert_sent_80'] ?? false) == true,
      alertSent100:
          (json['alertSent100'] ?? json['alert_sent_100'] ?? false) == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      currency: json['currency'] ?? null,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'category': category.name,
      'limitAmount': limitAmount,
      'month': month,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category.name,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'month': month,
      'alertSent80': alertSent80,
      'alertSent100': alertSent100,
    };
  }

  Budget copyWith({
    String? id,
    String? userId,
    TransactionCategory? category,
    double? limitAmount,
    double? spentAmount,
    String? month,
    bool? alertSent80,
    bool? alertSent100,
    DateTime? createdAt,
    String? currency,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      alertSent80: alertSent80 ?? this.alertSent80,
      alertSent100: alertSent100 ?? this.alertSent100,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static TransactionCategory parseCategory(String? category) {
    final c = (category ?? '').trim().toLowerCase();
    if (c.isEmpty) return TransactionCategory.other;

    switch (c) {
      case 'market':
        return TransactionCategory.market;

      case 'bills':
      case 'faturalar':
      case 'fatura':
      case 'invoice':
        return TransactionCategory.bills;

      case 'entertainment':
      case 'eğlence':
      case 'eglence':
        return TransactionCategory.entertainment;

      case 'transport':
      case 'ulaşım':
      case 'ulasim':
      case 'transportation':
        return TransactionCategory.transport;

      case 'food':
      case 'yemek':
        return TransactionCategory.food;

      case 'health':
      case 'sağlık':
      case 'saglik':
        return TransactionCategory.health;

      case 'shopping':
      case 'alışveriş':
      case 'alisveris':
        return TransactionCategory.shopping;

      case 'salary':
      case 'maaş':
      case 'maas':
        return TransactionCategory.salary;

      case 'transfer':
        return TransactionCategory.transfer;

      default:
        return TransactionCategory.other;
    }
  }
}
