import 'package:flutter/material.dart';

class ComposeScheduleSheet extends StatelessWidget {
  const ComposeScheduleSheet({super.key});

  List<Map<String, String>> _options() => [
    {'label': 'Later today', 'sub': '6:00 PM'},
    {'label': 'Tomorrow morning', 'sub': '8:00 AM'},
    {'label': 'Tomorrow afternoon', 'sub': '1:00 PM'},
    {'label': 'Next Monday', 'sub': 'Mon, 8:00 AM'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule send',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._options().map(
            (o) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.schedule_outlined,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              title: Text(
                o['label']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                o['sub']!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Scheduled for ${o['sub']}',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
