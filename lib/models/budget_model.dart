import '../models/transection_model.dart';

class Budget {
  final String? id;
  final String userId;
  final TransactionCategory category;
  final double limitAmount;
  final double spentAmount;
  final String month; // Format: '2024-01'
  final bool alertSent80;
  final bool alertSent100;
  final DateTime? createdAt;

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
    return Budget(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      category: _parseCategory(json['category']),
      limitAmount: (json['limitAmount'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      month: json['month'] ?? '',
      alertSent80: json['alertSent80'] ?? false,
      alertSent100: json['alertSent100'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
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
      default:
        return TransactionCategory.other;
    }
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
    );
  }
}