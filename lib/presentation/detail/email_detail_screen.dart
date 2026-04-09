import 'package:email_snaarp/presentation/detail/detail_provider.dart';
import 'package:email_snaarp/presentation/compose/compose_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EmailDetailScreen extends ConsumerStatefulWidget {
  final String emailId;
  const EmailDetailScreen({super.key, required this.emailId});

  @override
  ConsumerState<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends ConsumerState<EmailDetailScreen> {
  bool _showDetails = false;

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
  String _formatDate(DateTime timestamp) {
    return DateFormat('d MMM yyyy, HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final emailDetailAsyncValue = ref.watch(emailDetailProvider(widget.emailId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined, color: Colors.white), 
            onPressed: () {
              ref.read(emailDetailProvider(widget.emailId).notifier).archiveEmail(widget.emailId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email archived')));
            }
          ),
          IconButton(icon: Icon(Icons.delete_outline, color: Colors.white), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.mark_email_unread_outlined, color: Colors.white), 
            onPressed: () {
              ref.read(emailDetailProvider(widget.emailId).notifier).toggleReadStatus(widget.emailId, false);
              Navigator.pop(context);
            }
          ),
          IconButton(icon: Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: emailDetailAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (email) {
          if (email == null) return const Center(child: Text('Email not found.'));
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                email.subject,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref.read(emailDetailProvider(widget.emailId).notifier).toggleStar(widget.emailId);
                              },
                              child: Icon(
                                email.isStarred ? Icons.star : Icons.star_border, 
                                color: email.isStarred ? Colors.amber : (isDark ? Colors.grey[400] : Colors.grey[600])
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Label / Badge Placeholder
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue[900]?.withValues(alpha: 0.3) : Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Inbox',
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.blue[200] : Colors.blue[800], fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sender Info Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              backgroundImage: const NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Sender'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        email.senderName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.verified, color: Colors.blue[400], size: 14), // Mock verified icon
                                      const Spacer(),
                                      Text(
                                        _formatTime(email.timestamp),
                                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.more_vert, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _showDetails = !_showDetails),
                                    child: Row(
                                      children: [
                                        Text('to me', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13)),
                                        Icon(_showDetails ? Icons.expand_less : Icons.expand_more, size: 16, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Expanded Details
                      if (_showDetails)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600],)),
                                  Expanded(child: Text('${email.senderName} · ${email.senderEmail}')),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('To', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600],)),
                                  Expanded(child: Text(email.recipientEmail)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600],)),
                                  Expanded(child: Text(_formatDate(email.timestamp))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      // Body Box mimicking image 1 dark container
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          // border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email.fullBody.isNotEmpty ? email.fullBody : 'No body content.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.grey[300] : Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComposeEmailScreen(
                                  initialTo: email.senderEmail,
                                  initialSubject: 'Re: ${email.subject}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.reply),
                          label: const Text('Reply'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComposeEmailScreen(
                                  initialSubject: 'Fwd: ${email.subject}',
                                  initialBody: '\n\n---------- Forwarded message ---------\nFrom: ${email.senderName} <${email.senderEmail}>\nDate: ${_formatDate(email.timestamp)}\nSubject: ${email.subject}\nTo: ${email.recipientEmail}\n\n${email.fullBody}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forward),
                          label: const Text('Forward'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).colorScheme.primary,
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: IconButton(
                      //     icon: const Icon(Icons.emoji_emotions_outlined),
                      //     color: Colors.white,
                      //     onPressed: () {},
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
