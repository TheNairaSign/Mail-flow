import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';

class GetEmailsUseCase {
  final EmailRepository _emailRepository;

  GetEmailsUseCase(this._emailRepository);

  Future<List<EmailEntity>> call() async {
    return await _emailRepository.getEmails();
  }
}