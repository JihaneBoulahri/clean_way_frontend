class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = 'info',
    this.read = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final value = json['id'];
    final id = value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

    return NotificationModel(
      id: id,
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? 'info',
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'read': read,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? type,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      read: read ?? this.read,
    );
  }
}