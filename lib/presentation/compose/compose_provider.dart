import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/usecases/send_email_usecase.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart'; // To access emailRepositoryProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the use case
final sendEmailUseCaseProvider = Provider<SendEmailUseCase>((ref) {
  return SendEmailUseCase(ref.read(emailRepositoryProvider));
});

// Compose State Notifier
class ComposeNotifier extends StateNotifier<AsyncValue<void>> {
  final SendEmailUseCase _sendEmailUseCase;
  final InboxNotifier _inboxNotifier; // To update inbox after sending

  ComposeNotifier(this._sendEmailUseCase, this._inboxNotifier) : super(const AsyncValue.data(null));

  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newEmail = EmailEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        senderName: 'You', // Assuming the current user is the sender
        senderEmail: 'user@mail.com', // Mock sender email
        recipientEmail: recipientEmail,
        subject: subject,
        bodyPreview: body.split('\n').first, // First line as preview
        fullBody: body,
        timestamp: DateTime.now(),
        isRead: true, // Sent emails are considered read
        isStarred: false,
      );
      await _sendEmailUseCase.call(newEmail);
      _inboxNotifier.fetchEmails(); // Refresh inbox to show sent email
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final composeProvider = StateNotifierProvider<ComposeNotifier, AsyncValue<void>>((ref) {
  return ComposeNotifier(
    ref.read(sendEmailUseCaseProvider),
    ref.read(inboxProvider.notifier),
  );
});
