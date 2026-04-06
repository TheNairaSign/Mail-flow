import 'package:flutter/material.dart';
import 'package:email_snaarp/presentation/detail/models/compose_models.dart';

class ComposeBottomBar extends StatelessWidget {
  final List<Attachment> attachments;
  final int bodyLength;
  final VoidCallback onAttach;
  final void Function(Attachment) onRemoveAttachment;
  final VoidCallback onSchedule;
  final VoidCallback onDiscard;

  const ComposeBottomBar({
    required this.attachments,
    required this.bodyLength,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.onSchedule,
    required this.onDiscard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attachments.isNotEmpty)
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: attachments
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _AttachmentChip(
                          attachment: a,
                          onRemove: () => onRemoveAttachment(a),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (attachments.isNotEmpty) const SizedBox(height: 8),
          Row(
            children: [
              _AttachBtn(onTap: onAttach),
              const Spacer(),
              Text(
                '$bodyLength chars',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              _ToolIconBtn(
                icon: Icons.schedule_send_outlined,
                onTap: onSchedule,
                tooltip: 'Schedule send',
              ),
              // _ToolIconBtn(
              //   icon: Icons.lock_outline,
              //   onTap: () {},
              //   tooltip: 'Confidential',
              // ),
              _ToolIconBtn(
                icon: Icons.delete_outline,
                onTap: onDiscard,
                tooltip: 'Discard',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AttachBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              size: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 5),
            Text(
              'Attach',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onRemove;
  const _AttachmentChip({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.dividerColor, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 13,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            attachment.filename,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Text(
              '×',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodySmall?.color,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;
  const _ToolIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
