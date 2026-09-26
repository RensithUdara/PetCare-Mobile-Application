import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../widgets/faq_content.dart';
import '../widgets/profile_widgets.dart';

/// Searchable help centre with questions grouped by topic.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _search = TextEditingController();
  String _query = '';
  FaqCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<(FaqCategory, List<FaqEntry>)> get _visible => [
        for (final c in faqCategories)
          if (_category == null || _category == c)
            (c, c.entries.where((e) => _query.isEmpty || e.matches(_query)).toList()),
      ].where((group) => group.$2.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _visible;

    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Help & FAQ'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          GradientHeader(
            floating: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How can we help?',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Search our answers or browse by topic.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search questions',
                    fillColor: theme.colorScheme.surface,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _search.clear();
                              _query = '';
                            }),
                          ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                _TopicChip(
                  label: 'All',
                  icon: Icons.apps_rounded,
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final c in faqCategories)
                  _TopicChip(
                    label: c.title,
                    icon: c.icon,
                    accent: c.accent,
                    selected: _category == c,
                    onTap: () => setState(() => _category = _category == c ? null : c),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No answers found',
                      message: 'Try other words, or contact us and we’ll help.',
                    ),
                  ),
                for (final (category, entries) in groups) ...[
                  SectionTitle(title: category.title, icon: category.icon, accent: category.accent),
                  SoftCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final (i, entry) in entries.indexed) ...[
                          if (i > 0) const Divider(indent: 16, endIndent: 16),
                          _FaqTile(entry: entry, accent: category.accent, expanded: _query.isNotEmpty),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SoftCard(
                  gradient: LinearGradient(colors: [
                    FeatureAccent.clinics.color.withValues(alpha: 0.14),
                    FeatureAccent.appointments.color.withValues(alpha: 0.14),
                  ]),
                  child: Row(
                    children: [
                      const IconBadge(icon: Icons.support_agent, accent: FeatureAccent.clinics, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Still need help?',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            Text('Our team is happy to answer.', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
                        onPressed: () => showContactSupportSheet(context),
                        child: const Text('Contact'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = FeatureAccent.pets,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final FeatureAccent accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18, color: selected ? Colors.white : accent.color),
        label: Text(label),
        selected: selected,
        selectedColor: accent.color,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.entry, required this.accent, required this.expanded});

  final FaqEntry entry;
  final FeatureAccent accent;

  /// Search results open automatically so matches are visible.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey('${entry.question}-$expanded'),
        initiallyExpanded: expanded,
        iconColor: accent.color,
        collapsedIconColor: theme.colorScheme.onSurfaceVariant,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        title: Text(entry.question, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [
          Text(entry.answer,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45)),
        ],
      ),
    );
  }
}
