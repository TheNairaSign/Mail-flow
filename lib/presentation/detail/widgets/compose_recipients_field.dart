import 'package:flutter/material.dart';
import 'package:email_snaarp/presentation/detail/models/compose_models.dart';

class ComposeRecipientsField extends StatelessWidget {
  final List<Recipient> recipients;
  final TextEditingController controller;
  final void Function(Recipient) onRemove;
  final void Function(String) onAdd;
  final VoidCallback onToggleCcBcc;
  final bool showCcBcc;

  const ComposeRecipientsField({
    required this.recipients,
    required this.controller,
    required this.onRemove,
    required this.onAdd,
    required this.onToggleCcBcc,
    required this.showCcBcc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'To'),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              ...recipients.map(
                (r) => _RecipientChip(
                  recipient: r,
                  onRemove: () => onRemove(r),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 32,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add recipient…',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onSubmitted: onAdd,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onToggleCcBcc,
          child: Text(
            showCcBcc ? 'Hide' : 'Cc Bcc',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipientChip extends StatelessWidget {
  final Recipient recipient;
  final VoidCallback onRemove;
  const _RecipientChip({required this.recipient, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.5),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(5, 4, 8, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InitialsAvatar(
            initials: recipient.initials,
            size: 30,
            fontSize: 9,
            background: theme.colorScheme.secondary,
            foreground: theme.colorScheme.onSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            recipient.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, color: theme.colorScheme.onSurface, size: 12),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  final Color background;
  final Color foreground;

  const _InitialsAvatar({
    required this.initials,
    this.size = 38,
    this.fontSize = 13,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 62,
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.textTheme.bodySmall?.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
