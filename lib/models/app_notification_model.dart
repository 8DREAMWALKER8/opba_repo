class AppNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['_id'] ?? json['id']).toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
