import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/logic/weight_trend.dart';
import '../controllers/weight_controller.dart';
import '../providers/weight_providers.dart';
import '../widgets/weight_widgets.dart';

/// A pet's weight history: summary, chart and list of weigh-ins.
class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  WeightRange _range = WeightRange.all;

  void _showError() {
    final error = ref.read(weightControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error is Failure ? error.message : 'Something went wrong.')),
    );
  }

  Future<void> _logWeight() async {
    final logged = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LogWeightSheet(petId: widget.petId),
    );
    if (logged == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged')));
    }
  }

  Future<void> _delete(WeightEntry entry) async {
    if (!await ref.read(weightControllerProvider.notifier).delete(entry) && mounted) _showError();
  }

  @override
  Widget build(BuildContext context) {
    final petName = ref.watch(petProvider(widget.petId)).value?.name;
    final weights = ref.watch(petWeightsProvider(widget.petId));
    final now = ref.watch(clockProvider)();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BrandAppBar.page(title: petName == null ? 'Weight' : '$petName’s Weight'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logWeight,
        icon: const Icon(Icons.add),
        label: const Text('Log Weight'),
      ),
      body: weights.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Could not load weight history.',
          onRetry: () => ref.invalidate(petWeightsProvider(widget.petId)),
        ),
        data: (all) {
          final summary = summarize(all);
          if (summary == null) {
            return const EmptyState(
              icon: Icons.monitor_weight_outlined,
              title: 'No weigh-ins yet',
              message: 'Log your pet’s weight regularly to spot changes early.',
            );
          }
          final visible = entriesInRange(all, _range, now);
          final newestFirst = all.reversed.toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              WeightSummaryCard(summary: summary),
              const SizedBox(height: 16),
              SegmentedButton<WeightRange>(
                segments: [
                  for (final r in WeightRange.values) ButtonSegment(value: r, label: Text(r.label)),
                ],
                selected: {_range},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _range = s.first),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: visible.length < 2
                    ? Center(
                        child: Text(
                          visible.isEmpty
                              ? 'No weigh-ins in this period'
                              : 'Log another weigh-in to see a trend',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 12, top: 8),
                        child: WeightChart(entries: visible),
                      ),
              ),
              const SizedBox(height: 24),
              Text('History', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < newestFirst.length; i++)
                      Dismissible(
                        key: ValueKey(newestFirst[i].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: theme.colorScheme.errorContainer,
                          child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
                        ),
                        onDismissed: (_) => _delete(newestFirst[i]),
                        child: _HistoryRow(
                          entry: newestFirst[i],
                          previous: i + 1 < newestFirst.length ? newestFirst[i + 1] : null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Swipe left on an entry to delete it.',
                  textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, this.previous});

  final WeightEntry entry;
  final WeightEntry? previous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = previous == null ? null : entry.weightKg - previous!.weightKg;
    return ListTile(
      title: Text('${kg(entry.weightKg)} kg'),
      subtitle: Text([DateFormat.yMMMd().format(entry.date), ?entry.note].join(' · ')),
      trailing: delta == null
          ? null
          : Text(signedKg((delta * 10).round() / 10),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

class _LogWeightSheet extends ConsumerStatefulWidget {
  const _LogWeightSheet({required this.petId});

  final String petId;

  @override
  ConsumerState<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends ConsumerState<_LogWeightSheet> {
  final _formKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  final _note = TextEditingController();
  late DateTime? _date = dateOnly(ref.read(clockProvider)());

  @override
  void dispose() {
    _weight.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(weightControllerProvider.notifier).log(
          petId: widget.petId,
          weightKg: double.parse(_weight.text.trim().replaceAll(',', '.')),
          date: _date!,
          note: _note.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      final error = ref.read(weightControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error is Failure ? error.message : 'Could not save weight.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(weightControllerProvider).isLoading;
    final now = ref.watch(clockProvider)();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Log weight', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weight,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Weight is required' : Validators.weight(v),
              decoration: const InputDecoration(
                labelText: 'Weight *',
                suffixText: 'kg',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DateField(
              label: 'Date',
              initialValue: _date,
              firstDate: DateTime(now.year - 20),
              lastDate: now,
              clearable: false,
              validator: (d) => d == null ? 'Date is required' : null,
              onChanged: (d) => _date = d,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'e.g. After vet visit',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy ? null : _save,
              child: busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
