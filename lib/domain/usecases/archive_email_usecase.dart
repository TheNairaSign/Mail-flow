import 'package:email_snaarp/domain/repositories/email_repository.dart';

class ArchiveEmailUseCase {
  final EmailRepository _emailRepository;

  ArchiveEmailUseCase(this._emailRepository);

  Future<void> call(String id) async {
    await _emailRepository.archiveEmail(id);
  }
}
