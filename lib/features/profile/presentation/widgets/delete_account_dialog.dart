import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../controllers/account_controller.dart';

/// Confirms permanent account deletion. Password accounts re-enter their
/// password; Google accounts confirm by picking their account again.
Future<void> showDeleteAccountDialog(BuildContext context, {required bool usesPassword}) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteAccountDialog(usesPassword: usesPassword),
    );

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.usesPassword});

  final bool usesPassword;

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _understood = false;
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit => _understood && (!widget.usesPassword || _password.text.isNotEmpty);

  Future<void> _delete() async {
    final ok = await ref
        .read(accountControllerProvider.notifier)
        .deleteAccount(password: widget.usesPassword ? _password.text : null);
    // On success the router takes the user to the login screen.
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(accountControllerProvider);
    final error = theme.colorScheme.error;

    Widget item(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.remove_circle_outline, size: 18, color: error),
              const SizedBox(width: 8),
              Expanded(child: Text(text)),
            ],
          ),
        );

    return AlertDialog(
      icon: const IconBadge(icon: Icons.delete_forever_outlined, accent: FeatureAccent.emergency, size: 56),
      title: const Text('Delete your account?'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('This permanently deletes:'),
          const SizedBox(height: 10),
          item('All pets and their photos'),
          item('Vaccinations, appointments, medications and weight history'),
          item('Uploaded documents'),
          item('Saved clinics and veterinarians'),
          item('Emergency QR pages (the codes stop working)'),
          const SizedBox(height: 6),
          Text('This can’t be undone.', style: TextStyle(color: error, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (widget.usesPassword)
            TextField(
              controller: _password,
              obscureText: _obscure,
              enabled: !state.isBusy,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            )
          else
            Text('You’ll be asked to confirm with your Google account.',
                style: theme.textTheme.bodySmall),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _understood,
            onChanged: state.isBusy ? null : (v) => setState(() => _understood = v ?? false),
            title: const Text('I understand my data will be deleted forever'),
          ),
          if (state.error != null)
            Text(state.error!.message, style: TextStyle(color: error)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: state.isBusy
              ? null
              : () {
                  ref.read(accountControllerProvider.notifier).clearError();
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: error,
            foregroundColor: theme.colorScheme.onError,
            minimumSize: const Size(0, 44),
          ),
          onPressed: _canSubmit && !state.isBusy ? _delete : null,
          child: state.isBusy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text('Delete forever'),
        ),
      ],
    );
  }
}
