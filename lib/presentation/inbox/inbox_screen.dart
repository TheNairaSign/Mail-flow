import 'package:email_snaarp/presentation/compose/compose_email.dart';
import 'package:email_snaarp/presentation/detail/email_detail_screen.dart';
import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:email_snaarp/presentation/auth/account_provider.dart';
import 'package:email_snaarp/presentation/inbox/widgets/email_list_tile.dart';
import 'package:email_snaarp/presentation/inbox/widgets/gmail_drawer.dart';
import 'package:email_snaarp/presentation/inbox/widgets/account_bottom_sheet.dart';
import 'package:email_snaarp/presentation/inbox/widgets/empty_state_widget.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;
  String _searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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
    final activeUser = ref.watch(accountProvider).activeUser;

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
                            child: CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(activeUser.avatarUrl),
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
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        if (!e.subject.toLowerCase().contains(q) &&
                            !e.senderName.toLowerCase().contains(q) &&
                            !e.fullBody.toLowerCase().contains(q)) {
                          return false;
                        }
                      }

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
        
                    final isPrimary = (activeFolder == 'primary' || activeFolder == 'inbox') && _searchQuery.isEmpty;
                    final itemCount = (displayEmails.isEmpty && !isPrimary) ? 1 : displayEmails.length + (isPrimary ? 3 : 0);
        
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(height: 2, color: Theme.of(context).scaffoldBackgroundColor),
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
        label: const Text('Compose', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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