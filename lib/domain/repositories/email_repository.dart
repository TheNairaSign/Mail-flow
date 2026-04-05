import 'package:email_snaarp/domain/entities/email_entity.dart';

abstract class EmailRepository {
  Future<List<EmailEntity>> getEmails();
  Future<EmailEntity?> getEmailDetail(String id);
  Future<void> updateEmailReadStatus(String id, bool isRead);
  Future<void> sendEmail(EmailEntity email);
}