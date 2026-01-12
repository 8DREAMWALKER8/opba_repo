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

class LoanCalcRateInfo {
  final double monthlyRate;
  final double monthlyRatePercent;
  final double? annualEffectiveRate;
  final String? asOfMonth;
  final String? source;

  LoanCalcRateInfo({
    required this.monthlyRate,
    required this.monthlyRatePercent,
    required this.annualEffectiveRate,
    required this.asOfMonth,
    required this.source,
  });

  factory LoanCalcRateInfo.fromJson(Map<String, dynamic> json) {
    return LoanCalcRateInfo(
      monthlyRate: (json['monthly_rate'] is num)
          ? (json['monthly_rate'] as num).toDouble()
          : double.parse(json['monthly_rate'].toString()),
      monthlyRatePercent: (json['monthly_rate_percent'] is num)
          ? (json['monthly_rate_percent'] as num).toDouble()
          : double.parse(json['monthly_rate_percent'].toString()),
      annualEffectiveRate: (json['annual_effective_rate'] is num)
          ? (json['annual_effective_rate'] as num).toDouble()
          : (json['annual_effective_rate'] == null
              ? null
              : double.tryParse(json['annual_effective_rate'].toString())),
      asOfMonth: json['as_of_month']?.toString(),
      source: json['source']?.toString(),
    );
  }
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
      monthlyPayment: (json['monthlyPayment'] is num)
          ? (json['monthlyPayment'] as num).toDouble()
          : double.parse(json['monthlyPayment'].toString()),
      totalPayment: (json['totalPayment'] is num)
          ? (json['totalPayment'] as num).toDouble()
          : double.parse(json['totalPayment'].toString()),
      totalInterest: (json['totalInterest'] is num)
          ? (json['totalInterest'] as num).toDouble()
          : double.parse(json['totalInterest'].toString()),
    );
  }
}

class LoanCalcResponse {
  final bool ok;
  final LoanCalcInput input;
  final LoanCalcRateInfo rate;
  final LoanCalcResult result;

  LoanCalcResponse({
    required this.ok,
    required this.input,
    required this.rate,
    required this.result,
  });

  factory LoanCalcResponse.fromJson(Map<String, dynamic> json) {
    final inputJson = Map<String, dynamic>.from(json['input'] as Map);
    return LoanCalcResponse(
      ok: json['ok'] == true,
      input: LoanCalcInput(
        bankName: (inputJson['bank_name'] ?? '').toString(),
        loanType: (inputJson['loan_type'] ?? '').toString(),
        currency: (inputJson['currency'] ?? '').toString(),
        termMonths: (inputJson['term_months'] is num)
            ? (inputJson['term_months'] as num).toInt()
            : int.parse(inputJson['term_months'].toString()),
        principal: (inputJson['principal'] is num)
            ? (inputJson['principal'] as num).toDouble()
            : double.parse(inputJson['principal'].toString()),
      ),
      rate: LoanCalcRateInfo.fromJson(
          Map<String, dynamic>.from(json['rate'] as Map)),
      result: LoanCalcResult.fromJson(
          Map<String, dynamic>.from(json['result'] as Map)),
    );
  }
}
