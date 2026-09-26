import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';

/// Round owner avatar: photo when available, otherwise initials on a
/// brand gradient.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.initials, this.photoUrl, this.radius = 40});

  final String initials;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.brandGradient),
      child: initials.isEmpty
          ? Icon(Icons.person, color: Colors.white, size: radius)
          : Text(
              initials,
              style: TextStyle(color: Colors.white, fontSize: radius * 0.7, fontWeight: FontWeight.w800),
            ),
    );
    return SizedBox.square(
      dimension: radius * 2,
      child: ClipOval(
        child: photoUrl == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => placeholder,
                errorWidget: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

/// Titled group of [SettingsTile]s in one soft card.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 24, 6, 10),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const Divider(indent: 72, endIndent: 16),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final FeatureAccent accent;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: IconBadge(icon: icon, accent: accent, size: 40),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right)),
      onTap: onTap,
    );
  }
}

/// Bottom sheet with the support email: copy it, or open the mail app.
Future<void> showContactSupportSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final messenger = ScaffoldMessenger.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: IconBadge(icon: Icons.support_agent, accent: FeatureAccent.clinics, size: 60)),
                const SizedBox(height: 16),
                Text('Contact support',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  'Questions, bugs or ideas? Email us and we’ll get back to you, '
                  'usually within 1–2 working days.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                SoftCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.mail_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectableText(AppConstants.supportEmail,
                            style: theme.textTheme.titleSmall),
                      ),
                      IconButton(
                        tooltip: 'Copy email',
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () async {
                          await Clipboard.setData(const ClipboardData(text: AppConstants.supportEmail));
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                          messenger.showSnackBar(const SnackBar(content: Text('Email address copied')));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final ok = await launchUrl(Uri(
                      scheme: 'mailto',
                      path: AppConstants.supportEmail,
                      queryParameters: {'subject': '${AppConstants.appName} support (v${AppConstants.version})'},
                    ));
                    if (!ok) {
                      messenger.showSnackBar(const SnackBar(
                        content: Text('No email app found. Copy the address instead.'),
                      ));
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Write an email'),
                ),
              ],
            ),
          ),
        );
      },
    );
