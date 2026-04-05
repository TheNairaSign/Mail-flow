import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/presentation/auth/auth_provider.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final emailDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (emailDate.isAtSameMomentAs(today)) {
      return DateFormat.jm().format(timestamp); // e.g., 10:32 AM
    } else if (emailDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat.E().format(timestamp); // e.g., Mon, Tue
    } else {
      return DateFormat.MMMd().format(timestamp); // e.g., Mar 28
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsyncValue = ref.watch(inboxProvider);
    final filteredEmails = ref.watch(filteredEmailsProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by sender or subject',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(inboxProvider.notifier).fetchEmails(),
        child: inboxAsyncValue.when(
          loading: () => _buildSkeletonLoader(),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load emails.'),
                ElevatedButton(
                  onPressed: () => ref.read(inboxProvider.notifier).fetchEmails(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (emails) {
            if (filteredEmails.isEmpty && _searchQuery.isNotEmpty) {
              return const Center(child: Text('No matching emails found.'));
            } else if (filteredEmails.isEmpty) {
              return const Center(child: Text('No emails in your inbox.'));
            }
            return ListView.builder(
              itemCount: filteredEmails.length,
              itemBuilder: (context, index) {
                final email = filteredEmails[index];
                return EmailListTile(
                  email: email,
                  onTap: () {
                    // Navigate to detail screen
                    Navigator.pushNamed(context, '/email_detail', arguments: email.id);
                    // Mark as read when tapped
                    ref.read(inboxProvider.notifier).updateEmailReadStatus(email.id, true);
                  },
                  formatTimestamp: _formatTimestamp,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/compose');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 10, // Number of skeleton items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmailListTile extends StatelessWidget {
  const EmailListTile({
    super.key,
    required this.email,
    required this.onTap,
    required this.formatTimestamp,
  });

  final EmailEntity email;
  final VoidCallback onTap;
  final String Function(DateTime) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: email.isRead ? colorScheme.secondaryContainer : colorScheme.primary,
              foregroundColor: email.isRead ? colorScheme.onSecondaryContainer : colorScheme.onPrimary,
              child: Text(
                email.senderName.isNotEmpty ? email.senderName[0].toUpperCase() : '?',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          email.senderName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatTimestamp(email.timestamp),
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.subject,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.bodyPreview,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (!email.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Icon(
                  Icons.circle,
                  color: colorScheme.primary,
                  size: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}