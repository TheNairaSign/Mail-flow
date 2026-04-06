import 'package:flutter/material.dart';

class ComposeTopBar extends StatelessWidget {
  final bool isSending;
  final VoidCallback onClose;
  final VoidCallback onSend;

  const ComposeTopBar({
    required this.isSending,
    required this.onClose,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _BarIconBtn(icon: Icons.close, onTap: onClose),
          const SizedBox(width: 10),
          Text(
            'New message',
            style: theme.textTheme.titleLarge,
          ),
          const Spacer(),
          isSending
              ? const SizedBox(
                  width: 80,
                  height: 36,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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
      child: Icon(
        Icons.send_rounded,
        size: 25,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
