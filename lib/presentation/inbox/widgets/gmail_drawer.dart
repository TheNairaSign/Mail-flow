import 'package:email_snaarp/presentation/inbox/inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GmailDrawer extends ConsumerWidget {
  const GmailDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final activeFolder = ref.watch(activeFolderProvider);

    void switchFolder(String folder) {
       ref.read(activeFolderProvider.notifier).state = folder;
       Navigator.pop(context);
    }

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text('Gmail', style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
            ),
            Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
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
                    // onTap: () => switchFolder('promotions'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_outlined,
                    title: 'Social',
                    badge: '95 new',
                    badgeColor: Colors.blue[800],
                    isDark: isDark,
                    isSelected: activeFolder == 'social',
                    // onTap: () => switchFolder('social'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'Updates',
                    badge: '801 new',
                    badgeColor: Colors.orange[800],
                    isDark: isDark,
                    isSelected: activeFolder == 'updates',
                    // onTap: () => switchFolder('updates'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('All labels', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                  ),
                  _buildDrawerItem(icon: Icons.star_border, title: 'Starred', badge: '1', isDark: isDark, isSelected: activeFolder == 'starred', onTap: () => switchFolder('starred')),
                  // _buildDrawerItem(icon: Icons.schedule, title: 'Snoozed', isDark: isDark, isSelected: activeFolder == 'snoozed', onTap: () => switchFolder('snoozed')),
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
        color: isSelected ? (Color(0xff5269FF)) : Colors.transparent,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : isDark ? Colors.grey[200] : Colors.grey[800]),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDark
                ? Colors.grey[200]
                : Colors.grey[800]
          )
        ),
        trailing: badge != null 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? (isSelected ? Colors.transparent : (isDark ? Colors.transparent : Colors.grey[200])),
                  borderRadius: badgeColor != null ? BorderRadius.circular(20) : null,
                ),
                child: Text(
                  badge, 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: badgeColor != null ? Colors.white : (isSelected ? ( Colors.white) : (isDark ? Colors.grey[400] : Colors.grey[600]))
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
