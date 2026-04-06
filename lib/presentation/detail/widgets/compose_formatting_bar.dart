import 'package:flutter/material.dart';

class ComposeFormattingBar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;

  const ComposeFormattingBar({
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const _FmtLabel(text: 'Normal'),
            const _FmtSep(),
            _FmtBtn(icon: Icons.format_bold, active: isBold, onTap: onBold),
            _FmtBtn(
              icon: Icons.format_italic,
              active: isItalic,
              onTap: onItalic,
            ),
            _FmtBtn(
              icon: Icons.format_underline,
              active: isUnderline,
              onTap: onUnderline,
            ),
            const _FmtSep(),
            _FmtBtn(icon: Icons.format_list_bulleted, onTap: () {}),
            _FmtBtn(icon: Icons.format_list_numbered, onTap: () {}),
            _FmtBtn(icon: Icons.format_quote, onTap: () {}),
            const _FmtSep(),
            _FmtBtn(icon: Icons.link, onTap: () {}),
            _FmtBtn(icon: Icons.image_outlined, onTap: () {}),
            const _FmtSep(),
            _FmtBtn(icon: Icons.format_color_text, onTap: () {}),
            _FmtBtn(icon: Icons.format_clear, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _FmtSep extends StatelessWidget {
  const _FmtSep();

  @override
  Widget build(BuildContext context) => Container(
        width: 0.5,
        height: 18,
        color: Theme.of(context).dividerColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

class _FmtLabel extends StatelessWidget {
  final String text;
  const _FmtLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FmtBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _FmtBtn({
    required this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
