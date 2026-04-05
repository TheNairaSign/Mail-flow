class EmailEntity {
  final String id;
  final String senderName;
  final String senderEmail;
  final String recipientEmail;
  final String subject;
  final String bodyPreview;
  final String fullBody;
  final DateTime timestamp;
  bool isRead;
  final bool isStarred;

  EmailEntity({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.recipientEmail,
    required this.subject,
    required this.bodyPreview,
    required this.fullBody,
    required this.timestamp,
    this.isRead = false,
    this.isStarred = false,
  });

  EmailEntity copyWith({
    String? id,
    String? senderName,
    String? senderEmail,
    String? recipientEmail,
    String? subject,
    String? bodyPreview,
    String? fullBody,
    DateTime? timestamp,
    bool? isRead,
    bool? isStarred,
  }) {
    return EmailEntity(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      subject: subject ?? this.subject,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      fullBody: fullBody ?? this.fullBody,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}