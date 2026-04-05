import 'package:email_snaarp/domain/repositories/email_repository.dart';

class UpdateEmailReadStatusUseCase {
  final EmailRepository _emailRepository;

  UpdateEmailReadStatusUseCase(this._emailRepository);

  Future<void> call(String id, bool isRead) async {
    await _emailRepository.updateEmailReadStatus(id, isRead);
  }
}