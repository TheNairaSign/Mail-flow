import 'package:email_snaarp/presentation/compose/compose_provider.dart';
import 'package:email_snaarp/presentation/detail/models/compose_models.dart';
import 'package:email_snaarp/presentation/detail/widgets/compose_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComposeEmailScreen extends ConsumerStatefulWidget {
  const ComposeEmailScreen({super.key});

  @override
  ConsumerState<ComposeEmailScreen> createState() =>
      _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends ConsumerState<ComposeEmailScreen> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _ccCtrl = TextEditingController();
  final _bccCtrl = TextEditingController();

  bool _showCcBcc = false;
  bool _isSending = false;

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

  void _removeAttachment(Attachment a) =>
      setState(() => _attachments.remove(a));

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
      builder: (_) => const ComposeScheduleSheet(),
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
            ComposeTopBar(
              isSending: _isSending,
              onClose: _confirmDiscard,
              onSend: _send,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ComposeRecipientsField(
                      recipients: _recipients,
                      controller: _toCtrl,
                      onRemove: _removeRecipient,
                      onAdd: _addRecipient,
                      onToggleCcBcc: () => setState(() => _showCcBcc = !_showCcBcc),
                      showCcBcc: _showCcBcc,
                    ),
                    if (_showCcBcc) ...[
                      ComposeSimpleField(
                        label: 'Cc',
                        controller: _ccCtrl,
                        hint: 'Add Cc recipients…',
                      ),
                      ComposeSimpleField(
                        label: 'Bcc',
                        controller: _bccCtrl,
                        hint: 'Add Bcc recipients…',
                      ),
                    ],
                    ComposeSubjectField(controller: _subjectCtrl),
                    // ComposeFormattingBar(
                    //   isBold: _isBold,
                    //   isItalic: _isItalic,
                    //   isUnderline: _isUnderline,
                    //   onBold: () => setState(() => _isBold = !_isBold),
                    //   onItalic: () => setState(() => _isItalic = !_isItalic),
                    //   onUnderline: () =>
                    //       setState(() => _isUnderline = !_isUnderline),
                    // ),
                    ComposeBodyField(controller: _bodyCtrl),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            ComposeBottomBar(
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
