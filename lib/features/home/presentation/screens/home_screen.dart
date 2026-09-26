import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/greeting.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final name = user?.displayName?.split(' ').first;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${greetingFor(DateTime.now())}${name == null ? '' : ', $name'} 👋',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.dashboard_outlined,
                title: 'Your dashboard',
                message:
                    'Upcoming vaccinations, appointments and pet summaries will appear here.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
