import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_application/presentation/providers/auth_provider.dart';
import 'package:startup_application/presentation/widgets/custom_button.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    // High contrast B&W styling preference for Auth
    final buttonColor =
        theme.brightness == Brightness.light ? Colors.black : Colors.white;
    final buttonTextColor =
        theme.brightness == Brightness.light ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authProvider.notifier).signOut(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80),
            const SizedBox(height: 32),
            Text(
              'Verify Your Email',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'A verification link has been sent to your email address. Please check your inbox to activate your account.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (authState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            CustomButton(
              onPressed: () {
                final user = ref.read(authProvider).user;
                if (user?.email != null) {
                  ref
                      .read(authProvider.notifier)
                      .resendVerificationEmail(user!.email!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email resent')),
                  );
                }
              },
              text: 'Resend Verification Email',
              backgroundColor: buttonColor,
              textColor: buttonTextColor,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/signin'), // Or refresh?
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
