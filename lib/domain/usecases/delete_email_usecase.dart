import 'package:email_snaarp/domain/repositories/email_repository.dart';

class DeleteEmailUseCase {
  final EmailRepository _emailRepository;

  DeleteEmailUseCase(this._emailRepository);

  Future<void> call(String id) async {
    await _emailRepository.deleteEmail(id);
  }
}
