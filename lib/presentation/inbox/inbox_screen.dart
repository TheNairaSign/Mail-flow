import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/presentation/auth/auth_provider.dart';
import 'package:email_snaarp/presentation/detail/details.dart';
import 'package:email_snaarp/presentation/detail/email_detail_screen.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino
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

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                enableBackgroundFilterBlur: true,
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                largeTitle: const Text('Inbox'),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  child: const Icon(CupertinoIcons.arrow_right_circle),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    height: 50,
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search by sender or subject',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () => ref.read(inboxProvider.notifier).fetchEmails(),
              ),
              inboxAsyncValue.when(
                loading: () => _buildSkeletonLoader(),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load emails.'),
                        CupertinoButton(
                          onPressed: () => ref.read(inboxProvider.notifier).fetchEmails(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (emails) {
                  if (filteredEmails.isEmpty && _searchQuery.isNotEmpty) {
                    return const SliverFillRemaining(child: Center(child: Text('No matching emails found.')));
                  } else if (filteredEmails.isEmpty) {
                    return const SliverFillRemaining(child: Center(child: Text('No emails in your inbox.')));
                  }
                  return SliverList.builder(
                    itemCount: filteredEmails.length,
                    itemBuilder: (context, index) {
                      final email = filteredEmails[index];
                      return EmailListTile(
                        email: email,
                        onTap: () {
                          // Navigate to detail screen
                          // Navigator.pushNamed(context, '/email_detail', arguments: email.id);
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => EmailDetailScreen(emailId: email.id),
                            ),
                          );

                          // Mark as read when tapped
                          ref.read(inboxProvider.notifier).updateEmailReadStatus(email.id, true);
                        },
                        formatTimestamp: _formatTimestamp,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Hero(
              tag: 'compose_hero',
              child: CupertinoButton.filled(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ComposeEmailScreen(),
                      // fullscreenDialog: true,
                    ),
                  );
                },
                child: const Icon(Icons.edit, color: Colors.white,),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverList.builder(
      itemCount: 10, // Number of skeleton items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                radius: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width:  MediaQuery.of(context).size.width * 0.3,
                          height: 16,
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                        ),
                        const Spacer(),
                        Container(
                          width: 70,
                          height: 10,
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 14,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 12,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
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

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
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
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
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