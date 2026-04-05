import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';

class SendEmailUseCase {
  final EmailRepository _emailRepository;

  SendEmailUseCase(this._emailRepository);

  Future<void> call(EmailEntity email) async {
    await _emailRepository.sendEmail(email);
  }
}