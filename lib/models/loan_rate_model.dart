class LoanRateItem {
  final String bankName;
  final String loanType;
  final String currency;
  final int termMonths;
  final double monthlyRate;
  final double monthlyRatePercent;
  final double? annualEffectiveRate;
  final String? asOfMonth;
  final String? source;

  LoanRateItem({
    required this.bankName,
    required this.loanType,
    required this.currency,
    required this.termMonths,
    required this.monthlyRate,
    required this.monthlyRatePercent,
    this.annualEffectiveRate,
    this.asOfMonth,
    this.source,
  });

  factory LoanRateItem.fromJson(Map<String, dynamic> json) {
    return LoanRateItem(
      bankName: (json['bankName'] ?? '').toString(),
      loanType: (json['loanType'] ?? 'consumer').toString(),
      currency: (json['currency'] ?? 'TRY').toString(),
      termMonths: (json['termMonths'] as num?)?.toInt() ?? 0,
      monthlyRate: (json['monthlyRate'] as num?)?.toDouble() ?? 0.0,
      monthlyRatePercent:
          (json['monthlyRatePercent'] as num?)?.toDouble() ?? 0.0,
      annualEffectiveRate: (json['annualEffectiveRate'] as num?)?.toDouble(),
      asOfMonth: json['asOfMonth']?.toString(),
      source: json['source']?.toString(),
    );
  }
}

class LoanCalcInput {
  final String bankName;
  final String loanType;
  final String currency;
  final int termMonths;
  final double principal;

  LoanCalcInput({
    required this.bankName,
    required this.loanType,
    required this.currency,
    required this.termMonths,
    required this.principal,
  });

  Map<String, dynamic> toJson() => {
        'bank_name': bankName,
        'loan_type': loanType,
        'currency': currency,
        'term_months': termMonths,
        'principal': principal,
      };
}

class LoanCalcResult {
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;

  LoanCalcResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
  });

  factory LoanCalcResult.fromJson(Map<String, dynamic> json) {
    return LoanCalcResult(
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
    );
  }
}

class LoanCalcResponse {
  final LoanRateItem? rate;
  final LoanCalcResult result;

  LoanCalcResponse({required this.rate, required this.result});

  factory LoanCalcResponse.fromJson(Map<String, dynamic> json) {
    final rateJson = json['rate'];
    return LoanCalcResponse(
      rate: (rateJson is Map)
          ? LoanRateItem.fromJson(Map<String, dynamic>.from(rateJson))
          : null,
      result: LoanCalcResult.fromJson(
          Map<String, dynamic>.from(json['result'] as Map)),
    );
  }
}
