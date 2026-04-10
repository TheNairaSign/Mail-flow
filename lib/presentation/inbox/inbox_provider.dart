import 'package:email_snaarp/data/repositories/email_repository_impl.dart';
import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/domain/repositories/email_repository.dart';
import 'package:email_snaarp/domain/usecases/get_emails_usecase.dart';
import 'package:email_snaarp/domain/usecases/delete_email_usecase.dart';
import 'package:email_snaarp/domain/usecases/archive_email_usecase.dart';
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

final archiveEmailUseCaseProvider = Provider<ArchiveEmailUseCase>((ref) {
  return ArchiveEmailUseCase(ref.read(emailRepositoryProvider));
});

// Inbox State Notifier
class InboxNotifier extends StateNotifier<AsyncValue<List<EmailEntity>>> {
  final GetEmailsUseCase _getEmailsUseCase;
  final DeleteEmailUseCase _deleteEmailUseCase;
  final ArchiveEmailUseCase _archiveEmailUseCase;

  InboxNotifier(this._getEmailsUseCase, this._deleteEmailUseCase, this._archiveEmailUseCase) : super(const AsyncValue.loading()) {
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
      final updatedEmails = emails.map((email) {
        if (email.id == id) {
          return email.copyWith(folder: 'bin');
        }
        return email;
      }).toList();
      state = AsyncValue.data(updatedEmails);
    });

    try {
      await _deleteEmailUseCase.call(id);
    } catch (e, st) {
      // Revert if error occurs
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

  Future<void> archiveEmail(String id) async {
    // Optimistic UI update
    state.whenData((emails) {
      final updatedEmails = emails.map((email) {
        if (email.id == id) {
          return email.copyWith(isArchived: true, folder: 'archive');
        }
        return email;
      }).toList();
      state = AsyncValue.data(updatedEmails);
    });

    try {
      await _archiveEmailUseCase.call(id);
    } catch (e, st) {
      // Revert if error occurs
    }
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, AsyncValue<List<EmailEntity>>>((ref) {
  return InboxNotifier(
    ref.read(getEmailsUseCaseProvider),
    ref.read(deleteEmailUseCaseProvider),
    ref.read(archiveEmailUseCaseProvider),
  );
});

final activeFolderProvider = StateProvider<String>((ref) => 'inbox');

final filteredEmailsProvider = Provider.family<List<EmailEntity>, String>((ref, query) {
  final emailsAsyncValue = ref.watch(inboxProvider);
  final activeFolder = ref.watch(activeFolderProvider);

  return emailsAsyncValue.when(
    data: (emails) {
      var filtered = emails;

      // Filter by folder/status
      if (activeFolder == 'starred') {
        filtered = filtered.where((e) => e.isStarred).toList();
      } else if (activeFolder == 'archive') {
        filtered = filtered.where((e) => e.isArchived).toList();
      } else if (activeFolder == 'bin') {
        filtered = filtered.where((e) => e.folder == 'bin').toList();
      } else if (activeFolder == 'sent') {
        filtered = filtered.where((e) => e.folder == 'sent').toList();
      } else {
        // Default inbox: not archived and not in bin
        filtered = filtered.where((e) => !e.isArchived && e.folder != 'bin').toList();
      }

      if (query.isEmpty) {
        return filtered;
      }
      return filtered.where((email) {
        final lowerCaseQuery = query.toLowerCase();
        return email.senderName.toLowerCase().contains(lowerCaseQuery) || email.subject.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    },
    loading: () => [],
    error: (err, st) => [],
  );
});