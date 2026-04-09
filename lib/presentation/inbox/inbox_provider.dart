import 'package:email_snaarp/data/repositories/email_repository_impl.dart';
import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';
import 'package:email_snaarp/domain/usecases/get_emails_usecase.dart';
import 'package:email_snaarp/domain/usecases/delete_email_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for the repository and use case
final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return EmailRepositoryImpl();
});

final getEmailsUseCaseProvider = Provider<GetEmailsUseCase>((ref) {
  return GetEmailsUseCase(ref.read(emailRepositoryProvider));
});

final deleteEmailUseCaseProvider = Provider<DeleteEmailUseCase>((ref) {
  return DeleteEmailUseCase(ref.read(emailRepositoryProvider));
});

// Inbox State Notifier
class InboxNotifier extends StateNotifier<AsyncValue<List<EmailEntity>>> {
  final GetEmailsUseCase _getEmailsUseCase;
  final DeleteEmailUseCase _deleteEmailUseCase;

  InboxNotifier(this._getEmailsUseCase, this._deleteEmailUseCase) : super(const AsyncValue.loading()) {
    fetchEmails();
  }

  Future<void> fetchEmails() async {
    state = const AsyncValue.loading();
    try {
      final emails = await _getEmailsUseCase.call();
      state = AsyncValue.data(emails);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateEmailReadStatus(String id, bool isRead) {
    state.whenData((emails) {
      final updatedEmails = emails.map((email) {
        if (email.id == id) {
          return email.copyWith(isRead: isRead);
        }
        return email;
      }).toList();
      state = AsyncValue.data(updatedEmails);
    });
  }

  Future<void> deleteEmail(String id) async {
    // Optimistic UI update
    state.whenData((emails) {
      state = AsyncValue.data(emails.where((e) => e.id != id).toList());
    });

    try {
      await _deleteEmailUseCase.call(id);
    } catch (e, st) {
      // Revert if error occurs (optional, but good practice)
      // For now, let's just log or ignore for this exercise
    }
  }

  void toggleStar(String id) {
    state.whenData((emails) {
      final updatedEmails = emails.map((email) {
        if (email.id == id) {
          return email.copyWith(isStarred: !email.isStarred);
        }
        return email;
      }).toList();
      state = AsyncValue.data(updatedEmails);
    });
  }

  void archiveEmail(String id) {
    state.whenData((emails) {
      final updatedEmails = emails.map((email) {
        if (email.id == id) {
          return email.copyWith(isArchived: true, folder: 'archive'); // Mark archived
        }
        return email;
      }).toList();
      state = AsyncValue.data(updatedEmails);
    });
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, AsyncValue<List<EmailEntity>>>((ref) {
  return InboxNotifier(
    ref.read(getEmailsUseCaseProvider),
    ref.read(deleteEmailUseCaseProvider),
  );
});

final activeFolderProvider = StateProvider<String>((ref) => 'inbox');

final filteredEmailsProvider = Provider.family<List<EmailEntity>, String>((ref, query) {
  final emailsAsyncValue = ref.watch(inboxProvider);
  return emailsAsyncValue.when(
    data: (emails) {
      if (query.isEmpty) {
        return emails;
      }
      return emails.where((email) {
        final lowerCaseQuery = query.toLowerCase();
        return email.senderName.toLowerCase().contains(lowerCaseQuery) || email.subject.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    },
    loading: () => [],
    error: (err, st) => [],
  );
});