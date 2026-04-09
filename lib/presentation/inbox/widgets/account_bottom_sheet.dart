import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_snaarp/presentation/auth/account_provider.dart';

class AccountBottomSheet extends ConsumerStatefulWidget {
  const AccountBottomSheet({super.key});

  @override
  ConsumerState<AccountBottomSheet> createState() => _AccountBottomSheetState();
}

class _AccountBottomSheetState extends ConsumerState<AccountBottomSheet> {
  bool _isSwitchExpanded = true;

  void _showAddAccountDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2E30) : Colors.white,
          title: const Text('Add account'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter email address',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(accountProvider.notifier).addAccount(controller.text);
                  setState(() {
                    _isSwitchExpanded = true;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountState = ref.watch(accountProvider);
    final activeUser = accountState.activeUser;
    final otherUsers = accountState.otherUsers;
    
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
          CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(activeUser.avatarUrl),
          ),
          const SizedBox(height: 12),
          Text('Hi, ${activeUser.name}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(activeUser.email, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: .none
            ),
            child: Text('Manage your Google Account', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ListTile(
            title: const Text('Switch account', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(_isSwitchExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onTap: () {
              setState(() {
                _isSwitchExpanded = !_isSwitchExpanded;
              });
            },
          ),
          if (_isSwitchExpanded) ...[
            ...otherUsers.map((user) => ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
              onTap: () {
                ref.read(accountProvider.notifier).switchAccount(user.id);
                // The UI updates reactively, no need to pop the bottom sheet if we want the user to see the change,
                // but usually switching account closes the sheet.
                Navigator.pop(context);
              },
            )),
          ],
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add another account'),
            onTap: _showAddAccountDialog,
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Manage accounts on this device'),
            onTap: () {},
          ),
    //       const SizedBox(height: 8),
    //       Container(
    //         padding: const EdgeInsets.all(16),
    //         margin: const EdgeInsets.symmetric(horizontal: 16),
    //         decoration: BoxDecoration(
    //           color: isDark ? const Color(0xFF2D2E30) : Colors.grey[100],
    //           borderRadius: BorderRadius.circular(16),
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               children: [
    //                 const Icon(Icons.cloud_outlined),
    //                 const SizedBox(width: 12),
    //                 const Text('16% of 100 GB used', style: TextStyle(fontWeight: FontWeight.bold)),
    //               ],
    //             ),
    //             const SizedBox(height: 8),
    //             LinearProgressIndicator(
    //               value: 0.16,
    //               backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
    //               valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
    //               borderRadius: BorderRadius.circular(4),
    //             ),
    //             const SizedBox(height: 4),
    //             Text('16.44 GB of 100 GB', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    //             const SizedBox(height: 12),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 TextButton(onPressed: () {}, child: const Text('Get storage')),
    //                 TextButton(onPressed: () {}, child: const Text('Clean up space')),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //       Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text('Privacy Policy', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    //             const Padding(
    //               padding: EdgeInsets.symmetric(horizontal: 8.0),
    //               child: Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
    //             ),
    //             Text('Terms of Service', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    //           ],
    //         ),
    //       ),
        ],
      ),
    );
  }
}

