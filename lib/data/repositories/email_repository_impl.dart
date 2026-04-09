import 'package:email_snaarp/data/mock_emails.dart';
import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';

class EmailRepositoryImpl implements EmailRepository {
  // A mutable copy of mockEmails to simulate changes like read status
  final List<EmailEntity> _emails = List.from(mockEmails);

  @override
  Future<List<EmailEntity>> getEmails() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _emails;
  }

  @override
  Future<EmailEntity?> getEmailDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _emails.firstWhere((email) => email.id == id);
  }

  @override
  Future<void> updateEmailReadStatus(String id, bool isRead) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    final index = _emails.indexWhere((email) => email.id == id);
    if (index != -1) {
      _emails[index] = _emails[index].copyWith(isRead: isRead);
    }
  }

  @override
  Future<void> sendEmail(EmailEntity email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // For simplicity, just add to the list. In a real app, this would go to a "Sent" folder.
    _emails.insert(0, email); // Add to the beginning to appear as a new email
  }

  @override
  Future<void> deleteEmail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    _emails.removeWhere((email) => email.id == id);
  }
}