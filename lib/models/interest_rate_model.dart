class InterestRateItem {
  final String bankName;
  final String loanType;
  final String currency;
  final int termMonths;
  final double monthlyRate; // 0.03162
  final double monthlyRatePercent; // 3.16
  final double? annualEffectiveRate;
  final String? asOfMonth;
  final String? source;

  InterestRateItem({
    required this.bankName,
    required this.loanType,
    required this.currency,
    required this.termMonths,
    required this.monthlyRate,
    required this.monthlyRatePercent,
    required this.annualEffectiveRate,
    required this.asOfMonth,
    required this.source,
  });

  factory InterestRateItem.fromJson(Map<String, dynamic> json) {
    return InterestRateItem(
      bankName: (json['bankName'] ?? '').toString(),
      loanType: (json['loanType'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      termMonths: (json['termMonths'] is num)
          ? (json['termMonths'] as num).toInt()
          : int.parse(json['termMonths'].toString()),
      monthlyRate: (json['monthlyRate'] is num)
          ? (json['monthlyRate'] as num).toDouble()
          : double.parse(json['monthlyRate'].toString()),
      monthlyRatePercent: (json['monthlyRatePercent'] is num)
          ? (json['monthlyRatePercent'] as num).toDouble()
          : double.parse(json['monthlyRatePercent'].toString()),
      annualEffectiveRate: (json['annualEffectiveRate'] is num)
          ? (json['annualEffectiveRate'] as num).toDouble()
          : (json['annualEffectiveRate'] == null
              ? null
              : double.tryParse(json['annualEffectiveRate'].toString())),
      asOfMonth: json['asOfMonth']?.toString(),
      source: json['source']?.toString(),
    );
  }
}

class InterestRateChartPoint {
  final String label; // bankName
  final double value; // monthlyRatePercent
  final int termMonths;

  InterestRateChartPoint({
    required this.label,
    required this.value,
    required this.termMonths,
  });

  factory InterestRateChartPoint.fromJson(Map<String, dynamic> json) {
    return InterestRateChartPoint(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] is num)
          ? (json['value'] as num).toDouble()
          : double.parse(json['value'].toString()),
      termMonths: (json['termMonths'] is num)
          ? (json['termMonths'] as num).toInt()
          : int.parse(json['termMonths'].toString()),
    );
  }
}

class InterestRatesResponse {
  final bool ok;
  final int count;
  final List<InterestRateChartPoint> chart;
  final List<InterestRateItem> items;

  InterestRatesResponse({
    required this.ok,
    required this.count,
    required this.chart,
    required this.items,
  });

  factory InterestRatesResponse.fromJson(Map<String, dynamic> json) {
    final chartList =
        (json['chart'] is List) ? (json['chart'] as List) : <dynamic>[];
    final itemsList =
        (json['items'] is List) ? (json['items'] as List) : <dynamic>[];

    return InterestRatesResponse(
      ok: json['ok'] == true,
      count: (json['count'] is num)
          ? (json['count'] as num).toInt()
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      chart: chartList
          .map((e) => InterestRateChartPoint.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      items: itemsList
          .map((e) =>
              InterestRateItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class BankTermsResponse {
  final bool ok;
  final String bankName;
  final String loanType;
  final String currency;
  final int count;
  final List<BankTermItem> terms;

  BankTermsResponse({
    required this.ok,
    required this.bankName,
    required this.loanType,
    required this.currency,
    required this.count,
    required this.terms,
  });

  factory BankTermsResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['terms'] is List) ? (json['terms'] as List) : <dynamic>[];
    return BankTermsResponse(
      ok: json['ok'] == true,
      bankName: (json['bankName'] ?? '').toString(),
      loanType: (json['loanType'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      count: (json['count'] is num)
          ? (json['count'] as num).toInt()
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      terms: list
          .map(
              (e) => BankTermItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class BankTermItem {
  final int termMonths;
  final double monthlyRate;
  final double monthlyRatePercent;
  final double? annualEffectiveRate;
  final String? asOfMonth;
  final String? source;

  BankTermItem({
    required this.termMonths,
    required this.monthlyRate,
    required this.monthlyRatePercent,
    required this.annualEffectiveRate,
    required this.asOfMonth,
    required this.source,
  });

  factory BankTermItem.fromJson(Map<String, dynamic> json) {
    return BankTermItem(
      termMonths: (json['termMonths'] is num)
          ? (json['termMonths'] as num).toInt()
          : int.parse(json['termMonths'].toString()),
      monthlyRate: (json['monthlyRate'] is num)
          ? (json['monthlyRate'] as num).toDouble()
          : double.parse(json['monthlyRate'].toString()),
      monthlyRatePercent: (json['monthlyRatePercent'] is num)
          ? (json['monthlyRatePercent'] as num).toDouble()
          : double.parse(json['monthlyRatePercent'].toString()),
      annualEffectiveRate: (json['annualEffectiveRate'] is num)
          ? (json['annualEffectiveRate'] as num).toDouble()
          : (json['annualEffectiveRate'] == null
              ? null
              : double.tryParse(json['annualEffectiveRate'].toString())),
      asOfMonth: json['asOfMonth']?.toString(),
      source: json['source']?.toString(),
    );
  }
}
