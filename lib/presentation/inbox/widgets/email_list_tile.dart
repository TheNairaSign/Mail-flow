import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailListTile extends ConsumerWidget {
  final EmailEntity email;
  final VoidCallback onTap;
  final String Function(DateTime) formatTimestamp;

  const EmailListTile({super.key, required this.email, required this.onTap, required this.formatTimestamp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isRead = email.isRead;
    final isStarred = email.isStarred;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 20,
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${email.senderEmail}'),
            ),
            const SizedBox(width: 14),
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
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatTimestamp(email.timestamp),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead ? (isDark ? Colors.grey[400] : Colors.grey[600]) : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Unread dot indicator
                          if (!isRead)
                             Icon(Icons.circle, color: isDark ? Colors.blue[200] : Colors.blue[600], size: 8),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email.subject,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              email.bodyPreview,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isStarred ? Icons.star : Icons.star_border,
                          color: isStarred ? Colors.amber : (isDark ? Colors.grey[600] : Colors.grey[400]),
                          size: 22,
                        ),
                        onPressed: () {
                           ref.read(inboxProvider.notifier).toggleStar(email.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
