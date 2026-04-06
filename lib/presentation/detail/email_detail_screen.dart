import 'package:email_snaarp/presentation/detail/detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EmailDetailScreen extends ConsumerWidget {
  final String emailId;
  const EmailDetailScreen({super.key, required this.emailId});

  String _formatFullTimestamp(DateTime timestamp) {
    return DateFormat('EEE, MMM d, yyyy \'at\' h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailDetailAsyncValue = ref.watch(emailDetailProvider(emailId));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: emailDetailAsyncValue.when(
          data: (email) => Text(email?.subject ?? 'Email Detail'),
          loading: () => const Text('Loading...'),
          error: (err, st) => const Text('Error'),
        ),
        actions: [
          emailDetailAsyncValue.when(
            data: (email) {
              if (email == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(email.isRead ? Icons.mark_email_read : Icons.mark_email_unread),
                onPressed: () {
                  ref.read(emailDetailProvider(emailId).notifier).toggleReadStatus(email.id, !email.isRead);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: emailDetailAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (email) {
          if (email == null) {
            return const Center(child: Text('Email not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.subject,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(email.senderName.isNotEmpty ? email.senderName[0].toUpperCase() : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.senderName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '<${email.senderEmail}> to <${email.recipientEmail}>',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatFullTimestamp(email.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Divider(height: 32, color: isDark ? Colors.grey[800] : Colors.grey[300],),
                Text(
                  email.fullBody,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reply coming soon')),
                      );
                    },
                    icon: const Icon(Icons.reply),
                    label: const Text('Reply'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
