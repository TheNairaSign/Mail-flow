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
  bool isArchived;
  final String folder;
  final String category;
  final List<String> labels;
  final List<String> attachments;

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
    this.isArchived = false,
    this.folder = 'inbox',
    this.category = 'primary',
    this.labels = const [],
    this.attachments = const [],
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
    bool? isArchived,
    String? folder,
    String? category,
    List<String>? labels,
    List<String>? attachments,
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
      isArchived: isArchived ?? this.isArchived,
      folder: folder ?? this.folder,
      category: category ?? this.category,
      labels: labels ?? this.labels,
      attachments: attachments ?? this.attachments,
    );
  }
}