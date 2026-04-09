import 'package:email_snaarp/domain/entities/email_entity.dart';
import 'package:email_snaarp/presentation/compose/compose_email.dart';
import 'package:email_snaarp/presentation/detail/email_detail_screen.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 10 && _isFabExtended) {
        setState(() => _isFabExtended = false);
      } else if (_scrollController.offset <= 10 && !_isFabExtended) {
        setState(() => _isFabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final emailDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    if (now.difference(emailDate).inDays == 0) {
      return DateFormat.Hm().format(timestamp);
    } else {
      return DateFormat.MMMd().format(timestamp);
    }
  }

  void _showAccountBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountBottomSheet(),
    );
  }

  String _getFolderTitle(String folder) {
    switch (folder) {
      case 'primary':
      case 'inbox': return 'Primary';
      case 'starred': return 'Starred';
      case 'sent': return 'Sent';
      case 'all mail': return 'All mail';
      case 'drafts': return 'Drafts';
      case 'bin': return 'Bin';
      case 'spam': return 'Spam';
      default: return folder.isNotEmpty ? folder.substring(0, 1).toUpperCase() + folder.substring(1) : 'Inbox';
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsyncValue = ref.watch(inboxProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeFolder = ref.watch(activeFolderProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const GmailDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(inboxProvider.notifier).fetchEmails(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Floating App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search in emails',
                              hintStyle: TextStyle(fontSize: 16),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAccountBottomSheet,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2), // Mock colorful border
                            ),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Tonye'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Dynamic text indicator
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    _getFolderTitle(activeFolder),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // List Segment
                inboxAsyncValue.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, st) => Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Center(child: Text('Error: $err')),
                  ),
                  data: (emails) {
                    final displayEmails = emails.where((e) {
                      if (activeFolder == 'primary' || activeFolder == 'inbox') {
                        return !e.isArchived && (e.category == 'primary' || e.category.isEmpty);
                      } else if (activeFolder == 'starred') {
                        return e.isStarred;
                      } else if (activeFolder == 'sent') {
                        return e.folder == 'sent';
                      } else if (activeFolder == 'all mail') {
                        return true;
                      } else if (activeFolder == 'bin') {
                        return e.folder == 'trash';
                      } else if (activeFolder == 'drafts') {
                        return e.folder == 'drafts';
                      }
                      return !e.isArchived;
                    }).toList();
        
                    final isPrimary = activeFolder == 'primary' || activeFolder == 'inbox';
                    final itemCount = (displayEmails.isEmpty && !isPrimary) ? 1 : displayEmails.length + (isPrimary ? 3 : 0);
        
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (displayEmails.isEmpty && !isPrimary) {
                             return Padding(
                               padding: const EdgeInsets.symmetric(vertical: 80.0),
                               child: EmptyStateWidget(
                                 icon: activeFolder == 'starred' ? Icons.star_border : Icons.inbox_outlined,
                                 title: 'Nothing to see here',
                                 subtitle: 'Your folder is empty',
                               ),
                             );
                          }
                      
                          if (isPrimary) {
                            if (index == 0) return _buildHintTile(isDark);
                            if (index == 1) {
                              return _buildCategoryTile(
                                icon: Icons.info_outline,
                                iconColor: Colors.orange,
                                title: 'Updates',
                                subtitle: 'Glassdoor Jobs — Software Engineer at...',
                                badgeText: '99+ new',
                                badgeColor: Colors.orange[800]!,
                                isDark: isDark,
                              );
                            }
                            if (index == 2) {
                              return _buildCategoryTile(
                                icon: Icons.sell_outlined,
                                iconColor: Colors.green,
                                title: 'Promotions',
                                subtitle: 'TRAE — [TRAE] Meet the New SOLO (B...',
                                badgeText: '99+ new',
                                badgeColor: Colors.green[800]!,
                                isDark: isDark,
                              );
                            }
                          }
                          
                          final emailIndex = isPrimary ? index - 3 : index;
                          final email = displayEmails[emailIndex];
                          return EmailListTile(
                            email: email,
                            onTap: () {
                              ref.read(inboxProvider.notifier).updateEmailReadStatus(email.id, true);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EmailDetailScreen(emailId: email.id)));
                            },
                            formatTimestamp: _formatTimestamp,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComposeEmailScreen())),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Compose', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? const Color(0xFF3F445A) : const Color(0xFFC2E7FF),
        foregroundColor: isDark ? const Color(0xFFE2E2E9) : const Color(0xFF001D35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        isExtended: _isFabExtended,
      ),
    );
  }

  Widget _buildHintTile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, color: isDark ? Colors.blue[200] : Colors.blue[700], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tap a sender image to select that conversation.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            'Dismiss',
            style: TextStyle(
              color: isDark ? Colors.blue[200] : Colors.blue[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

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
              child: Text(
                email.senderName.isNotEmpty ? email.senderName[0].toUpperCase() : '?',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
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

// Drawer Widget matching Image 3
class GmailDrawer extends ConsumerWidget {
  const GmailDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final activeFolder = ref.watch(activeFolderProvider);

    void switchFolder(String f) {
       ref.read(activeFolderProvider.notifier).state = f;
       Navigator.pop(context);
    }

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1F21) : colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text('Gmail', style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.blue)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.inbox,
                    title: 'Primary',
                    badge: '99+',
                    isSelected: activeFolder == 'primary' || activeFolder == 'inbox',
                    isDark: isDark,
                    onTap: () => switchFolder('primary'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.sell_outlined,
                    title: 'Promotions',
                    badge: '243 new',
                    badgeColor: Colors.green[800],
                    isDark: isDark,
                    isSelected: activeFolder == 'promotions',
                    onTap: () => switchFolder('promotions'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_outlined,
                    title: 'Social',
                    badge: '95 new',
                    badgeColor: Colors.blue[800],
                    isDark: isDark,
                    isSelected: activeFolder == 'social',
                    onTap: () => switchFolder('social'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'Updates',
                    badge: '801 new',
                    badgeColor: Colors.orange[800],
                    isDark: isDark,
                    isSelected: activeFolder == 'updates',
                    onTap: () => switchFolder('updates'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('All labels', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                  ),
                  _buildDrawerItem(icon: Icons.star_border, title: 'Starred', badge: '1', isDark: isDark, isSelected: activeFolder == 'starred', onTap: () => switchFolder('starred')),
                  _buildDrawerItem(icon: Icons.schedule, title: 'Snoozed', isDark: isDark, isSelected: activeFolder == 'snoozed', onTap: () => switchFolder('snoozed')),
                  _buildDrawerItem(icon: Icons.label_important_outline, title: 'Important', badge: '233', isDark: isDark, isSelected: activeFolder == 'important', onTap: () => switchFolder('important')),
                  _buildDrawerItem(icon: Icons.send_outlined, title: 'Sent', badge: '2', isDark: isDark, isSelected: activeFolder == 'sent', onTap: () => switchFolder('sent')),
                  _buildDrawerItem(icon: Icons.schedule_send_outlined, title: 'Scheduled', isDark: isDark, isSelected: activeFolder == 'scheduled', onTap: () => switchFolder('scheduled')),
                  _buildDrawerItem(icon: Icons.outbox_outlined, title: 'Outbox', isDark: isDark, isSelected: activeFolder == 'outbox', onTap: () => switchFolder('outbox')),
                  _buildDrawerItem(icon: Icons.insert_drive_file_outlined, title: 'Drafts', badge: '7', isDark: isDark, isSelected: activeFolder == 'drafts', onTap: () => switchFolder('drafts')),
                  _buildDrawerItem(icon: Icons.all_inbox, title: 'All mail', badge: '99+', isDark: isDark, isSelected: activeFolder == 'all mail', onTap: () => switchFolder('all mail')),
                  _buildDrawerItem(icon: Icons.report_outlined, title: 'Spam', badge: '43', isDark: isDark, isSelected: activeFolder == 'spam', onTap: () => switchFolder('spam')),
                  _buildDrawerItem(icon: Icons.delete_outline, title: 'Bin', isDark: isDark, isSelected: activeFolder == 'bin', onTap: () => switchFolder('bin')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon, 
    required String title, 
    String? badge, 
    Color? badgeColor, 
    bool isSelected = false,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? (isDark ? const Color(0xFF3F445A) : Colors.blue[100]) : Colors.transparent,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? (isDark ? Colors.blue[200] : Colors.blue[800]) : (isDark ? Colors.grey[400] : Colors.grey[700])),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? (isDark ? Colors.blue[200] : Colors.blue[800]) : (isDark ? Colors.grey[200] : Colors.grey[800]),
          )
        ),
        trailing: badge != null 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? (isSelected ? Colors.transparent : (isDark ? Colors.transparent : Colors.grey[200])),
                  borderRadius: badgeColor != null ? BorderRadius.circular(12) : null,
                ),
                child: Text(
                  badge, 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: badgeColor != null ? Colors.white : (isSelected ? (isDark ? Colors.blue[200] : Colors.blue[800]) : (isDark ? Colors.grey[400] : Colors.grey[600]))
                  )
                ),
              )
            : null,
        dense: true,
        onTap: onTap ?? () {},
      ),
    );
  }
}

// Account Bottom Sheet matching Image 2
class AccountBottomSheet extends StatelessWidget {
  const AccountBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              const SizedBox(width: 8),
            ],
          ),
          const CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Tonye'),
          ),
          const SizedBox(height: 12),
          const Text('Hi, Tonye Bob - Manuel!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('tonyebobmanuel2@gmail.com', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            child: const Text('Manage your Google Account'),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          ListTile(
            title: const Text('Switch account', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.keyboard_arrow_up),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add another account'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Manage accounts on this device'),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2E30) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_outlined),
                    const SizedBox(width: 12),
                    const Text('16% of 100 GB used', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.16,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text('16.44 GB of 100 GB', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Get storage')),
                    TextButton(onPressed: () {}, child: const Text('Clean up space')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Privacy Policy', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Text('Terms of Service', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateWidget({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}