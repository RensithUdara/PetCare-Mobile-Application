import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final sent =
        await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (sent && mounted) setState(() => _sentTo = email);
  }

  @override
  Widget build(BuildContext context) {
    listenForAuthErrors(ref, context);
    final loading = ref.watch(authControllerProvider).isLoading;

    if (_sentTo != null) {
      return AuthScaffold(
        title: 'Check your email',
        subtitle: 'If an account exists for $_sentTo, you’ll receive a link '
            'to reset your password shortly.',
        showBack: true,
        children: [
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Sign In'),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we’ll send you a reset link',
      showBack: true,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
        ),
        const SizedBox(height: 24),
        LoadingButton(label: 'Send Reset Link', loading: loading, onPressed: _submit),
      ],
    );
  }
}
