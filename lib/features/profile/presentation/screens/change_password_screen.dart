import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../controllers/account_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _obscure = [true, true, true];

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(accountControllerProvider.notifier)
        .changePassword(currentPassword: _current.text, newPassword: _new.text);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
    context.pop();
  }

  Widget _field(int i, TextEditingController c, String label, FormFieldValidator<String> validator,
      {TextInputAction action = TextInputAction.next}) {
    return TextFormField(
      controller: c,
      obscureText: _obscure[i],
      textInputAction: action,
      onFieldSubmitted: action == TextInputAction.done ? (_) => _submit() : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure[i] ? 'Show password' : 'Hide password',
          icon: Icon(_obscure[i] ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure[i] = !_obscure[i]),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(accountControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SoftCard(
              child: Row(
                children: [
                  const IconBadge(icon: Icons.shield_outlined, accent: FeatureAccent.medications, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Use at least 8 characters with a mix of letters and numbers. '
                      'You’ll stay signed in on this device.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  _field(0, _current, 'Current password', Validators.loginPassword),
                  const SizedBox(height: 14),
                  _field(1, _new, 'New password', Validators.newPassword),
                  const SizedBox(height: 14),
                  _field(2, _confirm, 'Confirm new password', Validators.confirmPassword(() => _new.text),
                      action: TextInputAction.done),
                ],
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(state.error!.message,
                  textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.isBusy ? null : _submit,
              child: state.isBusy
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Update password'),
            ),
          ],
        ),
      ),
    );
  }
}
