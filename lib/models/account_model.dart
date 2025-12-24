class Account {
  final String? id;
  final String userId;
  final String bankName;
  final String cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String iban;
  final double balance;
  final String currency;
  final String accountType;
  final bool isActive;
  final DateTime? lastSyncAt;
  final DateTime? createdAt;

  Account({
    this.id,
    required this.userId,
    required this.bankName,
    required this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    required this.iban,
    this.balance = 0.0,
    this.currency = 'TRY',
    this.accountType = 'checking',
    this.isActive = true,
    this.lastSyncAt,
    this.createdAt,
  });

  // Masked card number for display
  String get maskedCardNumber {
    if (cardNumber.length >= 16) {
      final cleaned = cardNumber.replaceAll(' ', '');
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12)}';
    }
    return cardNumber;
  }

  // Get last 4 digits
  String get lastFourDigits {
    final cleaned = cardNumber.replaceAll(' ', '');
    return cleaned.length >= 4 ? cleaned.substring(cleaned.length - 4) : cleaned;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      bankName: json['bankName'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      cardHolderName: json['cardHolderName'],
      expiryDate: json['expiryDate'],
      iban: json['iban'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TRY',
      accountType: json['accountType'] ?? 'checking',
      isActive: json['isActive'] ?? true,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bankName': bankName,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'iban': iban,
      'balance': balance,
      'currency': currency,
      'accountType': accountType,
      'isActive': isActive,
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? iban,
    double? balance,
    String? currency,
    String? accountType,
    bool? isActive,
    DateTime? lastSyncAt,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      iban: iban ?? this.iban,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Bank list
class Bank {
  final String id;
  final String name;
  final String code;

  const Bank({
    required this.id,
    required this.name,
    required this.code,
  });

  static const List<Bank> turkishBanks = [
    Bank(id: 'ziraat', name: 'Ziraat Bankası', code: 'TCZBTR'),
    Bank(id: 'isbank', name: 'İş Bankası', code: 'ISBKTR'),
    Bank(id: 'garanti', name: 'Garanti BBVA', code: 'GARTTR'),
    Bank(id: 'yapikredi', name: 'Yapı Kredi', code: 'YAPITRT'),
    Bank(id: 'akbank', name: 'Akbank', code: 'AKBKTR'),
    Bank(id: 'halkbank', name: 'Halkbank', code: 'TRHBTR'),
    Bank(id: 'vakifbank', name: 'VakıfBank', code: 'TVBATR'),
    Bank(id: 'qnb', name: 'QNB Finansbank', code: 'FNNBTR'),
    Bank(id: 'denizbank', name: 'DenizBank', code: 'DENITRI'),
    Bank(id: 'teb', name: 'TEB', code: 'TEBUTR'),
    Bank(id: 'ing', name: 'ING', code: 'INGBTR'),
    Bank(id: 'hsbc', name: 'HSBC', code: 'HSBCTR'),
    Bank(id: 'enpara', name: 'Enpara', code: 'QNBFTR'),
  ];
}