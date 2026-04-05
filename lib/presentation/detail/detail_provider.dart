import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/usecases/get_email_detail_usecase.dart';
import 'package:email_snaarp/domain/usecases/update_email_read_status_usecase.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart'; // To access emailRepositoryProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for the use cases
final getEmailDetailUseCaseProvider = Provider<GetEmailDetailUseCase>((ref) {
  return GetEmailDetailUseCase(ref.read(emailRepositoryProvider));
});

final updateEmailReadStatusUseCaseProvider = Provider<UpdateEmailReadStatusUseCase>((ref) {
  return UpdateEmailReadStatusUseCase(ref.read(emailRepositoryProvider));
});

// Email Detail State Notifier
class EmailDetailNotifier extends StateNotifier<AsyncValue<EmailEntity?>> {
  final GetEmailDetailUseCase _getEmailDetailUseCase;
  final UpdateEmailReadStatusUseCase _updateEmailReadStatusUseCase;
  final InboxNotifier _inboxNotifier; // To update inbox state

  EmailDetailNotifier(
    this._getEmailDetailUseCase,
    this._updateEmailReadStatusUseCase,
    this._inboxNotifier,
  ) : super(const AsyncValue.loading());

  Future<void> fetchEmailDetail(String id) async {
    state = const AsyncValue.loading();
    try {
      final email = await _getEmailDetailUseCase.call(id);
      state = AsyncValue.data(email);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleReadStatus(String id, bool isRead) async {
    state.whenData((email) async {
      if (email != null) {
        state = AsyncValue.data(email.copyWith(isRead: isRead));
        await _updateEmailReadStatusUseCase.call(id, isRead);
        _inboxNotifier.updateEmailReadStatus(id, isRead); // Update inbox list
      }
    });
  }
}

final emailDetailProvider = StateNotifierProvider.family<EmailDetailNotifier, AsyncValue<EmailEntity?>, String>((ref, emailId) {
  return EmailDetailNotifier(
    ref.read(getEmailDetailUseCaseProvider),
    ref.read(updateEmailReadStatusUseCaseProvider),
    ref.read(inboxProvider.notifier),
  )..fetchEmailDetail(emailId);
});