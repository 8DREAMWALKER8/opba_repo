class Account {
  final String? id;
  final String userId;
  final String bankName;
  final String cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final double balance;
  final String currency;
  final String accountType;
  final bool isActive;
  final DateTime? lastSyncAt;
  final DateTime? createdAt;
  final String description;

  Account({
    this.id,
    required this.userId,
    required this.bankName,
    required this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.balance = 0.0,
    this.currency = 'TRY',
    this.accountType = 'checking',
    this.isActive = true,
    this.lastSyncAt,
    this.createdAt,
    required this.description,
  });

  String get maskedCardNumber {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.length >= 16) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12)}';
    }
    if (cleaned.isEmpty) {
      return '•••• •••• •••• ••••';
    }
    return cardNumber;
  }

  // son 4 rakamı al
  String get lastFourDigits {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.isEmpty) return '••••';
    return cleaned.length >= 4
        ? cleaned.substring(cleaned.length - 4)
        : cleaned;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: (json['_id'] ?? json['id'])?.toString(),
      userId: (json['userId'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      cardNumber: (json['cardNumber'] ?? '').toString(),
      cardHolderName:
          (json['cardHolderName'] ?? json['accountName'])?.toString(),
      balance: (json['balance'] ?? 0).toDouble(),
      currency: (json['currency'] ?? 'TRY').toString(),
      accountType: (json['accountType'] ?? 'checking').toString(),
      isActive: (json['isActive'] ?? true) as bool,
      lastSyncAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'].toString())
          : (json['lastSyncAt'] != null
              ? DateTime.tryParse(json['lastSyncAt'].toString())
              : null),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      description: (json['description'] ?? 'temp').toString(),
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'bankName': bankName,
      'accountName': (cardHolderName ?? '').trim(),
      'cardNumber': cardNumber,
      'balance': balance,
      'currency': currency,
      'description': description,
      'source': 'manual',
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    double? balance,
    String? currency,
    String? accountType,
    bool? isActive,
    DateTime? lastSyncAt,
    DateTime? createdAt,
    String? description,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}

// banka listesi
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
    Bank(id: 'isbank', name: 'İş Bankası', code: 'ISBKTR'),
    Bank(id: 'garanti', name: 'Garanti BBVA', code: 'GARTTR'),
    Bank(id: 'akbank', name: 'Akbank', code: 'AKBKTR'),
  ];
}
