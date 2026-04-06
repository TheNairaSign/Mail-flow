import 'package:email_snaarp/presentation/compose/compose_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Recipient chip model ─────────────────────────────────────────────────────
class Recipient {
  final String name;
  final String email;
  const Recipient({required this.name, required this.email});
  String get initials => name.isNotEmpty
      ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
      : email.isNotEmpty
          ? email[0].toUpperCase()
          : '?';
}

// ─── Attachment model ─────────────────────────────────────────────────────────
class Attachment {
  final String filename;
  const Attachment({required this.filename});
}

// ─── Main compose screen ──────────────────────────────────────────────────────
class ComposeEmailScreen extends ConsumerStatefulWidget {
  const ComposeEmailScreen({super.key});

  @override
  ConsumerState<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends ConsumerState<ComposeEmailScreen> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _ccCtrl = TextEditingController();
  final _bccCtrl = TextEditingController();

  bool _showCcBcc = false;
  bool _isSending = false;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  final List<Recipient> _recipients = [];
  final List<Attachment> _attachments = [];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    _toCtrl.dispose();
    _ccCtrl.dispose();
    _bccCtrl.dispose();
    super.dispose();
  }

  void _removeRecipient(Recipient r) => setState(() => _recipients.remove(r));

  void _addRecipient(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recipients.add(Recipient(name: trimmed, email: trimmed));
      _toCtrl.clear();
    });
  }

  void _removeAttachment(Attachment a) => setState(() => _attachments.remove(a));

  void _pickAttachment() {
    setState(() {
      _attachments.add(const Attachment(filename: 'attachment.pdf'));
    });
  }

  Future<void> _send() async {
    if (_recipients.isEmpty) {
      _showSnack('Please add at least one recipient.');
      return;
    }
    setState(() => _isSending = true);
    
    final success = await ref.read(composeProvider.notifier).sendEmail(
      recipientEmail: _recipients.map((r) => r.email).join(', '),
      subject: _subjectCtrl.text,
      body: _bodyCtrl.text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _showSnack('Email sent successfully!');
        Navigator.of(context).maybePop();
      } else {
        _showSnack('Failed to send email');
      }
    }
  }

  void _showSnack(String msg) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmDiscard() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Discard draft?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Your draft will not be saved.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep editing',
              style: TextStyle(color: theme.textTheme.bodySmall?.color),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.maybePop(context);
            },
            child: const Text(
              'Discard',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleSend() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              isSending: _isSending,
              onClose: _confirmDiscard,
              onSend: _send,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RecipientsField(
                      recipients: _recipients,
                      controller: _toCtrl,
                      onRemove: _removeRecipient,
                      onAdd: _addRecipient,
                      onToggleCcBcc: () => setState(() => _showCcBcc = !_showCcBcc),
                      showCcBcc: _showCcBcc,
                    ),
                    if (_showCcBcc) ...[
                      _SimpleField(
                        label: 'Cc',
                        controller: _ccCtrl,
                        hint: 'Add Cc recipients…',
                      ),
                      _SimpleField(
                        label: 'Bcc',
                        controller: _bccCtrl,
                        hint: 'Add Bcc recipients…',
                      ),
                    ],
                    _SubjectField(controller: _subjectCtrl),
                    // _FormattingBar(
                    //   isBold: _isBold,
                    //   isItalic: _isItalic,
                    //   isUnderline: _isUnderline,
                    //   onBold: () => setState(() => _isBold = !_isBold),
                    //   onItalic: () => setState(() => _isItalic = !_isItalic),
                    //   onUnderline: () => setState(() => _isUnderline = !_isUnderline),
                    // ),
                    _BodyField(controller: _bodyCtrl),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _BottomBar(
              attachments: _attachments,
              bodyLength: _bodyCtrl.text.length,
              onAttach: _pickAttachment,
              onRemoveAttachment: _removeAttachment,
              onSchedule: _scheduleSend,
              onDiscard: _confirmDiscard,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isSending;
  final VoidCallback onClose;
  final VoidCallback onSend;

  const _TopBar({
    required this.isSending,
    required this.onClose,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      // color: theme.colorScheme.primary,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _BarIconBtn(icon: Icons.close, onTap: onClose),
          const SizedBox(width: 10),
          Text(
            'New message',
            style: theme.textTheme.titleLarge?.copyWith(),
          ),
          // const SizedBox(width: 10),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          //   decoration: BoxDecoration(
          //     color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Text(
          //     'Draft saved',
          //     style: theme.textTheme.labelSmall?.copyWith(
          //       color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          //     ),
          //   ),
          // ),
          const Spacer(),
          isSending
              ? const SizedBox(
                  width: 80,
                  height: 36,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),
                    ),
                  ),
                )
              : _SendButton(onTap: onSend),
        ],
      ),
    );
  }
}

class _BarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BarIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.send_rounded, size: 25, color: theme.colorScheme.primary),
    );
  }
}

// ─── Recipients field ─────────────────────────────────────────────────────────
class _RecipientsField extends StatelessWidget {
  final List<Recipient> recipients;
  final TextEditingController controller;
  final void Function(Recipient) onRemove;
  final void Function(String) onAdd;
  final VoidCallback onToggleCcBcc;
  final bool showCcBcc;

  const _RecipientsField({
    required this.recipients,
    required this.controller,
    required this.onRemove,
    required this.onAdd,
    required this.onToggleCcBcc,
    required this.showCcBcc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _FieldLabel(text: 'To'),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...recipients.map(
                  (r) => _RecipientChip(recipient: r, onRemove: () => onRemove(r)),
                ),
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
      ),
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
            size: 20,
            fontSize: 9,
            background: theme.colorScheme.secondary,
            foreground: theme.colorScheme.onSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            recipient.email,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Text(
              '×',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.secondary,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Cc / Bcc field ────────────────────────────────────────────────────
class _SimpleField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  const _SimpleField({required this.label, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FieldLabel(text: label),
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subject field ────────────────────────────────────────────────────────────
class _SubjectField extends StatelessWidget {
  final TextEditingController controller;
  const _SubjectField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const _FieldLabel(text: 'Subject'),
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Add a subject…',
                hintStyle: theme.textTheme.titleSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formatting bar ───────────────────────────────────────────────────────────
class _FormattingBar extends StatelessWidget {
  final bool isBold, isItalic, isUnderline;
  final VoidCallback onBold, onItalic, onUnderline;

  const _FormattingBar({
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
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
            _FmtBtn(icon: Icons.format_italic, active: isItalic, onTap: onItalic),
            _FmtBtn(icon: Icons.format_underline, active: isUnderline, onTap: onUnderline),
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
      onTap: () {}, // Future style selection
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
  const _FmtBtn({required this.icon, this.active = false, required this.onTap});

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

// ─── Body field ───────────────────────────────────────────────────────────────
class _BodyField extends StatelessWidget {
  final TextEditingController controller;
  const _BodyField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: TextField(
        controller: controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.75,
        ),
        decoration: InputDecoration(
          hintText: 'Write your message…',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final List<Attachment> attachments;
  final int bodyLength;
  final VoidCallback onAttach;
  final void Function(Attachment) onRemoveAttachment;
  final VoidCallback onSchedule;
  final VoidCallback onDiscard;

  const _BottomBar({
    required this.attachments,
    required this.bodyLength,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.onSchedule,
    required this.onDiscard,
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
              _ToolIconBtn(
                icon: Icons.lock_outline,
                onTap: () {},
                tooltip: 'Confidential',
              ),
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
            Icon(Icons.attach_file, size: 14, color: theme.textTheme.bodySmall?.color),
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
          Icon(Icons.picture_as_pdf, size: 13, color: theme.colorScheme.secondary),
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

// ─── Initials avatar ──────────────────────────────────────────────────────────
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
          color: foreground,
        ),
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────
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

// ─── Schedule send bottom sheet ───────────────────────────────────────────────
class _ScheduleSheet extends StatelessWidget {
  const _ScheduleSheet();

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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Scheduled for ${o['sub']}',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
