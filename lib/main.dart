import 'package:email_snaarp/presentation/auth/auth_provider.dart';
import 'package:email_snaarp/presentation/auth/login_screen.dart';
import 'package:email_snaarp/presentation/inbox/inbox_screen.dart';
import 'package:email_snaarp/presentation/detail/email_detail_screen.dart';
import 'package:email_snaarp/presentation/compose/compose_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_snaarp/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Email Snaarp',
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: authState ? '/inbox' : '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/inbox':
            return MaterialPageRoute(builder: (_) => const InboxScreen());
          case '/email_detail':
            final args = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => EmailDetailScreen(emailId: args!));
          case '/compose':
            return MaterialPageRoute(builder: (_) => const ComposeScreen());
          default:
            return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
        }
      },
    );
  }
}