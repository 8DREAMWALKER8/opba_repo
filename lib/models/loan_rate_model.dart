class LoanRate {
  final String? id;
  final String bankName;
  final String loanType;
  final double interestRate;
  final int termMonths;
  final double? minAmount;
  final double? maxAmount;
  final double? monthlyPayment;
  final DateTime? lastUpdate;

  LoanRate({
    this.id,
    required this.bankName,
    required this.loanType,
    required this.interestRate,
    this.termMonths = 12,
    this.minAmount,
    this.maxAmount,
    this.monthlyPayment,
    this.lastUpdate,
  });

  // Calculate monthly payment for a given loan amount
  double calculateMonthlyPayment(double principal) {
    if (interestRate == 0) {
      return principal / termMonths;
    }
    final monthlyRate = interestRate / 100 / 12;
    final factor = (monthlyRate * 
        _pow(1 + monthlyRate, termMonths)) / 
        (_pow(1 + monthlyRate, termMonths) - 1);
    return principal * factor;
  }

  // Simple pow function
  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  factory LoanRate.fromJson(Map<String, dynamic> json) {
    return LoanRate(
      id: json['_id'] ?? json['id'],
      bankName: json['bankName'] ?? '',
      loanType: json['loanType'] ?? 'personal',
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      termMonths: json['termMonths'] ?? 12,
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      monthlyPayment: json['monthlyPayment']?.toDouble(),
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'loanType': loanType,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'monthlyPayment': monthlyPayment,
    };
  }
}

class CurrencyRate {
  final String code;
  final String name;
  final double buyRate;
  final double sellRate;
  final DateTime asOf;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.buyRate,
    required this.sellRate,
    required this.asOf,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      buyRate: (json['buyRate'] ?? 0).toDouble(),
      sellRate: (json['sellRate'] ?? 0).toDouble(),
      asOf: json['asOf'] != null
          ? DateTime.parse(json['asOf'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'buyRate': buyRate,
      'sellRate': sellRate,
      'asOf': asOf.toIso8601String(),
    };
  }
}