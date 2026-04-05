import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';

class GetEmailDetailUseCase {
  final EmailRepository _emailRepository;

  GetEmailDetailUseCase(this._emailRepository);

  Future<EmailEntity?> call(String id) async {
    return await _emailRepository.getEmailDetail(id);
  }
}