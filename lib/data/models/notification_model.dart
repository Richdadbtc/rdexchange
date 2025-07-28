class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}