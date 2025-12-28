class User {
  final String? id;
  final String username;
  final String email;
  final String? phone;
  final String? name;
  final String language;
  final String currency;
  final String theme;
  final String securityQuestion;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.phone,
    this.name,
    this.language = 'tr',
    this.currency = 'TRY',
    this.theme = 'light',
    required this.securityQuestion,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      name: json['name'],
      language: json['language'] ?? 'tr',
      currency: json['currency'] ?? 'TRY',
      theme: json['theme'] ?? 'light',
      securityQuestion: json['securityQuestion'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'name': name,
      'language': language,
      'currency': currency,
      'theme': theme,
      'securityQuestion': securityQuestion,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? name,
    String? language,
    String? currency,
    String? theme,
    String? securityQuestion,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
