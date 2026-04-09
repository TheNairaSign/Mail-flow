import 'package:flutter/material.dart';

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
