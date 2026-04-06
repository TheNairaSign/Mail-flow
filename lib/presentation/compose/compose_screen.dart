import 'package:email_snaarp/presentation/compose/compose_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_toController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _bodyController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard email?'),
              content: const Text('You have unsaved changes. Do you want to discard this email?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Future<void> _sendEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSending = true;
      });

      final success = await ref.read(composeProvider.notifier).sendEmail(
            recipientEmail: _toController.text,
            subject: _subjectController.text,
            body: _bodyController.text,
          );

      if (mounted) {
        setState(() {
          _isSending = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email sent successfully')),
          );
          Navigator.pop(context); // Dismiss the compose screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send email')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isSending, // Prevent popping while sending
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          if (mounted) Navigator.pop(context);
        }
      },
      child: Hero(
        tag: 'compose_hero',
        child: Scaffold(
          appBar: AppBar(
          title: const Text('New message'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          actions: [
            _isSending
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: _sendEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column( // Changed to Column to allow for Dividers
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero, // Remove padding from ListView
                  children: [
                    TextFormField(
                      controller: _toController,
                      decoration: InputDecoration(
                        hintText: 'To', // Changed to hintText
                        border: InputBorder.none,
                        filled: true,
                        fillColor: colorScheme.surface, // Use surface for background
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter recipient email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant), // Thin divider
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Subject', // Changed to hintText
                        border: InputBorder.none,
                        filled: true,
                        fillColor: colorScheme.surface, // Use surface for background
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant), // Thin divider
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Cc/Bcc', // New field
                        border: InputBorder.none,
                        filled: true,
                        fillColor: colorScheme.surface, // Use surface for background
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant), // Thin divider
                    TextFormField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        hintText: 'Compose email', // Changed to hintText
                        border: InputBorder.none,
                        filled: true,
                        fillColor: colorScheme.surface, // Use surface for background
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      maxLines: null, // Allows the field to expand
                      minLines: 10,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email body';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat feature coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.attachment),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attachment feature coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Star feature coming soon')),
                  );
                },
              ),
              const Spacer(), // Pushes icons to the left
            ],
          ),
        ),
      ),
    ),
  );
  }
}